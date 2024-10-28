classdef OrthancConnection < handle
    %OrthancConnection
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = private)
    end
    
    properties (Constant = true, GetAccess = private)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
    end
    
    methods (Access = public, Static)
           
        function vstMetadataPerPatient = GetAllMetadata()            
            % setup http settings
            [sServerIpAndHttpPort, sHttpUsername, sHttpPassword] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('DicomServerHttpConfig'),...
                DicomImporter.DicomServerHttpConfigFileIPAndPortVarName,...
                DicomImporter.DicomServerHttpConfigFileUsernameVarName,...
                DicomImporter.DicomServerHttpConfigFilePasswordVarName);
            
            oWebOpts = weboptions('Username',sHttpUsername,'Password',sHttpPassword);
            
            % get patient UUIDs            
            vsPatientOrthancUUIDs = string(webread("http://" + sServerIpAndHttpPort + "/patients", oWebOpts));
            dNumPatients = length(vsPatientOrthancUUIDs);
            
            c1stMetadataPerPatient = cell(dNumPatients,1);
            
            % loop through patients
            for dPatientIndex=1:dNumPatients
                sPatientOrthancUUID = vsPatientOrthancUUIDs(dPatientIndex);
                
                stPatientMetadata = webread("http://" + sServerIpAndHttpPort + "/patients/" + sPatientOrthancUUID, oWebOpts);
                
                sPatientId = string(stPatientMetadata.MainDicomTags.PatientID);
                vsPatientIdSplit = strsplit(sPatientId);
                dPatientId = str2double(vsPatientIdSplit(end));
                
                % process studies
                vsStudyOrthancUUIDs = string(stPatientMetadata.Studies);
                dNumStudies = length(vsStudyOrthancUUIDs);
                
                c1stMetadataPerStudy = cell(1,dNumStudies);
                
                for dStudyIndex=1:dNumStudies
                    sStudyOrthancUUID = vsStudyOrthancUUIDs(dStudyIndex);
                    
                    stStudyMetadata = webread("http://" + sServerIpAndHttpPort + "/studies/" + sStudyOrthancUUID, oWebOpts);
                    
                    chTime = stStudyMetadata.MainDicomTags.StudyDate(1:6);
                    dtStudyDatetime = datetime([stStudyMetadata.MainDicomTags.StudyDate, 'T', chTime], 'InputFormat', 'yyyyMMdd''T''HHmmss');
                    
                    sStudyDescription = string(stStudyMetadata.MainDicomTags.StudyDescription);
                    sStudyId = string(stStudyMetadata.MainDicomTags.StudyID);
                    sStudyInstanceUID = string(stStudyMetadata.MainDicomTags.StudyInstanceUID);
                                        
                    % process series
                    vsSeriesOrthancUUIDs = string(stStudyMetadata.Series);
                    dNumSeries = length(vsSeriesOrthancUUIDs);
                    
                    c1stMetadataPerSeries = cell(1,dNumSeries);
                    
                    for dSeriesIndex=1:dNumSeries
                        sSeriesOrthancUUID = vsSeriesOrthancUUIDs(dSeriesIndex);
                        
                        stSeriesMetadata = webread("http://" + sServerIpAndHttpPort + "/series/" + sSeriesOrthancUUID, oWebOpts);
                        
                        if isfield(stSeriesMetadata.MainDicomTags, 'SeriesDate')
                            if isfield(stSeriesMetadata.MainDicomTags, 'SeriesTime')
                                chTime = stSeriesMetadata.MainDicomTags.SeriesTime(1:6);
                            else
                                chTime = '000000';
                            end
                            
                            dtSeriesDatetime = datetime([stSeriesMetadata.MainDicomTags.SeriesDate, 'T', chTime], 'InputFormat', 'yyyyMMdd''T''HHmmss');
                        else
                            dtSeriesDatetime = datetime.empty;
                        end
                        
                        sModality = string(stSeriesMetadata.MainDicomTags.Modality);
                        sSeriesDescription = string(stSeriesMetadata.MainDicomTags.SeriesDescription);
                        sSeriesInstanceUID = string(stSeriesMetadata.MainDicomTags.SeriesInstanceUID);
                        dNumInstances = length(stSeriesMetadata.Instances);
                        
                        c1stMetadataPerSeries{dSeriesIndex} = struct(...
                            'sSeriesOrthancUUID', sSeriesOrthancUUID,...
                            'dtSeriesDatetime', dtSeriesDatetime,...
                            'sModality', sModality,...
                            'sSeriesDescription', sSeriesDescription,...
                            'sSeriesInstanceUID', sSeriesInstanceUID,...
                            'dNumInstances', dNumInstances);
                    end
                    
                    vstMetadataPerSeries = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1stMetadataPerSeries);
                    
                    c1stMetadataPerStudy{dStudyIndex} = struct(...
                        'sStudyOrthancUUID', sStudyOrthancUUID,...
                        'dtStudyDatetime', dtStudyDatetime,...
                        'sStudyDescription', sStudyDescription,...
                        'sStudyId', sStudyId,...
                        'sStudyInstanceUID', sStudyInstanceUID,...
                        'vstMetadataPerSeries', vstMetadataPerSeries);
                end
                
                vstMetadataPerStudy = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1stMetadataPerStudy);
                
                c1stMetadataPerPatient{dPatientIndex} = struct(...
                    'dPatientId', dPatientId,...
                    'sPatientOrthancUUID', sPatientOrthancUUID,...
                    'vstMetadataPerStudy', vstMetadataPerStudy);
            end
            
            vstMetadataPerPatient = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1stMetadataPerPatient);
        end
        
        function vsQueries = UpdateMySQLFromOrthanc(vstMetadataPerPatient)
            arguments
                vstMetadataPerPatient struct = struct.empty
            end
            
            if isempty(vstMetadataPerPatient)
                disp('Downloading Orthanc metadata...');
                vstMetadataPerPatient = OrthancConnection.GetAllMetadata();
                disp('Orthanc metadata downloaded');
            end
                
            % Backup MySQL database to allow for complete rollback
            MySQLDatabase.Backup();
            
            % Record SQL queries
            vsQueries = string.empty;
            
            % track studies and series to see if any need to be deleted
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "patients", "patient_study_id");
            vd_ids_patients = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.patient_study_id);
            vb_ids_patients_used = false(size(vd_ids_patients));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "dicom_studies", "id_dicom_studies");
            vd_ids_dicom_studies = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_dicom_studies);
            vb_ids_dicom_studies_used = false(size(vd_ids_dicom_studies));
            
            tIds = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "dicom_series", "id_dicom_series");
            vd_ids_dicom_series = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tIds.id_dicom_series);
            vb_ids_dicom_series_used = false(size(vd_ids_dicom_series));
            
            % get patient UUIDs                        
            dNumPatients = length(vstMetadataPerPatient);
            
            % loop through patients
            for dPatientIndex=1:dNumPatients
                sPatientOrthancUUID = vstMetadataPerPatient(dPatientIndex).sPatientOrthancUUID;                                
                dPatientId = vstMetadataPerPatient(dPatientIndex).dPatientId;
                vb_ids_patients_used(vd_ids_patients == dPatientId) = true;
                
                % set Orthanc UUID to MySQL patients                
                vsColumnNames = "orthanc_pacs_uuid";
                c1xNewValues = {sPatientOrthancUUID};
                sWhereQuery = "WHERE patients.patient_study_id = " + string(dPatientId);
                
                sQuery = MySQLDatabase.SyncValuesToMySQL("patients", dPatientId, vsColumnNames, c1xNewValues, sWhereQuery);
                vsQueries = [vsQueries; sQuery];
                
                % process studies
                vstMetadataPerStudy = vstMetadataPerPatient(dPatientIndex).vstMetadataPerStudy;
                dNumStudies = length(vstMetadataPerStudy);
                
                for dStudyIndex=1:dNumStudies
                    sStudyOrthancUUID = vstMetadataPerStudy(dStudyIndex).sStudyOrthancUUID;
                    dtStudyDatetime = vstMetadataPerStudy(dStudyIndex).dtStudyDatetime;
                    sStudyDescription = vstMetadataPerStudy(dStudyIndex).sStudyDescription;
                    sStudyId = vstMetadataPerStudy(dStudyIndex).sStudyId;
                    sStudyInstanceUID = vstMetadataPerStudy(dStudyIndex).sStudyInstanceUID;
                    
                    % Set Orthanc values to MySQL imaging_studies
                    tIdOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "dicom_studies", "id_dicom_studies", "WHERE dicom_studies.dicom_instance_uid = '" + sStudyInstanceUID + "'");
                    
                    if isempty(tIdOutput)
                        d_id_dicom_studies = [];
                    else
                        d_id_dicom_studies = tIdOutput.id_dicom_studies{1};
                    end
                    
                    vsColumnNames = [...
                        "fk_dicom_studies_patient_study_id"
                        "dicom_id"
                        "dicom_instance_uid"
                        "dicom_datetime"
                        "dicom_description"
                        "orthanc_pacs_uuid"];
                    c1xNewValues = {
                        dPatientId
                        sStudyId
                        sStudyInstanceUID
                        dtStudyDatetime
                        sStudyDescription
                        sStudyOrthancUUID};
                    
                    [sQuery, d_id_dicom_studies] = MySQLDatabase.SyncValuesToMySQL("dicom_studies", d_id_dicom_studies, vsColumnNames, c1xNewValues);
                    vb_ids_dicom_studies_used(vd_ids_dicom_studies == d_id_dicom_studies) = true;
                    vsQueries = [vsQueries; sQuery];
                    
                    % process series
                    vsMetadataPerSeries = vstMetadataPerStudy(dStudyIndex).vstMetadataPerSeries;
                    dNumSeries = length(vsMetadataPerSeries);
                    
                    for dSeriesIndex=1:dNumSeries
                        sSeriesOrthancUUID = vsMetadataPerSeries(dSeriesIndex).sSeriesOrthancUUID;                        
                        dtSeriesDatetime = vsMetadataPerSeries(dSeriesIndex).dtSeriesDatetime;
                        sModality = vsMetadataPerSeries(dSeriesIndex).sModality;
                        sSeriesDescription = vsMetadataPerSeries(dSeriesIndex).sSeriesDescription;
                        sSeriesInstanceUID = vsMetadataPerSeries(dSeriesIndex).sSeriesInstanceUID;
                        dNumInstances = vsMetadataPerSeries(dSeriesIndex).dNumInstances;
                        
                        if sSeriesDescription == ""
                            sSeriesDescription = string.empty;
                        end
                        
                        % Set Orthanc values to MySQL imaging_series
                        tIdOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "dicom_series", "id_dicom_series", "WHERE dicom_series.dicom_instance_uid = '" + sSeriesInstanceUID + "'");
                        
                        if isempty(tIdOutput)
                            d_id_dicom_series = [];
                        else
                            d_id_dicom_series = tIdOutput.id_dicom_series{1};
                        end
                        
                        vsColumnNames = [...
                            "fk_dicom_series_id_dicom_studies"
                            "dicom_modality"
                            "dicom_instance_uid"
                            "dicom_description"
                            "dicom_datetime"
                            "orthanc_pacs_uuid"
                            "number_of_instances"
                            ];
                        c1xNewValues = {
                            d_id_dicom_studies
                            sModality
                            sSeriesInstanceUID
                            sSeriesDescription
                            dtSeriesDatetime
                            sSeriesOrthancUUID
                            dNumInstances};
                        
                        [sQuery, d_id_dicom_series] = MySQLDatabase.SyncValuesToMySQL("dicom_series", d_id_dicom_series, vsColumnNames, c1xNewValues);     
                        vb_ids_dicom_series_used(vd_ids_dicom_series == d_id_dicom_series) = true;                   
                        vsQueries = [vsQueries; sQuery];                        
                    end
                end
            end
            
            % clear values for un-used patients
            vd_ids_patients = vd_ids_patients(~vb_ids_patients_used);
            
            if ~isempty(vd_ids_patients)
                sTableName = "patients";
                
                for dPatientIndex=1:length(vd_ids_patients)
                    tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTableName, "orthanc_pacs_uuid", "WHERE patient_study_id = " + string(vd_ids_patients(dPatientIndex)));
                    
                    if ~isempty(tOutput.orthanc_pacs_uuid{1})
                        sQuery = SQLUtilities.UpdateDatabase(MySQLDatabase.GetConnection(), sTableName, "orthanc_pacs_uuid", {string.empty}, "WHERE patient_study_id = " + string(vd_ids_patients(dPatientIndex)));
                        vsQueries = [vsQueries; sQuery];
                    end
                end
            end
            
            % delete un-used rows
            vd_ids_dicom_studies = vd_ids_dicom_studies(~vb_ids_dicom_studies_used);
            
            if ~isempty(vd_ids_dicom_studies)
                sTableName = "dicom_studies";
                vsWhereStatementColumnNames = "id_dicom_studies";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_dicom_studies);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
            vd_ids_dicom_series = vd_ids_dicom_series(~vb_ids_dicom_series_used);
            
            if ~isempty(vd_ids_dicom_series)
                sTableName = "dicom_series";
                vsWhereStatementColumnNames = "id_dicom_series";
                c2xWhereStatementValuesPerColumnPerRowToDelete = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vd_ids_dicom_series);               
                
                vsDeleteQueries = MySQLDatabase.DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete);
                vsQueries = [vsQueries; vsDeleteQueries];
            end
            
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static)
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

