classdef REDCapConnection < handle
    %REDCapConnection
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = private)
    end
    
    properties (Constant = true, GetAccess = private)        
        sInformationCompleteCode = "Complete"
        sInformationIncompleteCode = "Incomplete"
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
    end
    
    methods (Access = public, Static)
        
        function DownloadAllRecordsAsCSV(sPath)
            arguments
                sPath (1,1) string
            end
            
            warning(...
                'REDCapConnection:DownloadAllRecordsAsCSV:PatientIdentifiersContainedWithinDownload',...
                'Be aware that the downloaded CSV contains patient DOB, patient DOD, as well as multiple unvalidated, free-text fields that could potentially contain patient information.');
            
            % prepare HTTPS request to REDCap API
            oOptions = matlab.net.http.HTTPOptions;
            oOptions.ConvertResponse = false;
            
            [sAPIToken, sAPIUrl] = FileIOUtils.LoadMatFile(Experiment.GetDataPath('REDCapConnectionSettings'), 'sAPIToken', 'sAPIUrl');
            
            oRequest = matlab.net.http.RequestMessage(...
                matlab.net.http.RequestMethod.POST,...
                [matlab.net.http.HeaderField('Content-Type', 'application/x-www-form-urlencoded'), matlab.net.http.HeaderField('Accept', 'application/json')],...
                matlab.net.http.MessageBody(matlab.net.QueryParameter(...
                "token", sAPIToken,...
                "content", "record",...
                "action", "export",...
                "format", "csv",...
                "type", "flat",...
                "csvDelimiter", "",...
                "rawOrLabel", "label",...
                "rawOrLabelHeaders", "raw",...
                "exportCheckboxLabel", "false",...
                "exportSurveyFields", "false",...
                "exportDataAccessGroups", "false",...
                "returnFormat", "json",...
                "exportBlankForGrayFormStatus", "true",...
                matlab.net.ArrayFormat.php)));
            
            % send request
            oResponse = oRequest.send(matlab.net.URI(sAPIUrl), oOptions);
            
            % get data out of request response
            sData = oResponse.Body.Data;
            
            % escape special characters
            sData = strrep(sData, "%", "%%");
            sData = strrep(sData, "\", "\\");
            
            % save data to CSV file
            fid = fopen(sPath,'wt');
            fprintf(fid, sData);
            fclose(fid);
        end
        
        function [vsQueries, stIncompleteForms] = UpdateMySQLFromRedcap(sRedcapDownloadCsvPath)
            arguments
                sRedcapDownloadCsvPath string = string.empty
            end
            
            bDeleteCsvAfterUpdate = false;
            
            if isempty(sRedcapDownloadCsvPath)
                sRedcapDownloadCsvPath = string(tempname) + ".csv";
            
                % download all data from REDCap to CSV
                REDCapConnection.DownloadAllRecordsAsCSV(sRedcapDownloadCsvPath);
                bDeleteCsvAfterUpdate = true;
            end
                
            e = [];
            
            try 
                % back-up MySQL database
                MySQLDatabase.Backup();
                
                % read in data from CSV and write to MySQL
                [vsQueries, stIncompleteForms] = REDCapConnection.ImportCsvDataAndWriteToMysql(sRedcapDownloadCsvPath);
            catch e                
            end
            
            if bDeleteCsvAfterUpdate
                % make sure the download REDCap data file is deleted
                delete(sRedcapDownloadCsvPath);
                
                warning(...
                    'REDCapConnection:UpdateMysqlFromRedcap:RedcapDownloadDeletedConfirmation',...
                    'Confirmation that the REDCap CSV download was successfully deleted.');
            end
            
            if ~isempty(e)
                rethrow(e);
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static)
        
        function [vsQueries, stIncompleteForms] = ImportCsvDataAndWriteToMysql(sRedcapDownloadCsvPath)
            c2xCsvData = readcell(sRedcapDownloadCsvPath);
            
            vsCsvHeaders = string(c2xCsvData(1,:));
            c2xCsvData = c2xCsvData(2:end,:);
            
            vsQueries = string.empty;
            
            vdIncompleteRowIndices = [];
            vdIncompletePatientIds = [];
            vsIncompleteFormName = string.empty;
            
            % need to track that every entry in the REDCap tables are used
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastasis_histopathology_reports", "id_brain_metastasis_histopathology_reports");
            vd_ids_brain_metastasis_histopathology_reports = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_brain_metastasis_histopathology_reports);
            vb_ids_brain_metastasis_histopathology_reports_used = false(size(vd_ids_brain_metastasis_histopathology_reports));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "breast_cancer_receptor_reports", "id_breast_cancer_receptor_reports");
            vd_ids_breast_cancer_receptor_reports = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_breast_cancer_receptor_reports);
            vb_ids_breast_cancer_receptor_reports_used = false(size(vd_ids_breast_cancer_receptor_reports));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "extracranial_histopathology_reports", "id_extracranial_histopathology_reports");
            vd_ids_extracranial_histopathology_reports = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_extracranial_histopathology_reports);
            vb_ids_extracranial_histopathology_reports_used = false(size(vd_ids_extracranial_histopathology_reports));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "histopathology_reports", "id_histopathology_reports");
            vd_ids_histopathology_reports = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_histopathology_reports);
            vb_ids_histopathology_reports_used = false(size(vd_ids_histopathology_reports));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "lung_cancer_receptor_reports", "id_lung_cancer_receptor_reports");
            vd_ids_lung_cancer_receptor_reports = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_lung_cancer_receptor_reports);
            vb_ids_lung_cancer_receptor_reports_used = false(size(vd_ids_lung_cancer_receptor_reports));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "new_metastases_counts", "id_new_metastases_counts");
            vd_ids_new_metastases_counts = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_new_metastases_counts);
            vb_ids_new_metastases_counts_used = false(size(vd_ids_new_metastases_counts));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "pseudo_progression_conclusions", "id_pseudo_progression_conclusions");
            vd_ids_pseudo_progression_conclusions = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_pseudo_progression_conclusions);
            vb_ids_pseudo_progression_conclusions_used = false(size(vd_ids_pseudo_progression_conclusions));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "pseudo_progression_scores", "id_pseudo_progression_scores");
            vd_ids_pseudo_progression_scores = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_pseudo_progression_scores);
            vb_ids_pseudo_progression_scores_used = false(size(vd_ids_pseudo_progression_scores));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "qualitative_measurements", "id_qualitative_measurements");
            vd_ids_qualitative_measurements = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_qualitative_measurements);
            vb_ids_qualitative_measurements_used = false(size(vd_ids_qualitative_measurements));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "radiology_assessments", "id_radiology_assessments");
            vd_ids_radiology_assessments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_radiology_assessments);
            vb_ids_radiology_assessments_used = false(size(vd_ids_radiology_assessments));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "radionecrosis_treatments", "id_radionecrosis_treatments");
            vd_ids_radionecrosis_treatments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_radionecrosis_treatments);
            vb_ids_radionecrosis_treatments_used = false(size(vd_ids_radionecrosis_treatments));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "radionecrosis_treatments_has_brain_metastases", ["fk_rt_has_bms_id_radionecrosis_treatments" "fk_rt_has_bms_brain_metastases_patient_study_id" "fk_rt_has_bms_brain_metastases_brain_metastasis_number"]);
            vd_fk_rt_has_bms_id_radionecrosis_treatments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.fk_rt_has_bms_id_radionecrosis_treatments);
            vd_fk_rt_has_bms_brain_metastases_patient_study_id = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.fk_rt_has_bms_brain_metastases_patient_study_id);
            vd_fk_rt_has_bms_brain_metastases_brain_metastasis_number = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.fk_rt_has_bms_brain_metastases_brain_metastasis_number);
            vb_radionecrosis_treatments_has_brain_metastases_used = false(size(vd_fk_rt_has_bms_id_radionecrosis_treatments));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "salvage_treatments", "id_salvage_treatments");
            vd_ids_salvage_treatments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_salvage_treatments);
            vb_ids_salvage_treatments_used = false(size(vd_ids_salvage_treatments));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "salvage_treatments_has_brain_metastases", ["fk_st_has_bms_id_salvage_treatments" "fk_st_has_bms_brain_metastases_patient_study_id" "fk_st_has_bms_brain_metastases_brain_metastasis_number"]);
            vd_fk_st_has_bms_id_salvage_treatments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.fk_st_has_bms_id_salvage_treatments);
            vd_fk_st_has_bms_brain_metastases_patient_study_id = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.fk_st_has_bms_brain_metastases_patient_study_id);
            vd_fk_st_has_bms_brain_metastases_brain_metastasis_number = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.fk_st_has_bms_brain_metastases_brain_metastasis_number);
            vb_salvage_treatments_has_brain_metastases_used = false(size(vd_fk_st_has_bms_id_salvage_treatments));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "size_measurements", "id_size_measurements");
            vd_ids_size_measurements = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_size_measurements);
            vb_ids_size_measurements_used = false(size(vd_ids_size_measurements));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "systemic_therapies", "id_systemic_therapies");
            vd_ids_systemic_therapies = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_systemic_therapies);
            vb_ids_systemic_therapies_used = false(size(vd_ids_systemic_therapies));
            
            
            
            for dRowIndex=1:size(c2xCsvData,1)
                if mod(dRowIndex,100) == 0
                    disp(string(dRowIndex) + "/" + string(size(c2xCsvData,1)));
                end
                
                c1xCsvRow = c2xCsvData(dRowIndex,:);
                
                dPatientId = c1xCsvRow{vsCsvHeaders == "study_id"};
                chRepeatInstrument = c1xCsvRow{vsCsvHeaders == "redcap_repeat_instrument"};
                
                oPatient = Patient.LoadFromDatabase(dPatientId);
                
                try
                    
                    if ismissing(chRepeatInstrument) % working with all non-repeat instruments all in one row
                        
                        % process "patient_information" REDCap form
                        
                        vsMysqlColumnNames = [
                            "sex"
                            "age_at_first_srs_srt_months"
                            "deceased_status"
                            "survival_time_months"
                            "data_collection_notes"
                            ];
                        
                        if c1xCsvRow{vsCsvHeaders == "patient_information_complete"} == REDCapConnection.sInformationCompleteCode
                            
                            % age_at_first_srs_srt_months
                            %   can't directly record DOB and DOD since they
                            %   identify patients, so calculate the needed values
                            dtDateOfBirth = c1xCsvRow{vsCsvHeaders == "patient_date_of_birth"};
                            dtDateOfFirstSRS = oPatient.GetFirstBrainRadiationTherapyDate();
                            
                            dAgeAtTimeOfTreatment_months = calmonths(between(dtDateOfBirth, dtDateOfFirstSRS)); % use double calmonths to round off the number of days
                            
                            
                            % survival_time_months
                            dtDateOfDeath = calendarDuration.empty;
                            
                            if ~ismissing(c1xCsvRow{vsCsvHeaders == "patient_date_of_death"})
                                dtDateOfDeath = c1xCsvRow{vsCsvHeaders == "patient_date_of_death"};
                            elseif ~ismissing(c1xCsvRow{vsCsvHeaders == "patient_last_interaction_date"})
                                dtDateOfDeath = c1xCsvRow{vsCsvHeaders == "patient_last_interaction_date"};
                            end
                            
                            dSurvivalTime_months = [];
                            
                            if ~isempty(dtDateOfDeath)
                                dSurvivalTime_months = calmonths(between(dtDateOfFirstSRS, dtDateOfDeath));
                            end
                                                        
                            % create SQL query
                            c1xREDCapValues = {
                                Sex.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "patient_sex"}).GetMySQLEnumValue()
                                dAgeAtTimeOfTreatment_months
                                DeceasedStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "patient_deceased"}).GetMySQLEnumValue()
                                dSurvivalTime_months
                                c1xCsvRow{vsCsvHeaders == "patient_notes"}
                                };
                        else
                            c1xREDCapValues = {
                                string.empty
                                []
                                string.empty
                                []
                                string.empty
                                };
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "patient_information_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "patient_information"];
                        end
                        
                        sQuery = MySQLDatabase.SyncValuesToMySQL("patients", dPatientId, vsMysqlColumnNames, c1xREDCapValues, "WHERE patient_study_id = " + string(dPatientId));
                        vsQueries = [vsQueries; sQuery];
                            
                        
                        % process "brain_radiology_preresection" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: radiology_assessments
                            sTableName = "radiology_assessments";
                            d_id_radiology_assessments = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_radiology_assessments_patient_study_id", "type"],...
                                {dPatientId, RadiologyAssessmentType.PreResection.GetMySQLEnumValue()}));
                            
                            vsMysqlColumnNames = ["fk_radiology_assessments_patient_study_id", "scan_date", "type", "data_collection_notes"];
                            c1xREDCapValues = {...
                                dPatientId
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_date"}
                                RadiologyAssessmentType.PreResection.GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_notes"}};
                            
                            [sQuery,d_id_radiology_assessments] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_radiology_assessments, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_radiology_assessments_used(vd_ids_radiology_assessments == d_id_radiology_assessments) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: size_measurements
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "size_measurements";
                                d_id_size_measurements = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number",...
                                    "rano_bm_measurement_mm", "anterior_posterior_diameter_mm", "mediolateral_diameter_mm", "craniocaudal_diameter_mm"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_rano_bm_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_anterior_posterior_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_mediolateral_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_craniocaudal_measurement_mm"}};
                                
                                [sQuery,d_id_size_measurements] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_size_measurements, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_size_measurements_used(vd_ids_size_measurements == d_id_size_measurements) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                            
                            % MySQL table: qualitative_measurements
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "qualitative_measurements";
                                d_id_qualitative_measurements = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_qualitative_measurements_id_radiology_assessments", "fk_qualitative_measurements_brain_metastases_patient_study_id", "fk_qualitative_measurements_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_qualitative_measurements_id_radiology_assessments", "fk_qualitative_measurements_brain_metastases_patient_study_id", "fk_qualitative_measurements_brain_metastasis_number",...
                                    "metastasis_is_parenchymal", "edema_present", "mass_effect_present", "appearance"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_parenchymal"}).GetMySQLValue()
                                    YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_edema"}).GetMySQLValue()
                                    YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_mass_effect"}).GetMySQLValue()
                                    BrainMetastasisAppearanceScore.GetEnumFromREDCapEnumValues(c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_appearance"}, c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_bm" + string(dBMNumber) + "_rim_enhancement_type"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_qualitative_measurements] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_qualitative_measurements, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_qualitative_measurements_used(vd_ids_qualitative_measurements == d_id_qualitative_measurements) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_preresection_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "brain_radiology_preresection"];
                        end
                        
                        % process "brain_radiology_pretreatment" (e.g. display name of "pre-radiation") REDCap form
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: radiology_assessments
                            sTableName = "radiology_assessments";
                            d_id_radiology_assessments = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_radiology_assessments_patient_study_id", "type"],...
                                {dPatientId, RadiologyAssessmentType.PreRadiation.GetMySQLEnumValue()}));
                            
                            vsMysqlColumnNames = ["fk_radiology_assessments_patient_study_id", "scan_date", "type", "data_collection_notes"];
                            c1xREDCapValues = {...
                                dPatientId
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_date"}
                                RadiologyAssessmentType.PreRadiation.GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_notes"}};
                            
                            [sQuery,d_id_radiology_assessments] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_radiology_assessments, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_radiology_assessments_used(vd_ids_radiology_assessments == d_id_radiology_assessments) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: size_measurements
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "size_measurements";
                                d_id_size_measurements = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number",...
                                    "rano_bm_measurement_mm", "anterior_posterior_diameter_mm", "mediolateral_diameter_mm", "craniocaudal_diameter_mm"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_rano_bm_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_anterior_posterior_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_mediolateral_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_craniocaudal_measurement_mm"}};
                                
                                [sQuery,d_id_size_measurements] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_size_measurements, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_size_measurements_used(vd_ids_size_measurements == d_id_size_measurements) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                            
                            % MySQL table: qualitative_measurements
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "qualitative_measurements";
                                d_id_qualitative_measurements = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_qualitative_measurements_id_radiology_assessments", "fk_qualitative_measurements_brain_metastases_patient_study_id", "fk_qualitative_measurements_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_qualitative_measurements_id_radiology_assessments", "fk_qualitative_measurements_brain_metastases_patient_study_id", "fk_qualitative_measurements_brain_metastasis_number",...
                                    "metastasis_is_parenchymal", "surgical_cavity_present", "edema_present", "mass_effect_present", "appearance"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_parenchymal"}).GetMySQLValue()
                                    YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_surgical_cavity"}).GetMySQLValue()
                                    YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_edema"}).GetMySQLValue()
                                    YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_mass_effect"}).GetMySQLValue()
                                    BrainMetastasisAppearanceScore.GetEnumFromREDCapEnumValues(c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_appearance"}, c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_bm" + string(dBMNumber) + "_rim_enhancement_type"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_qualitative_measurements] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_qualitative_measurements, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_qualitative_measurements_used(vd_ids_qualitative_measurements == d_id_qualitative_measurements) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_pretreatment_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "brain_radiology_pretreatment"];
                        end
                        
                        % process "brain_radiology_followup_2_years" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_2_years_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: radiology_assessments
                            sTableName = "radiology_assessments";
                            d_id_radiology_assessments = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_radiology_assessments_patient_study_id", "type"],...
                                {dPatientId, RadiologyAssessmentType.Post2YearFollowUp.GetMySQLEnumValue()}));
                            
                            vsMysqlColumnNames = ["fk_radiology_assessments_patient_study_id", "scan_date", "type", "data_collection_notes"];
                            c1xREDCapValues = {...
                                dPatientId
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_last_followup_date"}
                                RadiologyAssessmentType.Post2YearFollowUp.GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_last_followup_notes"}};
                            
                            [sQuery,d_id_radiology_assessments] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_radiology_assessments, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_radiology_assessments_used(vd_ids_radiology_assessments == d_id_radiology_assessments) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: size_measurements
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "size_measurements";
                                d_id_size_measurements = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number",...
                                    "rano_bm_measurement_mm", "anterior_posterior_diameter_mm", "mediolateral_diameter_mm", "craniocaudal_diameter_mm"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_last_followup_bm" + string(dBMNumber) + "_rano_bm_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_last_followup_bm" + string(dBMNumber) + "_anterior_posterior_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_last_followup_bm" + string(dBMNumber) + "_mediolateral_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_last_followup_bm" + string(dBMNumber) + "_craniocaudal_measurement_mm"}};
                                
                                [sQuery,d_id_size_measurements] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_size_measurements, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_size_measurements_used(vd_ids_size_measurements == d_id_size_measurements) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                            
                            % MySQL table: pseudo_progression_scores
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "pseudo_progression_scores";
                                d_id_pseudo_progression_scores = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_pseudo_progression_scores_id_radiology_assessments", "fk_pseudo_progression_scores_brain_metastases_patient_study_id", "fk_pseudo_progression_scores_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_pseudo_progression_scores_id_radiology_assessments", "fk_pseudo_progression_scores_brain_metastases_patient_study_id", "fk_pseudo_progression_scores_brain_metastasis_number",...
                                    "pseudo_progression_score"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    PseudoProgressionScore.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_last_followup_bm" + string(dBMNumber) + "_pseudo_progression"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_pseudo_progression_scores] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_pseudo_progression_scores, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_pseudo_progression_scores_used(vd_ids_pseudo_progression_scores == d_id_pseudo_progression_scores) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_2_years_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "brain_radiology_followup_2_years"];
                        end
                        
                        % process "brain_radiology_pseudoprogression_conclusion" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_pseudoprogression_conclusion_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: pseudo_progression_conclusions
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "pseudo_progression_conclusions";
                                d_id_pseudo_progression_conclusions = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_pseudo_prog_conclusions_brain_metastases_patient_study_id", "fk_pseudo_prog_conclusions_brain_metastasis_number"],...
                                    {dPatientId, dBMNumber}));
                                
                                if ismissing(c1xCsvRow{vsCsvHeaders == "brain_radiology_conclusion_bm" + string(dBMNumber) + "_pseudo_progression_is_radiation_necrosis"})
                                    sIsRadionecrosis = [];
                                else
                                    sIsRadionecrosis = PsuedoProgressionSubTypeStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_conclusion_bm" + string(dBMNumber) + "_pseudo_progression_is_radiation_necrosis"}).GetMySQLEnumValue();
                                end
                                
                                if ismissing(c1xCsvRow{vsCsvHeaders == "brain_radiology_conclusion_bm" + string(dBMNumber) + "_pseudo_progression_is_are"})
                                    sIsAdverseRadiationEffect = [];
                                else
                                    sIsAdverseRadiationEffect = PsuedoProgressionSubTypeStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_conclusion_bm" + string(dBMNumber) + "_pseudo_progression_is_are"}).GetMySQLEnumValue();
                                end
                                
                                
                                vsMysqlColumnNames = [...
                                    "fk_pseudo_prog_conclusions_brain_metastases_patient_study_id", "fk_pseudo_prog_conclusions_brain_metastasis_number",...
                                    "pseudo_progression_confirmed", "is_radiation_necrosis", "is_adverse_radiation_effect", "confirmation_method", "data_collection_notes"];
                                c1xREDCapValues = {...
                                    dPatientId
                                    dBMNumber
                                    PseudoProgressionConfirmationStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_conclusion_bm" + string(dBMNumber) + "_pseudo_progression_confirmed"}).GetMySQLEnumValue()
                                    sIsRadionecrosis
                                    sIsAdverseRadiationEffect                                    
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_conclusion_bm" + string(dBMNumber) + "_pseudo_progression_confirmation_method"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_conclusion_notes"}}; % realize this will be repeated for all BMs, but doing it this way allows one less table to be mananged
                                
                                [sQuery,d_id_pseudo_progression_conclusions] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_pseudo_progression_conclusions, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_pseudo_progression_conclusions_used(vd_ids_pseudo_progression_conclusions == d_id_pseudo_progression_conclusions) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_pseudoprogression_conclusion_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "brain_radiology_pseudoprogression_conclusion"];
                        end
                        
                    else % working with single repeating instrument instance in one row
                        dRepeatInstance = c1xCsvRow{vsCsvHeaders == "redcap_repeat_instance"};
                        
                        % process "primary_cancer_histopathology" REDCap form
                        % (display name for "primary_cancer_information" form)
                        if c1xCsvRow{vsCsvHeaders == "primary_cancer_information_complete"} == REDCapConnection.sInformationCompleteCode
                            % find IDs in histopathology_reports and extracranial_histopathology_reports tables
                            vsColumns = "id_histopathology_reports, id_extracranial_histopathology_reports";
                            sJoinStatement = "histopathology_reports JOIN extracranial_histopathology_reports ON histopathology_reports.id_histopathology_reports = extracranial_histopathology_reports.fk_extracranial_histopath_reports_id_histopathology_reports";
                            sWhereStatement = "WHERE histopathology_reports.fk_histopathology_reports_patient_study_id = " + string(dPatientId) + " AND extracranial_histopathology_reports.redcap_repeat_instance = " + string(dRepeatInstance);
                            
                            tJoinStatementOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoinStatement, vsColumns, sWhereStatement);
                            
                            if isempty(tJoinStatementOutput)
                                d_id_extracranial_histopathology_reports = [];
                                d_id_histopathology_reports = [];
                            elseif size(tJoinStatementOutput,1) == 1
                                d_id_extracranial_histopathology_reports = tJoinStatementOutput.id_extracranial_histopathology_reports{1};
                                d_id_histopathology_reports = tJoinStatementOutput.id_histopathology_reports{1};
                            else
                                error('Not unique join result');
                            end
                            
                            % MySQL table: histopathology_reports
                            sTableName = "histopathology_reports";
                            
                            vsMysqlColumnNames = ["fk_histopathology_reports_patient_study_id", "date", "primary_cancer", "differentiation", "data_collection_notes"];
                            
                            ePrimaryCancerSite = PrimaryCancerSite.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_site"});
                            
                            c1xREDCapValues = {...
                                dPatientId
                                c1xCsvRow{vsCsvHeaders == "primary_cancer_histopathology_date"}
                                ePrimaryCancerSite.GetMySQLEnumValue()
                                HistopathologyDifferentiation.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_histopathology_differentiation"}).GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "primary_cancer_notes"}};
                            
                            if ePrimaryCancerSite == PrimaryCancerSite.Lung
                                vsMysqlColumnNames(end+1) = "lung_cancer_type";
                                c1xREDCapValues{end+1} = HistopathologyType.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_lung_histopathology_type"}).GetMySQLEnumValue();
                            else
                                vsMysqlColumnNames = [vsMysqlColumnNames, "non_lung_cancer_type"];
                                c1xREDCapValues{end+1} = HistopathologyType.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_non_lung_histopathology_type"}).GetMySQLEnumValue();
                            end
                            
                            [sQuery,d_id_histopathology_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_histopathology_reports, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_histopathology_reports_used(vd_ids_histopathology_reports == d_id_histopathology_reports) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: extracranial_histopathology_reports
                            sTableName = "extracranial_histopathology_reports";
                            
                            vsMysqlColumnNames = ["fk_extracranial_histopath_reports_id_histopathology_reports", "redcap_repeat_instance", "source"];
                            c1xREDCapValues = {...
                                d_id_histopathology_reports
                                dRepeatInstance
                                ExtracranialHistopathologySource.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_histopathology_source"}).GetMySQLEnumValue()};
                            
                            [sQuery,d_id_extracranial_histopathology_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_extracranial_histopathology_reports, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_extracranial_histopathology_reports_used(vd_ids_extracranial_histopathology_reports == d_id_extracranial_histopathology_reports) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: lung_cancer_receptor_reports
                            if ePrimaryCancerSite == PrimaryCancerSite.Lung
                                sTableName = "lung_cancer_receptor_reports";
                                d_id_lung_cancer_receptor_reports = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_lung_cancer_receptor_reports_id_histopathology_reports"],...
                                    {d_id_histopathology_reports}));
                                
                                vsMysqlColumnNames = ["fk_lung_cancer_receptor_reports_id_histopathology_reports", "pd_l1_status", "alk_status", "egfr_status", "ros1_status", "braf_status", "kras_status"];
                                c1xREDCapValues = {...
                                    d_id_histopathology_reports
                                    PDL1Status.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_lung_pd_l1"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_lung_alk"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_lung_egfr"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_lung_ros1"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_lung_braf"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_lung_kras"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_lung_cancer_receptor_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_lung_cancer_receptor_reports, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_lung_cancer_receptor_reports_used(vd_ids_lung_cancer_receptor_reports == d_id_lung_cancer_receptor_reports) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                            
                            % MySQL table: breast_cancer_receptor_reports
                            if ePrimaryCancerSite == PrimaryCancerSite.Breast
                                sTableName = "breast_cancer_receptor_reports";
                                d_id_breast_cancer_receptor_reports = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_breast_cancer_receptor_reports_id_histopathology_reports"],...
                                    {d_id_histopathology_reports}));
                                
                                vsMysqlColumnNames = ["fk_breast_cancer_receptor_reports_id_histopathology_reports", "estrogen_status", "progesterone_status", "her2_neu_status"];
                                c1xREDCapValues = {...
                                    d_id_histopathology_reports
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_breast_estrogen"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_breast_progesterone"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "primary_cancer_breast_her2_neu"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_breast_cancer_receptor_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_breast_cancer_receptor_reports, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_breast_cancer_receptor_reports_used(vd_ids_breast_cancer_receptor_reports == d_id_breast_cancer_receptor_reports) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "primary_cancer_information_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "primary_cancer_information"];
                        end
                        
                        % process "brain_metastasis_histopathology" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_complete"} == REDCapConnection.sInformationCompleteCode
                            % find IDs in histopathology_reports and extracranial_histopathology_reports tables
                            vsColumns = "id_histopathology_reports, id_brain_metastasis_histopathology_reports";
                            sJoinStatement = "histopathology_reports JOIN brain_metastasis_histopathology_reports ON histopathology_reports.id_histopathology_reports = brain_metastasis_histopathology_reports.fk_bm_histopathology_reports_id_histopathology_reports";
                            sWhereStatement = "WHERE histopathology_reports.fk_histopathology_reports_patient_study_id=" + string(dPatientId) + " AND brain_metastasis_histopathology_reports.redcap_repeat_instance=" + string(dRepeatInstance);
                            
                            tJoinStatementOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoinStatement, vsColumns, sWhereStatement);
                            
                            if isempty(tJoinStatementOutput)
                                d_id_brain_metastasis_histopathology_reports = [];
                                d_id_histopathology_reports = [];
                            elseif size(tJoinStatementOutput,1) == 1
                                d_id_brain_metastasis_histopathology_reports = tJoinStatementOutput.id_brain_metastasis_histopathology_reports{1};
                                d_id_histopathology_reports = tJoinStatementOutput.id_histopathology_reports{1};
                            else
                                error('Not unique join result');
                            end
                            
                            % MySQL table: histopathology_reports
                            sTableName = "histopathology_reports";
                            
                            vsMysqlColumnNames = ["fk_histopathology_reports_patient_study_id", "date", "primary_cancer", "differentiation", "data_collection_notes"];
                            
                            ePrimaryCancerSite = PrimaryCancerSite.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_primary_cancer_site"});
                            
                            if ~ismissing(string(c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_differentiation"}))
                                sDifferentiation = HistopathologyDifferentiation.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_differentiation"}).GetMySQLEnumValue();
                            else
                                sDifferentiation = string.empty;
                            end
                            
                            c1xREDCapValues = {...
                                dPatientId
                                c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_date"}
                                ePrimaryCancerSite.GetMySQLEnumValue()
                                sDifferentiation
                                c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_notes"}};
                            
                            if ePrimaryCancerSite == PrimaryCancerSite.Lung
                                vsMysqlColumnNames(end+1) = "lung_cancer_type";
                                
                                if ~ismissing(string(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_histopathology_type_v2"}))
                                    c1xREDCapValues{end+1} = HistopathologyType.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_histopathology_type_v2"}).GetMySQLEnumValue();
                                else
                                    c1xREDCapValues{end+1} = [];
                                end
                            else
                                vsMysqlColumnNames = [vsMysqlColumnNames, "non_lung_cancer_type"];
                                
                                if ~ismissing(string(c1xCsvRow{vsCsvHeaders == "brain_metastasis_non_lung_histopathology_type"}))
                                    c1xREDCapValues{end+1} = HistopathologyType.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_non_lung_histopathology_type"}).GetMySQLEnumValue();
                                else
                                    c1xREDCapValues{end+1} = [];
                                end
                            end
                            
                            [sQuery,d_id_histopathology_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_histopathology_reports, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_histopathology_reports_used(vd_ids_histopathology_reports == d_id_histopathology_reports) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: brain_metastasis_histopathology_reports
                            sTableName = "brain_metastasis_histopathology_reports";
                            
                            vsMysqlColumnNames = ["fk_bm_histopathology_reports_id_histopathology_reports", "redcap_repeat_instance", "malignancy_present", "necrosis_present", "sampled_brain_metastasis_number"];
                            c1xREDCapValues = {...
                                d_id_histopathology_reports
                                dRepeatInstance
                                YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_malignancy_present"}).GetMySQLValue()
                                YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_necrosis_present"}).GetMySQLValue()
                                c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_bm_number"}};
                            
                            [sQuery,d_id_brain_metastasis_histopathology_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_brain_metastasis_histopathology_reports, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_brain_metastasis_histopathology_reports_used(vd_ids_brain_metastasis_histopathology_reports == d_id_brain_metastasis_histopathology_reports) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: lung_cancer_receptor_reports
                            if ePrimaryCancerSite == PrimaryCancerSite.Lung && YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_malignancy_present"}) == YesNo.Yes
                                sTableName = "lung_cancer_receptor_reports";
                                d_id_lung_cancer_receptor_reports = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_lung_cancer_receptor_reports_id_histopathology_reports"],...
                                    {d_id_histopathology_reports}));
                                
                                vsMysqlColumnNames = ["fk_lung_cancer_receptor_reports_id_histopathology_reports", "pd_l1_status", "alk_status", "egfr_status", "ros1_status", "braf_status", "kras_status"];
                                c1xREDCapValues = {...
                                    d_id_histopathology_reports
                                    PDL1Status.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_pd_l1_v2"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_alk_v2"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_egfr_v2"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_ros1_v2"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_braf_v2"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_lung_kras_v2"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_lung_cancer_receptor_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_lung_cancer_receptor_reports, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_lung_cancer_receptor_reports_used(vd_ids_lung_cancer_receptor_reports == d_id_lung_cancer_receptor_reports) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                            
                            % MySQL table: breast_cancer_receptor_reports
                            if ePrimaryCancerSite == PrimaryCancerSite.Breast && YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_malignancy_present"}) == YesNo.Yes
                                sTableName = "breast_cancer_receptor_reports";
                                d_id_breast_cancer_receptor_reports = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_breast_cancer_receptor_reports_id_histopathology_reports"],...
                                    {d_id_histopathology_reports}));
                                
                                vsMysqlColumnNames = ["fk_breast_cancer_receptor_reports_id_histopathology_reports", "estrogen_status", "progesterone_status", "her2_neu_status"];
                                c1xREDCapValues = {...
                                    d_id_histopathology_reports
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_breast_estrogen_v2"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_breast_progesterone_v2"}).GetMySQLEnumValue()
                                    BiomarkerStatus.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_metastasis_breast_her2_neu_v2"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_breast_cancer_receptor_reports] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_breast_cancer_receptor_reports, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_breast_cancer_receptor_reports_used(vd_ids_breast_cancer_receptor_reports == d_id_breast_cancer_receptor_reports) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "brain_metastasis_histopathology_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "brain_metastasis_histopathology"];
                        end
                        
                        % process "systemic_therapy" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "systemic_therapy_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: systemic_therapies
                            sTableName = "systemic_therapies";
                            d_id_systemic_therapies = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_systemic_therapies_patient_study_id", "redcap_repeat_instance"],...
                                {dPatientId, dRepeatInstance}));
                            
                            vsMysqlColumnNames = ["fk_systemic_therapies_patient_study_id", "redcap_repeat_instance", "type", "type_other", "was_radiosensitizer", "start_date", "therapy_agent", "data_collection_notes"];
                            c1xREDCapValues = {...
                                dPatientId
                                dRepeatInstance
                                SystemicTherapyType.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "systemic_therapy_type"}).GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "systemic_therapy_type_other"}
                                YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "systemic_therapy_was_radiosensitizer"}).GetMySQLValue();
                                c1xCsvRow{vsCsvHeaders == "systemic_therapy_start_date"}
                                c1xCsvRow{vsCsvHeaders == "systemic_therapy_agent"}
                                c1xCsvRow{vsCsvHeaders == "systemic_therapy_notes"}};
                            
                            [sQuery,d_id_systemic_therapies] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_systemic_therapies, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_systemic_therapies_used(vd_ids_systemic_therapies == d_id_systemic_therapies) = true;
                            vsQueries = [vsQueries; sQuery];
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "systemic_therapy_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "systemic_therapy"];
                        end
                        
                        % process "salvage_treatment" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "salvage_treatment_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: salvage_treatments
                            sTableName = "salvage_treatments";
                            d_id_salvage_treatments = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_salvage_treatments_patient_study_id", "redcap_repeat_instance"],...
                                {dPatientId, dRepeatInstance}));
                            
                            vsMysqlColumnNames = ["fk_salvage_treatments_patient_study_id", "redcap_repeat_instance", "treatment_date", "type", "type_other", "new_metastases_targeted", "data_collection_notes"];
                            c1xREDCapValues = {...
                                dPatientId
                                dRepeatInstance
                                c1xCsvRow{vsCsvHeaders == "salvage_treatment_date"}
                                SalvageTreatmentType.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "salvage_treatment_type"}).GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "salvage_treatment_type_other"}
                                YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "salvage_treatment_new_bms_targeted"}).GetMySQLValue()
                                c1xCsvRow{vsCsvHeaders == "salvage_treatment_notes"}};
                            
                            [sQuery, d_id_salvage_treatments] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_salvage_treatments, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_salvage_treatments_used(vd_ids_salvage_treatments == d_id_salvage_treatments) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: salvage_treatments_has_brain_metastases
                            sTableName = "salvage_treatments_has_brain_metastases";
                            
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                eBMTargeted = YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "salvage_treatment_bm" + string(dBMNumber) + "_targeted"});
                                
                                if eBMTargeted == YesNo.Yes
                                    sWhereQuery = "WHERE " + ...
                                        "fk_st_has_bms_id_salvage_treatments = " + string(d_id_salvage_treatments) + " AND " + ...
                                        "fk_st_has_bms_brain_metastases_patient_study_id = " + string(dPatientId) + " AND " + ...
                                        "fk_st_has_bms_brain_metastases_brain_metastasis_number = " + string(dBMNumber);
                                    
                                    tLookup = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTableName, [], sWhereQuery);
                                    
                                    if isempty(tLookup)
                                        SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), sTableName, ...
                                            ["fk_st_has_bms_id_salvage_treatments" "fk_st_has_bms_brain_metastases_patient_study_id" "fk_st_has_bms_brain_metastases_brain_metastasis_number"],...
                                            {d_id_salvage_treatments, dPatientId, dBMNumber});
                                    end
                                    
                                    vb_salvage_treatments_has_brain_metastases_used(vd_fk_st_has_bms_id_salvage_treatments == d_id_salvage_treatments & vd_fk_st_has_bms_brain_metastases_patient_study_id == dPatientId & vd_fk_st_has_bms_brain_metastases_brain_metastasis_number == dBMNumber) = true;
                                end
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "salvage_treatment_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "salvage_treatment"];
                        end
                        
                        % process "radionecrosis_treatment" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: radionecrosis_treatment
                            sTableName = "radionecrosis_treatments";
                            d_id_radionecrosis_treatments = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_radionecrosis_treatments_patient_study_id", "redcap_repeat_instance"],...
                                {dPatientId, dRepeatInstance}));
                            
                            vsMysqlColumnNames = ["fk_radionecrosis_treatments_patient_study_id", "redcap_repeat_instance", "treatment_date", "type", "type_other", "new_metastases_targeted", "data_collection_notes"];
                            c1xREDCapValues = {...
                                dPatientId
                                dRepeatInstance
                                c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_date"}
                                RadionecrosisTreatmentType.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_type"}).GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_type_other"}
                                YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_new_bms_targeted"}).GetMySQLValue()
                                c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_notes"}};
                            
                            [sQuery, d_id_radionecrosis_treatments] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_radionecrosis_treatments, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_radionecrosis_treatments_used(vd_ids_radionecrosis_treatments == d_id_radionecrosis_treatments) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: radionecrosis_treatments_has_brain_metastases
                            sTableName = "radionecrosis_treatments_has_brain_metastases";
                            
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                eBMTargeted = YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_bm" + string(dBMNumber) + "_targeted"});
                                
                                if eBMTargeted == YesNo.Yes
                                    sWhereQuery = "WHERE " + ...
                                        "fk_rt_has_bms_id_radionecrosis_treatments = " + string(d_id_radionecrosis_treatments) + " AND " + ...
                                        "fk_rt_has_bms_brain_metastases_patient_study_id = " + string(dPatientId) + " AND " + ...
                                        "fk_rt_has_bms_brain_metastases_brain_metastasis_number = " + string(dBMNumber);
                                    
                                    tLookup = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTableName, [], sWhereQuery);
                                    
                                    if isempty(tLookup)
                                        SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), sTableName, ...
                                            ["fk_rt_has_bms_id_radionecrosis_treatments" "fk_rt_has_bms_brain_metastases_patient_study_id" "fk_rt_has_bms_brain_metastases_brain_metastasis_number"],...
                                            {d_id_radionecrosis_treatments, dPatientId, dBMNumber});
                                    end
                                    
                                    vb_radionecrosis_treatments_has_brain_metastases_used(vd_fk_rt_has_bms_id_radionecrosis_treatments == d_id_radionecrosis_treatments & vd_fk_rt_has_bms_brain_metastases_patient_study_id == dPatientId & vd_fk_rt_has_bms_brain_metastases_brain_metastasis_number == dBMNumber) = true;
                                end
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "radionecrosis_treatment_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "radionecrosis_treatment"];
                        end
                        
                        % process "brain_radiology_followup" REDCap form
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_complete"} == REDCapConnection.sInformationCompleteCode
                            % MySQL table: radiology_assessments
                            sTableName = "radiology_assessments";
                            d_id_radiology_assessments = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_radiology_assessments_patient_study_id", "redcap_repeat_instance", "type"],...
                                {dPatientId, dRepeatInstance, RadiologyAssessmentType.FollowUp.GetMySQLEnumValue()}));
                            
                            vsMysqlColumnNames = ["fk_radiology_assessments_patient_study_id", "redcap_repeat_instance", "scan_date", "type", "data_collection_notes"];
                            c1xREDCapValues = {...
                                dPatientId
                                dRepeatInstance
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_date"}
                                RadiologyAssessmentType.FollowUp.GetMySQLEnumValue()
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_notes"}};
                            
                            [sQuery,d_id_radiology_assessments] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_radiology_assessments, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_radiology_assessments_used(vd_ids_radiology_assessments == d_id_radiology_assessments) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: new_metastases_counts
                            sTableName = "new_metastases_counts";
                            d_id_new_metastases_counts = REDCapConnection.GetIdForDataInTable(sTableName,...
                                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                ["fk_new_metastases_counts_id_radiology_assessments"],...
                                {d_id_radiology_assessments}));
                            
                            vsMysqlColumnNames = ["fk_new_metastases_counts_id_radiology_assessments", "number_new_metastases_countable", "number_new_metastases", "number_suspected_new_metastases_countable", "number_suspected_new_metastases", "metastases_present_missed_in_previous_followup"];
                            c1xREDCapValues = {...
                                d_id_radiology_assessments
                                CountableUncountable.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_number_of_new_bms_countable"}).GetMySQLValue()
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_number_new_bms"}
                                CountableUncountable.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_number_of_suspected_new_bms_countable"}).GetMySQLValue()
                                c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_number_suspected_new_bms"}
                                YesNo.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_bms_present_missed_in_previous_followup"}).GetMySQLValue()};
                            
                            [sQuery,d_id_new_metastases_counts] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_new_metastases_counts, vsMysqlColumnNames, c1xREDCapValues);
                            vb_ids_new_metastases_counts_used(vd_ids_new_metastases_counts == d_id_new_metastases_counts) = true;
                            vsQueries = [vsQueries; sQuery];
                            
                            % MySQL table: size_measurements
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "size_measurements";
                                d_id_size_measurements = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_size_measurements_id_radiology_assessments", "fk_size_measurements_brain_metastases_patient_study_id", "fk_size_measurements_brain_metastasis_number",...
                                    "rano_bm_measurement_mm", "anterior_posterior_diameter_mm", "mediolateral_diameter_mm", "craniocaudal_diameter_mm"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_bm" + string(dBMNumber) + "_rano_bm_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_bm" + string(dBMNumber) + "_anterior_posterior_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_bm" + string(dBMNumber) + "_mediolateral_measurement_mm"}
                                    c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_bm" + string(dBMNumber) + "_craniocaudal_measurement_mm"}};
                                
                                [sQuery,d_id_size_measurements] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_size_measurements, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_size_measurements_used(vd_ids_size_measurements == d_id_size_measurements) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                            
                            % MySQL table: pseudo_progression_scores
                            for dBMNumber=1:oPatient.GetNumberOfBrainMetastases()
                                sTableName = "pseudo_progression_scores";
                                d_id_pseudo_progression_scores = REDCapConnection.GetIdForDataInTable(sTableName,...
                                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                                    ["fk_pseudo_progression_scores_id_radiology_assessments", "fk_pseudo_progression_scores_brain_metastases_patient_study_id", "fk_pseudo_progression_scores_brain_metastasis_number"],...
                                    {d_id_radiology_assessments, dPatientId, dBMNumber}));
                                
                                vsMysqlColumnNames = [...
                                    "fk_pseudo_progression_scores_id_radiology_assessments", "fk_pseudo_progression_scores_brain_metastases_patient_study_id", "fk_pseudo_progression_scores_brain_metastasis_number",...
                                    "pseudo_progression_score"];
                                c1xREDCapValues = {...
                                    d_id_radiology_assessments
                                    dPatientId
                                    dBMNumber
                                    PseudoProgressionScore.GetEnumFromREDCapEnumValue(c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_bm" + string(dBMNumber) + "_pseudo_progression"}).GetMySQLEnumValue()};
                                
                                [sQuery,d_id_pseudo_progression_scores] = MySQLDatabase.SyncValuesToMySQL(sTableName, d_id_pseudo_progression_scores, vsMysqlColumnNames, c1xREDCapValues);
                                vb_ids_pseudo_progression_scores_used(vd_ids_pseudo_progression_scores == d_id_pseudo_progression_scores) = true;
                                vsQueries = [vsQueries; sQuery];
                            end
                        end
                        
                        if c1xCsvRow{vsCsvHeaders == "brain_radiology_followup_complete"} == REDCapConnection.sInformationIncompleteCode
                            vdIncompleteRowIndices = [vdIncompleteRowIndices; dRowIndex];
                            vdIncompletePatientIds = [vdIncompletePatientIds; dPatientId];
                            vsIncompleteFormName = [vsIncompleteFormName; "brain_radiology_followup"];
                        end
                    end
                    
                catch e
                    warning("Error on row " + string(dRowIndex) + " for patient ID " + string(dPatientId));
                    rethrow(e);
                end
            end
            
            % consolidate incomplete rows
            stIncompleteForms = struct(...
                'vdIncompleteRowIndices', vdIncompleteRowIndices,...
                'vdIncompletePatientIds', vdIncompletePatientIds,...
                'vsIncompleteFormName', vsIncompleteFormName);
            
            
            % check that no rows have to be deleted
            
            % - delete from histopathology_reports
            % -- will auto-propogate to:
            % --- brain_metastasis_histopathology_reports
            % --- extracranial_histopathology_reports
            % -- may or may not auto-propogate to (e.g. if an update occurs changing cancer type from lung to liver, then the lung_cancer_receptor_report will remain, but should be deleted):
            % --- breast_cancer_receptor_reports
            % --- lung_cancer_receptor_reports            
            
            vd_ids_histopathology_reports = vd_ids_histopathology_reports(~vb_ids_histopathology_reports_used);
            
            if ~isempty(vd_ids_histopathology_reports)
                sTableName = "histopathology_reports";
                vsWhereStatementColumnNames = "id_histopathology_reports";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_histopathology_reports);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            vd_ids_lung_cancer_receptor_reports = vd_ids_lung_cancer_receptor_reports(~vb_ids_lung_cancer_receptor_reports_used);
            
            if ~isempty(vd_ids_lung_cancer_receptor_reports)
                sTableName = "lung_cancer_receptor_reports";
                vsWhereStatementColumnNames = "id_lung_cancer_receptor_reports";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_lung_cancer_receptor_reports);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            vd_ids_breast_cancer_receptor_reports = vd_ids_breast_cancer_receptor_reports(~vb_ids_breast_cancer_receptor_reports_used);
            
            if ~isempty(vd_ids_breast_cancer_receptor_reports)
                sTableName = "breast_cancer_receptor_reports";
                vsWhereStatementColumnNames = "id_breast_cancer_receptor_reports";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_breast_cancer_receptor_reports);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            
            % - delete from radiology_assessments
            % -- will auto-propogate:
            % --- new_metastases_counts
            % --- pseudo_progression_scores
            % --- qualitative_measurements
            % --- size_measurements
            
            vd_ids_radiology_assessments = vd_ids_radiology_assessments(~vb_ids_radiology_assessments_used);
            
            if ~isempty(vd_ids_radiology_assessments)
                sTableName = "radiology_assessments";
                vsWhereStatementColumnNames = "id_radiology_assessments";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_radiology_assessments);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            
            % - delete from pseudo_progression_conclusions
            
            vd_ids_pseudo_progression_conclusions = vd_ids_pseudo_progression_conclusions(~vb_ids_pseudo_progression_conclusions_used);
            
            if ~isempty(vd_ids_pseudo_progression_conclusions)
                sTableName = "pseudo_progression_conclusions";
                vsWhereStatementColumnNames = "id_pseudo_progression_conclusions";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_pseudo_progression_conclusions);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            
            % - delete from radionecrosis_treatments
            % -- may or may not to auto-propogate (e.g. if treatment type is changed from resection to something else):
            % --- radionecrosis_treatments_has_brain_metastases
            
            vd_ids_radionecrosis_treatments = vd_ids_radionecrosis_treatments(~vb_ids_radionecrosis_treatments_used);
            
            if ~isempty(vd_ids_radionecrosis_treatments)
                sTableName = "radionecrosis_treatments";
                vsWhereStatementColumnNames = "id_radionecrosis_treatments";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_radionecrosis_treatments);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            vd_fk_rt_has_bms_id_radionecrosis_treatments = vd_fk_rt_has_bms_id_radionecrosis_treatments(~vb_radionecrosis_treatments_has_brain_metastases_used);
            vd_fk_rt_has_bms_brain_metastases_patient_study_id = vd_fk_rt_has_bms_brain_metastases_patient_study_id(~vb_radionecrosis_treatments_has_brain_metastases_used);
            vd_fk_rt_has_bms_brain_metastases_brain_metastasis_number = vd_fk_rt_has_bms_brain_metastases_brain_metastasis_number(~vb_radionecrosis_treatments_has_brain_metastases_used);
            
            if ~isempty(vd_fk_rt_has_bms_id_radionecrosis_treatments)
                sTableName = "radionecrosis_treatments_has_brain_metastases";
                vsWhereStatementColumnNames = ["fk_rt_has_bms_id_radionecrosis_treatments", "fk_rt_has_bms_brain_metastases_patient_study_id", "fk_rt_has_bms_brain_metastases_brain_metastasis_number"];
                c2xWhereStatementValuesPerColumnPerRowToDelete = [...
                    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_fk_rt_has_bms_id_radionecrosis_treatments), ...
                    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_fk_rt_has_bms_brain_metastases_patient_study_id), ...
                    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_fk_rt_has_bms_brain_metastases_brain_metastasis_number)];               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            
            % - delete from salvage_treatments
            % -- may or may not auto-propogate (e.g. if treatment type changes):
            % --- salvage_treatments_has_brain_metastases
            
            vd_ids_salvage_treatments = vd_ids_salvage_treatments(~vb_ids_salvage_treatments_used);
            
            if ~isempty(vd_ids_salvage_treatments)
                sTableName = "salvage_treatments";
                vsWhereStatementColumnNames = "id_salvage_treatments";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_salvage_treatments);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            vd_fk_st_has_bms_id_salvage_treatments = vd_fk_st_has_bms_id_salvage_treatments(~vb_salvage_treatments_has_brain_metastases_used);
            vd_fk_st_has_bms_brain_metastases_patient_study_id = vd_fk_st_has_bms_brain_metastases_patient_study_id(~vb_salvage_treatments_has_brain_metastases_used);
            vd_fk_st_has_bms_brain_metastases_brain_metastasis_number = vd_fk_st_has_bms_brain_metastases_brain_metastasis_number(~vb_salvage_treatments_has_brain_metastases_used);
            
            if ~isempty(vd_fk_st_has_bms_id_salvage_treatments)
                sTableName = "salvage_treatments_has_brain_metastases";
                vsWhereStatementColumnNames = ["fk_st_has_bms_id_salvage_treatments", "fk_st_has_bms_brain_metastases_patient_study_id", "fk_st_has_bms_brain_metastases_brain_metastasis_number"];
                c2xWhereStatementValuesPerColumnPerRowToDelete = [...
                    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_fk_st_has_bms_id_salvage_treatments),...
                    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_fk_st_has_bms_brain_metastases_patient_study_id),...
                    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_fk_st_has_bms_brain_metastases_brain_metastasis_number)];               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            % - delete from systemic_therapies
            
            vd_ids_systemic_therapies = vd_ids_systemic_therapies(~vb_ids_systemic_therapies_used);
            
            if ~isempty(vd_ids_systemic_therapies)
                sTableName = "systemic_therapies";
                vsWhereStatementColumnNames = "id_systemic_therapies";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_systemic_therapies);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
        end
        
        function dID = GetIdForDataInTable(sTableName, sWhereQuery)
            arguments
                sTableName (1,1) string
                sWhereQuery (1,1) string
            end
            
            tValuesFromTable = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTableName, "id_" + sTableName, sWhereQuery);
            
            if isempty(tValuesFromTable)
                dID = [];
            elseif size(tValuesFromTable,1) == 1
                dID = tValuesFromTable.("id_" + sTableName){1};
            else
                error('Multiple values found, where query not uniquely identifyig');
            end
        end
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)
    end
end

