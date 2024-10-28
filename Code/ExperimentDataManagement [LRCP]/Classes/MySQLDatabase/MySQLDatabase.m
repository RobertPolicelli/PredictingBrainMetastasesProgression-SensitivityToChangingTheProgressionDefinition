classdef MySQLDatabase < handle
    %MySQLDatabase
    
    
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
        
        function Connect()
            [sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('MySQLConnectionSettings'),...
                'sMySQLDataSourceName', 'sMySQLServerUsername', 'sMySQLServerPassword');
            
            oSQLDB = database(sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword);
            oSQLDB.AutoCommit = 'off'; % so bad, why would this not be default
            
            global oDatabaseConnection;
            oDatabaseConnection = oSQLDB;
            
            disp('Successfully connected to database');
        end
        
        function oConnection = GetConnection()
            global oDatabaseConnection;
            
            if isempty(oDatabaseConnection) || ~oDatabaseConnection.isopen
                MySQLDatabase.Connect();
            end
            
            oConnection = oDatabaseConnection;
        end
        
        function CloseConnection()
            oConnection = MySQLDatabase.GetConnection();
            oConnection.close();
            
            global oDatabaseConnection;
            oDatabaseConnection = [];
        end
        
        function oPatient = GetPatientByStudyId(dStudyId)
            arguments
                dStudyId (1,1) double {mustBeInteger, mustBePositive}
            end
                        
            oPatient = Patient.LoadFromDatabase(dStudyId);
        end
        
        function vsSqlQueries = UpdateFromTreatmentPlanningSystems(sTreatmentPlanningSystemMetadataSpreadsheetFilepath)
            % Backup MySQL database to allow for complete rollback
            MySQLDatabase.Backup();
            
            % record queries
            vsSqlQueries = string.empty;
            
            % RayStation            
            c1xRawData = readcell(sTreatmentPlanningSystemMetadataSpreadsheetFilepath, 'Sheet', 'RayStation Plans');
            
            vsHeaders = string(c1xRawData(1,:));
            c2xTPSData = c1xRawData(2:end,:);
            
            eTPS = TreatmentPlanningSystem.RayStation;
            
            vdPatientIdPerPrescription = double(string(c2xTPSData(:,vsHeaders == "Study ID")));
            
            vsPlanNamePerPrescription = string(c2xTPSData(:,vsHeaders == "Plan Name"));
            vsBeamSetNamePerPrescription = string(c2xTPSData(:,vsHeaders == "Beam Set Name"));
            
            vdPrescribedDosePerPrescription_Gy = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xTPSData(:,vsHeaders == "Prescribed Dose (Gy)"));
            vdPrescribedFractionsPerPrescription = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xTPSData(:,vsHeaders == "Prescribed Number of Fractions"));
            
            c1vsGTVNamesPerPrescription = cell(size(c2xTPSData,1),1);
            
            for dRowIndex=1:size(c2xTPSData,1)
                 vsGTVNames = string(c2xTPSData(dRowIndex,contains(vsHeaders, "GTV")));
                 c1vsGTVNamesPerPrescription{dRowIndex} = vsGTVNames(~ismissing(vsGTVNames));
            end
            
            vsQueries = MySQLDatabase.UpdateWithTreatmentPlanningSystemData(vdPatientIdPerPrescription, vsPlanNamePerPrescription, vsBeamSetNamePerPrescription, [], vdPrescribedDosePerPrescription_Gy, vdPrescribedFractionsPerPrescription, c1vsGTVNamesPerPrescription, eTPS);
            vsSqlQueries = [vsSqlQueries; vsQueries];
            
            % Eclipse
            bNoEclipseSheet = false;
            
            try
                c1xRawData = readcell(sTreatmentPlanningSystemMetadataSpreadsheetFilepath, 'Sheet', 'Eclipse Plans');
            catch
                warning('No sheet named "Eclipse Plans" found.');
                bNoEclipseSheet = true;
            end
            
            if ~bNoEclipseSheet
                vsHeaders = string(c1xRawData(1,:));
                c2xTPSData = c1xRawData(2:end,:);
                
                eTPS = TreatmentPlanningSystem.Eclipse;
                
                vdPatientIdPerPrescription = double(string(c2xTPSData(:,vsHeaders == "Study ID")));
                
                vsPlanNamePerPrescription = string(c2xTPSData(:,vsHeaders == "Plan Name"));
                vsBeamSetNamePerPrescription = string(c2xTPSData(:,vsHeaders == "Plan Name"));
                
                vdPrescribedDosePerPrescription_Gy = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xTPSData(:,vsHeaders == "Prescribed Dose (Gy)"));
                vdPrescribedFractionsPerPrescription = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xTPSData(:,vsHeaders == "Prescribed Number of Fractions"));
                
                c1vsGTVNamesPerPrescription = cell(size(c2xTPSData,1),1);
                
                for dRowIndex=1:size(c2xTPSData,1)
                    vsGTVNames = string(c2xTPSData(dRowIndex,contains(vsHeaders, "GTV")));
                    c1vsGTVNamesPerPrescription{dRowIndex} = vsGTVNames(~ismissing(vsGTVNames));
                end
                
                vsQueries = MySQLDatabase.UpdateWithTreatmentPlanningSystemData(vdPatientIdPerPrescription, vsPlanNamePerPrescription, vsBeamSetNamePerPrescription, [], vdPrescribedDosePerPrescription_Gy, vdPrescribedFractionsPerPrescription, c1vsGTVNamesPerPrescription, eTPS);
                vsSqlQueries = [vsSqlQueries; vsQueries];
            end
            
            % Pinnacle
            c1xRawData = readcell(sTreatmentPlanningSystemMetadataSpreadsheetFilepath, 'Sheet', 'Pinnacle Plans');
            
            vsHeaders = string(c1xRawData(1,:));
            c2xTPSData = c1xRawData(2:end,:);
            
            eTPS = TreatmentPlanningSystem.Pinnacle;
            
            vdPatientIdPerPrescription = double(string(c2xTPSData(:,vsHeaders == "Study ID")));
            
            vsPlanNamePerPrescription = string(c2xTPSData(:,vsHeaders == "Plan Name"));
            vsBeamSetNamePerPrescription = string(c2xTPSData(:,vsHeaders == "Trial Name"));            
            vsPrescriptionNamePerPrescription = string(c2xTPSData(:,vsHeaders == "Prescription Name"));
            
            vdPrescribedDosePerPrescription_Gy = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xTPSData(:,vsHeaders == "Prescribed Dose (Gy)"));
            vdPrescribedFractionsPerPrescription = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xTPSData(:,vsHeaders == "Prescribed Number of Fractions"));
            
            c1vsGTVNamesPerPrescription = cell(size(c2xTPSData,1),1);
            
            for dRowIndex=1:size(c2xTPSData,1)
                 vsGTVNames = string(c2xTPSData(dRowIndex,contains(vsHeaders, "GTV")));
                 c1vsGTVNamesPerPrescription{dRowIndex} = vsGTVNames(~ismissing(vsGTVNames));
            end
            
            vsQueries = MySQLDatabase.UpdateWithTreatmentPlanningSystemData(vdPatientIdPerPrescription, vsPlanNamePerPrescription, vsBeamSetNamePerPrescription, vsPrescriptionNamePerPrescription, vdPrescribedDosePerPrescription_Gy, vdPrescribedFractionsPerPrescription, c1vsGTVNamesPerPrescription, eTPS);
            vsSqlQueries = [vsSqlQueries; vsQueries];
        end
        
        function vsAllQueries = UpdateFromImagingSeriesAssignments(sImagingSeriesAssignmentsFilepath)
            % Backup MySQL database to allow for complete rollback
            MySQLDatabase.Backup();
            
            % Record of all queries to be made
            vsAllQueries = string.empty;
            
            % *** T1w-CE ***
            vsQueries = MySQLDatabase.UpdateFromImagingSeriesAssignmentsSheet(sImagingSeriesAssignmentsFilepath, ImagingSeriesAssignmentType.T1wPostContrast);
            vsAllQueries = [vsAllQueries; vsQueries];
            
            % *** Planning CT ***
            vsQueries = MySQLDatabase.UpdateFromImagingSeriesAssignmentsSheet(sImagingSeriesAssignmentsFilepath, ImagingSeriesAssignmentType.PlanningCT);
            vsAllQueries = [vsAllQueries; vsQueries];
            
            % *** RT Struct ***
            vsQueries = MySQLDatabase.UpdateFromImagingSeriesAssignmentsSheet(sImagingSeriesAssignmentsFilepath, ImagingSeriesAssignmentType.Contours);
            vsAllQueries = [vsAllQueries; vsQueries];
                        
            % *** Registrations ***
            vsQueries = MySQLDatabase.UpdateRegistrationsFromImagingSeriesAssignmentsSheet(sImagingSeriesAssignmentsFilepath);
            vsAllQueries = [vsAllQueries; vsQueries];
        end
        
        function vsSqlQueries = UpdateFromAria(sAriaDataSpreadsheetFilepath)
            % Backup MySQL database to allow for complete rollback
            MySQLDatabase.Backup();
            
            % Record of all queries to be made
            vsSqlQueries = string.empty;
            
            % read matrix of data from Aria data collection
            c1xAriaData = readcell(sAriaDataSpreadsheetFilepath);
            
            vsHeaders1 = string(c1xAriaData(1,:));
            vsHeaders2 = string(c1xAriaData(2,:));
            
            c1xAriaData = c1xAriaData(3:end,:);
            
            % import/update each row
            for dRowIndex=1:size(c1xAriaData,1)
                dPatientStudyId = str2double(c1xAriaData{dRowIndex, vsHeaders1 == "Study ID"});
                
                oPatient = MySQLDatabase.GetPatientByStudyId(dPatientStudyId);
                
                if isempty(oPatient)
                    [~,sQuery] = SQLUtilities.InsertIntoDatabase(...
                        MySQLDatabase.GetConnection(),...
                        "patients",...
                        "patient_study_id", {dPatientStudyId});
                    vsSqlQueries = [vsSqlQueries; sQuery];
                    
                    oPatient = MySQLDatabase.GetPatientByStudyId(dPatientStudyId);
                end
                
                % Aria diagnoses
                % Compare existing diagnoses to proposed from
                % spreadsheet. If there's a difference in one or more, all
                % to be replaced.
                voExistingDiagnoses = oPatient.GetAriaDiagnoses();
                
                voDiagnosesToBeInserted = AriaDiagnosis.empty;
                
                dDiagnosisStartColIndex = 4;
                dNumDiagnosisColGroups = 3;
                dPerDiagnosisNumberOfCols = 3;
                
                for dDiagnosisIndex=1:dNumDiagnosisColGroups
                    dStartIndex = dDiagnosisStartColIndex + (dDiagnosisIndex - 1) * dPerDiagnosisNumberOfCols;
                    
                    xDateMonth = c1xAriaData{dRowIndex, dStartIndex+0};
                    xDateYear = c1xAriaData{dRowIndex, dStartIndex+1};
                    xCode = c1xAriaData{dRowIndex, dStartIndex+2};
                    
                    if ~all(ismissing([xDateMonth, xDateYear, xCode]))
                        voDiagnosesToBeInserted = [voDiagnosesToBeInserted, AriaDiagnosis.CreateFromSpreadsheetData(string(xCode), xDateYear, xDateMonth)];
                    end
                end
                
                % delete all diagnoses in DB if difference found 
                if ~isempty(voExistingDiagnoses) && ~MySQLDatabase.ObjectVectorsEqualIgnoreOrder(voExistingDiagnoses, voDiagnosesToBeInserted)
                    % delete old diagnoses
                    sDeleteWhereQuery = "fk_aria_diagnoses_patient_study_id = " + string(dPatientStudyId);
                    sQuery = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), "aria_diagnoses", sDeleteWhereQuery);
                    vsSqlQueries = [vsSqlQueries; sQuery];
                end
                
                % write diagnoses to DB
                if isempty(voExistingDiagnoses) || ~MySQLDatabase.ObjectVectorsEqualIgnoreOrder(voExistingDiagnoses, voDiagnosesToBeInserted)
                    vsSQLColumnsToInsert = ["disease_site_code" "disease_site" "date" "fk_aria_diagnoses_patient_study_id"];
                    
                    for dDiagnosisIndex=1:length(voDiagnosesToBeInserted)
                        oDiagnosisToInsert = voDiagnosesToBeInserted(dDiagnosisIndex);
                        
                        c1xSQLValuesToInsert = {...
                            oDiagnosisToInsert.GetDiseaseSiteCode(),...
                            oDiagnosisToInsert.GetDiseaseSite().GetMySQLEnumValue(),...
                            oDiagnosisToInsert.GetDate(),...
                            dPatientStudyId};
                        
                        [~,sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "aria_diagnoses", vsSQLColumnsToInsert, c1xSQLValuesToInsert);
                        vsSqlQueries = [vsSqlQueries; sQuery];
                    end
                end
                
                % Brain RT
                % Compare existing brain RTs to proposed from
                % spreadsheet. If there's a difference in one or more, all
                % to be replaced.
                voExistingBrainPlans = oPatient.GetAriaBrainRadiationTherapyCoursePlans();
                
                voBrainPlansToBeInserted = AriaRadiationTherapyCoursePlan.empty;
                
                dBrainPlanStartColIndex = 13;
                dNumBrainPlanColGroups = 7;
                dPerBrainPlanNumberOfCols = 6;
                
                for dBrainPlanIndex=1:dNumBrainPlanColGroups
                    dStartIndex = dBrainPlanStartColIndex + (dBrainPlanIndex - 1) * dPerBrainPlanNumberOfCols;
                    
                    xDateMonth = c1xAriaData{dRowIndex, dStartIndex+0};
                    xDateYear = c1xAriaData{dRowIndex, dStartIndex+1};
                    xIntentCode = c1xAriaData{dRowIndex, dStartIndex+2};
                    xDose_cGy = c1xAriaData{dRowIndex, dStartIndex+3};
                    xNumFractionsPrescribed = c1xAriaData{dRowIndex, dStartIndex+4};
                    xNumFractionsDelivered = c1xAriaData{dRowIndex, dStartIndex+5};
                    
                    if ~all(ismissing([xDateMonth, xDateYear, xIntentCode, xDose_cGy, xNumFractionsPrescribed, xNumFractionsDelivered]))
                        voBrainPlansToBeInserted = [voBrainPlansToBeInserted, ...
                            AriaRadiationTherapyCoursePlan.CreateFromSpreadsheetData(...
                            string(xIntentCode), xDateYear, xDateMonth, xDose_cGy/100, xNumFractionsPrescribed, xNumFractionsDelivered)];
                    end
                end
                
                % delete all brain plans in DB if difference found 
                if ~isempty(voExistingBrainPlans) && ~MySQLDatabase.ObjectVectorsEqualIgnoreOrder(voExistingBrainPlans, voBrainPlansToBeInserted)
                    % delete old brain plans
                    sDeleteWhereQuery = "fk_aria_brain_radiation_therapy_course_plans_patient_study_id = " + string(dPatientStudyId);
                    sQuery = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), "aria_brain_radiation_therapy_course_plans", sDeleteWhereQuery);
                    vsSqlQueries = [vsSqlQueries; sQuery];
                end
                
                % write brain plans to DB
                if isempty(voExistingBrainPlans) || ~MySQLDatabase.ObjectVectorsEqualIgnoreOrder(voExistingBrainPlans, voBrainPlansToBeInserted)
                    vsSQLColumnsToInsert = ["treatment_date", "intent", "calculated_dose_at_normalization_point_gy", "number_of_fractions_prescribed", "number_of_fractions_delivered", "fk_aria_brain_radiation_therapy_course_plans_patient_study_id"];
                    
                    for dPlanIndex=1:length(voBrainPlansToBeInserted)
                        oBrainPlansToInsert = voBrainPlansToBeInserted(dPlanIndex);
                        
                        c1xSQLValuesToInsert = {...
                            oBrainPlansToInsert.GetTreatmentDate(),...
                            oBrainPlansToInsert.GetIntent().GetMySQLEnumValue(),...
                            oBrainPlansToInsert.GetCalculatedDoseAtNormalizationPoint_Gy(),...
                            oBrainPlansToInsert.GetNumberOfFractionsPrescribed,...
                            oBrainPlansToInsert.GetNumberOfFractionsDelivered,...
                            dPatientStudyId};
                        
                        [~,sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "aria_brain_radiation_therapy_course_plans", vsSQLColumnsToInsert, c1xSQLValuesToInsert);
                        vsSqlQueries = [vsSqlQueries; sQuery];
                    end
                end
                
                % Lung RT
                % Compare existing lung RTs to proposed from
                % spreadsheet. If there's a difference in one or more, all
                % to be replaced.
                voExistingLungPlans = oPatient.GetAriaLungRadiationTherapyCoursePlans();
                
                voLungPlansToBeInserted = AriaLungRadiationTherapyCoursePlan.empty;
                
                dLungPlanStartColIndex = 55;
                dNumLungPlanColGroups = 4;
                dPerLungPlanNumberOfCols = 7;
                
                for dLungPlanIndex=1:dNumLungPlanColGroups
                    dStartIndex = dLungPlanStartColIndex + (dLungPlanIndex - 1) * dPerLungPlanNumberOfCols;
                    
                    xDateMonth = c1xAriaData{dRowIndex, dStartIndex+0};
                    xDateYear = c1xAriaData{dRowIndex, dStartIndex+1};
                    xSiteCode = c1xAriaData{dRowIndex, dStartIndex+2};
                    xIntentCode = c1xAriaData{dRowIndex, dStartIndex+3};
                    xDose_cGy = c1xAriaData{dRowIndex, dStartIndex+4};
                    xNumFractionsPrescribed = c1xAriaData{dRowIndex, dStartIndex+5};
                    xNumFractionsDelivered = c1xAriaData{dRowIndex, dStartIndex+6};
                    
                    if ~all(ismissing([xDateMonth, xDateYear, xSiteCode, xIntentCode, xDose_cGy, xNumFractionsPrescribed, xNumFractionsDelivered]))
                        voLungPlansToBeInserted = [voLungPlansToBeInserted, ...
                            AriaLungRadiationTherapyCoursePlan.CreateFromSpreadsheetData(...
                            string(xIntentCode), xDateYear, xDateMonth, xDose_cGy/100, xNumFractionsPrescribed, xNumFractionsDelivered, string(xSiteCode))];
                    end
                end
                
                % delete all Lung plans in DB if difference found 
                if ~isempty(voExistingLungPlans) && ~MySQLDatabase.ObjectVectorsEqualIgnoreOrder(voExistingLungPlans, voLungPlansToBeInserted)
                    % delete old Lung plans
                    sDeleteWhereQuery = "fk_aria_lung_radiation_therapy_course_plans_patient_study_id = " + string(dPatientStudyId);
                    sQuery = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), "aria_lung_radiation_therapy_course_plans", sDeleteWhereQuery);
                    vsSqlQueries = [vsSqlQueries; sQuery];
                end
                
                % write Lung plans to DB
                if isempty(voExistingLungPlans) || ~MySQLDatabase.ObjectVectorsEqualIgnoreOrder(voExistingLungPlans, voLungPlansToBeInserted)
                    vsSQLColumnsToInsert = ["treatment_date", "intent", "site", "calculated_dose_at_normalization_point_gy", "number_of_fractions_prescribed", "number_of_fractions_delivered", "fk_aria_lung_radiation_therapy_course_plans_patient_study_id"];
                    
                    for dPlanIndex=1:length(voLungPlansToBeInserted)
                        oLungPlansToInsert = voLungPlansToBeInserted(dPlanIndex);
                        
                        c1xSQLValuesToInsert = {...
                            oLungPlansToInsert.GetTreatmentDate(),...
                            oLungPlansToInsert.GetIntent().GetMySQLEnumValue(),...
                            oLungPlansToInsert.GetSite().GetMySQLEnumValue(),...
                            oLungPlansToInsert.GetCalculatedDoseAtNormalizationPoint_Gy(),...
                            oLungPlansToInsert.GetNumberOfFractionsPrescribed,...
                            oLungPlansToInsert.GetNumberOfFractionsDelivered,...
                            dPatientStudyId};
                        
                        [~,sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "aria_lung_radiation_therapy_course_plans", vsSQLColumnsToInsert, c1xSQLValuesToInsert);
                        vsSqlQueries = [vsSqlQueries; sQuery];
                    end
                end
            end
        end
        
        function vsQueries = UpdatePatientExclusions(sPatientExclusionSpreadsheetFilepath)
            % Backup MySQL database to allow for complete rollback
            MySQLDatabase.Backup();
            
            % Record of all queries to be made
            vsQueries = string.empty;
            
            % Read in spreadsheet
            c1xRawData = readcell(sPatientExclusionSpreadsheetFilepath);
            
            vsHeaders = string(c1xRawData(1,:));
            
            vdPatientIdPerRow = double(string(c1xRawData(2:end, vsHeaders == "Study ID")));
            vbIsExcludedPerRow = string(c1xRawData(2:end, vsHeaders == "Excluded")) == "Yes";
            vsExclusionReason = string(c1xRawData(2:end, vsHeaders == "Exclusion Reason"));
            
            c1xExclusionReason = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vsExclusionReason);
            c1xExclusionReason(ismissing(vsExclusionReason)) = {string.empty};
            
            for dRowIndex=1:length(vdPatientIdPerRow)
                oPatient = Patient.LoadFromDatabase(vdPatientIdPerRow(dRowIndex));
                
                bExistingIsExcluded = oPatient.IsExcluded();
                sExistingExclusionReason = oPatient.GetExclusionReason();
                
                bNewIsExcluded = vbIsExcludedPerRow(dRowIndex);
                sNewExclusionReason = c1xExclusionReason{dRowIndex};
                
                if xor(bExistingIsExcluded, bNewIsExcluded) ||...
                        xor(isempty(sExistingExclusionReason), isempty(sNewExclusionReason)) || ...
                        (~isempty(sExistingExclusionReason) && sExistingExclusionReason ~= sNewExclusionReason)
                    sQuery = SQLUtilities.UpdateDatabase(MySQLDatabase.GetConnection(), 'patients', ["is_excluded", "exclusion_reason"], {bNewIsExcluded, sNewExclusionReason}, "patient_study_id = " + string(vdPatientIdPerRow(dRowIndex)));
                    vsQueries = [vsQueries; sQuery];
                end
            end
        end
        
        function Backup()
            chBackupPath = Experiment.GetDataPath('MySQLBackupsFolder');
                        
            oConnection = MySQLDatabase.GetConnection();
            chDBName = oConnection.DefaultCatalog;
            
            sBackupFilename = string(chDBName) + " Backup " + datestr(datetime, "[YYYY-mm-dd_HH.MM.SS]") + ".sql";
            sBackupFilePath = string(fullfile(chBackupPath, sBackupFilename));
            
            [sMySQLDatabaseName, sMySQLServerUsername, sMySQLServerPassword, sMySQLInstallBinPath] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('MySQLConnectionSettings'),...
                'sMySQLDatabaseName', 'sMySQLServerUsername', 'sMySQLServerPassword', 'sMySQLInstallBinPath');
            
            sCall = """"+ fullfile(sMySQLInstallBinPath, "mysqldump.exe") + """ --user=" + sMySQLServerUsername + " --password=" + sMySQLServerPassword + " --databases " + sMySQLDatabaseName + " > """ + sBackupFilePath + """";            
            dStatusCode = system(sCall);
            
            if dStatusCode ~= 0
                error(...
                    'MySQLDatabase:Backup:SystemCallFailure',...
                    'System call to mysqldump failed, see console for details.');
            end
            
            disp("MySQL database backed via mysqldump to: " + sBackupFilePath);
        end
        
        function Restore(sRestoreFilePath)
            arguments
                sRestoreFilePath (1,1) string
            end
            
            [sMySQLServerUsername, sMySQLServerPassword, sMySQLInstallBinPath] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('MySQLConnectionSettings'),...
                'sMySQLServerUsername', 'sMySQLServerPassword', 'sMySQLInstallBinPath');
            
            sCall = """"+ fullfile(sMySQLInstallBinPath, "mysql.exe") + """ --user=" + sMySQLServerUsername + " --password=" + sMySQLServerPassword + " < """ + sRestoreFilePath + """";            
            dStatusCode = system(sCall);
            
            if dStatusCode ~= 0
                error(...
                    'MySQLDatabase:Restore:SystemCallFailure',...
                    'System call to mysql failed, see console for details.');
            end
            
            disp("MySQL database restore via mysql from: " + sRestoreFilePath);
            
        end
        
        function [sQuery, dTablePrimaryKey] = SyncValuesToMySQL(sTableName, dTablePrimaryKey, vsMySQLColumnNames, c1xNewValuesForMySQL, sCustomWhereQuery)
            arguments
                sTableName
                dTablePrimaryKey
                vsMySQLColumnNames
                c1xNewValuesForMySQL
                sCustomWhereQuery = string.empty
            end
            
            % clean "missing" values
            for dValueIndex=1:length(c1xNewValuesForMySQL)
                if isscalar(c1xNewValuesForMySQL{dValueIndex}) && ~isenum(c1xNewValuesForMySQL{dValueIndex}) && ismissing(c1xNewValuesForMySQL{dValueIndex}) % enums don't work with ismissing for some reason
                    c1xNewValuesForMySQL{dValueIndex} = [];
                end
            end
            
            if isempty(dTablePrimaryKey) % do insert
                [dTablePrimaryKey, sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), sTableName, vsMySQLColumnNames, c1xNewValuesForMySQL);
            else
                if isempty(sCustomWhereQuery)
                    sWhereQuery = SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues("id_" + sTableName, {dTablePrimaryKey});
                else
                    sWhereQuery = sCustomWhereQuery;
                end
                    
                tCurrentMySQLValues = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTableName, vsMySQLColumnNames, sWhereQuery);
                
                c1xCurrentMySQLValues = cell(size(c1xNewValuesForMySQL));
                
                for dValueIndex=1:length(vsMySQLColumnNames)
                    c1xCurrentMySQLValues(dValueIndex) = tCurrentMySQLValues.(vsMySQLColumnNames(dValueIndex));
                end
                
                vbIncludeInQuery = MySQLDatabase.ValueShouldBeIncludedInUpdateQuery(c1xNewValuesForMySQL, c1xCurrentMySQLValues);
                
                if any(vbIncludeInQuery)
                    sQuery = SQLUtilities.UpdateDatabase(MySQLDatabase.GetConnection(), sTableName, vsMySQLColumnNames(vbIncludeInQuery), c1xNewValuesForMySQL(vbIncludeInQuery), sWhereQuery);
                else
                    sQuery = string.empty;
                end
            end
        end
        
        function vsQueries = DeleteRowsFromTable(sTableName, vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete)
            dNumRowsToDelete = size(c2xWhereStatementValuesPerColumnPerRowToDelete,1);
            vsQueries = strings(dNumRowsToDelete,1);
            
            for dRowToDelete=1:dNumRowsToDelete
                sWhereQuery = SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(vsWhereStatementColumnNames, c2xWhereStatementValuesPerColumnPerRowToDelete(dRowToDelete,:));
                
                vsQueries(dRowToDelete) = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), sTableName, sWhereQuery);
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static)
        
        function vsQueries = UpdateRegistrationsFromImagingSeriesAssignmentsSheet(sImagingSeriesAssignmentsFilepath)
            vsQueries = string.empty;
            
            c2xRawData = readcell(sImagingSeriesAssignmentsFilepath, 'Sheet', 'Registrations');
            
            vsHeaders1 = string(c2xRawData(1,:));
            vsHeaders2 = string(c2xRawData(2,:));
            
            c2xData = c2xRawData(3:end,:);
            
            vdPatientIdsPerRow_New = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xData(:, vsHeaders1 == "Patient Study ID"));
            
            vsRegistrationSourcePerRow_New = string(c2xData(:, vsHeaders1 == "Registration File" & vsHeaders2 == "Source"));
            vsRegistrationSeriesInstanceUIDPerRow_New = string(c2xData(:, vsHeaders1 == "Registration File" & vsHeaders2 == "Series Instance UID"));
            vsRegistrationSOPInstanceUIDPerRow_New = string(c2xData(:, vsHeaders1 == "Registration File" & vsHeaders2 == "SOP Instance UID"));
            vdRegistrationInstanceNumberPerRow_New = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xData(:, vsHeaders1 == "Registration File" & vsHeaders2 == "Instance Number"));
            
            vsPrimaryImageSeriesInstanceUIDPerRow_New = string(c2xData(:, vsHeaders1 == "Primary Image Series" & vsHeaders2 == "Series Instance UID"));
            vsSecondaryImageSeriesInstanceUIDPerRow_New = string(c2xData(:, vsHeaders1 == "Secondary Image Series" & vsHeaders2 == "Series Instance UID"));
            
            sJoin = "imaging_series_registrations " + ...
                "JOIN dicom_series reg_dicom_series ON fk_registration_series_id_dicom_series = reg_dicom_series.id_dicom_series "+ ...
                "JOIN dicom_series pri_dicom_series ON fk_primary_imaging_series_id_dicom_series = pri_dicom_series.id_dicom_series "+ ...
                "JOIN dicom_series sec_dicom_series ON fk_secondary_imaging_series_id_dicom_series = sec_dicom_series.id_dicom_series "+ ...
                "JOIN dicom_studies ON reg_dicom_series.fk_dicom_series_id_dicom_studies = id_dicom_studies " + ...
                "JOIN patients ON fk_dicom_studies_patient_study_id = patient_study_id";
            vsColumns = [...
                "id_imaging_series_registrations"
                "source"
                "dicom_sop_instance_uid"
                "dicom_instance_number"
                
                "reg_dicom_series.dicom_instance_uid"
                "pri_dicom_series.dicom_instance_uid"
                "sec_dicom_series.dicom_instance_uid"
                
                "patient_study_id"];
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoin, vsColumns);
            
            vdPatientIdsPerRow_Existing = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tOutput.patient_study_id);
            
            vsRegistrationSourcePerRow_Existing = string(tOutput.source);
            vsRegistrationSeriesInstanceUIDPerRow_Existing = string(tOutput.dicom_instance_uid);
            vsRegistrationSOPInstanceUIDPerRow_Existing = string(tOutput.dicom_sop_instance_uid);
            vdRegistrationInstanceNumberPerRow_Existing = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tOutput.dicom_instance_number);
            
            vsPrimaryImageSeriesInstanceUIDPerRow_Existing = string(tOutput.dicom_instance_uid_1);
            vsSecondaryImageSeriesInstanceUIDPerRow_Existing = string(tOutput.dicom_instance_uid_2);
            
            
            % delete rows from Existing that aren't in New and mark rows in
            % New that are already in DB
            vbNewRowAlreadyInDatabase = false(size(vdPatientIdsPerRow_New));
            
            for dExistingRowIndex=1:length(vdPatientIdsPerRow_Existing)
                vbMatchingRowsInNew = ...
                    vdPatientIdsPerRow_Existing(dExistingRowIndex) == vdPatientIdsPerRow_New & ...
                    vsRegistrationSourcePerRow_Existing(dExistingRowIndex) == vsRegistrationSourcePerRow_New & ...
                    vsRegistrationSeriesInstanceUIDPerRow_Existing(dExistingRowIndex) == vsRegistrationSeriesInstanceUIDPerRow_New & ...
                    vsRegistrationSOPInstanceUIDPerRow_Existing(dExistingRowIndex) == vsRegistrationSOPInstanceUIDPerRow_New & ...
                    vdRegistrationInstanceNumberPerRow_Existing(dExistingRowIndex) == vdRegistrationInstanceNumberPerRow_New & ...
                    vsPrimaryImageSeriesInstanceUIDPerRow_Existing(dExistingRowIndex) == vsPrimaryImageSeriesInstanceUIDPerRow_New & ...
                    vsSecondaryImageSeriesInstanceUIDPerRow_Existing(dExistingRowIndex) == vsSecondaryImageSeriesInstanceUIDPerRow_New;
                
                if ~any(vbMatchingRowsInNew)
                    sQuery = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), 'imaging_series_registrations', "id_imaging_series_registrations = " + string(tOutput.id_imaging_series_registrations{dExistingRowIndex}));
                    vsQueries = [vsQueries; sQuery];
                else
                    vbNewRowAlreadyInDatabase(vbMatchingRowsInNew) = true;
                end
            end
            
            
            % add rows from New
            vdPatientIdsPerRow_New = vdPatientIdsPerRow_New(~vbNewRowAlreadyInDatabase);
            vsRegistrationSourcePerRow_New = vsRegistrationSourcePerRow_New(~vbNewRowAlreadyInDatabase);
            vsRegistrationSeriesInstanceUIDPerRow_New = vsRegistrationSeriesInstanceUIDPerRow_New(~vbNewRowAlreadyInDatabase);            
            vsRegistrationSOPInstanceUIDPerRow_New = vsRegistrationSOPInstanceUIDPerRow_New(~vbNewRowAlreadyInDatabase);
            vdRegistrationInstanceNumberPerRow_New = vdRegistrationInstanceNumberPerRow_New(~vbNewRowAlreadyInDatabase);
            vsPrimaryImageSeriesInstanceUIDPerRow_New = vsPrimaryImageSeriesInstanceUIDPerRow_New(~vbNewRowAlreadyInDatabase);
            vsSecondaryImageSeriesInstanceUIDPerRow_New = vsSecondaryImageSeriesInstanceUIDPerRow_New(~vbNewRowAlreadyInDatabase);
            
            for dNewRowIndex=1:length(vdPatientIdsPerRow_New)
                tRegSeriesIdOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), 'dicom_series', "id_dicom_series", "WHERE dicom_instance_uid = '" + vsRegistrationSeriesInstanceUIDPerRow_New(dNewRowIndex) + "'");
                
                if isempty(tRegSeriesIdOutput) || size(tRegSeriesIdOutput,1) > 1
                    error(...
                        'MySQLDatabase:UpdateRegistrationsFromImagingSeriesAssignmentsSheet:UniqueRegistrationDicomSeriesNotFound',...
                        'Either no or multiple Dicom series were found with the requested registration series instance UID.');
                end                
                
                dRegDicomSeriesId = tRegSeriesIdOutput.id_dicom_series{1};
                
                
                tPriSeriesIdOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), 'dicom_series', "id_dicom_series", "WHERE dicom_instance_uid = '" + vsPrimaryImageSeriesInstanceUIDPerRow_New(dNewRowIndex) + "'");
                
                if isempty(tPriSeriesIdOutput) || size(tPriSeriesIdOutput,1) > 1
                    error(...
                        'MySQLDatabase:UpdateRegistrationsFromImagingSeriesAssignmentsSheet:UniquePrimaryDicomSeriesNotFound',...
                        'Either no or multiple Dicom series were found with the requested primary series instance UID.');
                end                
                
                dPriDicomSeriesId = tPriSeriesIdOutput.id_dicom_series{1};
                
                
                tSecSeriesIdOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), 'dicom_series', "id_dicom_series", "WHERE dicom_instance_uid = '" + vsSecondaryImageSeriesInstanceUIDPerRow_New(dNewRowIndex) + "'");
                
                if isempty(tSecSeriesIdOutput) || size(tSecSeriesIdOutput,1) > 1
                    error(...
                        'MySQLDatabase:UpdateRegistrationsFromImagingSeriesAssignmentsSheet:UniqueSecondaryDicomSeriesNotFound',...
                        'Either no or multiple Dicom series were found with the requested secondary series instance UID.');
                end                
                
                dSecDicomSeriesId = tSecSeriesIdOutput.id_dicom_series{1};
                                                
                vsInsertColumns = [
                    "fk_registration_series_id_dicom_series"
                    "fk_primary_imaging_series_id_dicom_series"
                    "fk_secondary_imaging_series_id_dicom_series"
                    "source"
                    "dicom_sop_instance_uid"
                    "dicom_instance_number"];
                c1xInsertValues = {
                    dRegDicomSeriesId
                    dPriDicomSeriesId
                    dSecDicomSeriesId
                    vsRegistrationSourcePerRow_New(dNewRowIndex)
                    vsRegistrationSOPInstanceUIDPerRow_New(dNewRowIndex)
                    vdRegistrationInstanceNumberPerRow_New(dNewRowIndex)};
                
                [~,sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(),"imaging_series_registrations",vsInsertColumns,c1xInsertValues);
                vsQueries = [vsQueries; sQuery];
            end
        end
        
        function vsQueries = UpdateFromImagingSeriesAssignmentsSheet(sImagingSeriesAssignmentsFilepath, eImagingSeriesAssignmentType)
            vsQueries = string.empty;
            
            vsSopInstanceUidPerRow_New = string.empty;
            
            if eImagingSeriesAssignmentType == ImagingSeriesAssignmentType.T1wPostContrast
                c2xRawData = readcell(sImagingSeriesAssignmentsFilepath, 'Sheet', 'T1w-CE MRI');
                
                vsHeaders = string(c2xRawData(1,:));
                c2xData = c2xRawData(2:end,:);
            elseif eImagingSeriesAssignmentType == ImagingSeriesAssignmentType.PlanningCT
                c2xRawData = readcell(sImagingSeriesAssignmentsFilepath, 'Sheet', 'Planning CT');
                
                vsHeaders = string(c2xRawData(1,:));
                c2xData = c2xRawData(2:end,:);
            elseif eImagingSeriesAssignmentType == ImagingSeriesAssignmentType.Contours
                c2xRawData = readcell(sImagingSeriesAssignmentsFilepath, 'Sheet', 'Contours');
                
                vsHeaders = string(c2xRawData(1,:));                
                c2xData = c2xRawData(2:end,:);
                
                vsSopInstanceUidPerRow_New = string(c2xData(:, vsHeaders == "SOP Instance UID"));
            else
                error(...
                    'MySQLDatabase:UpdateFromImagingSeriesAssignmentsSheet:UnsupportedImagingSeriesAsssignmentType',...
                    'Provided eImagingSeriesAssignmentType unsupported');
            end
            
            vdPatientIdsPerRow_New = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xData(:, vsHeaders == "Patient Study ID"));
            vsSeriesInstanceUIDPerRow_New = string(c2xData(:, vsHeaders == "Series Instance UID"));
            
            if isempty(vsSopInstanceUidPerRow_New)
                vsSopInstanceUidPerRow_New = strings(size(vsSeriesInstanceUIDPerRow_New));
            end
            
            % sync to MySQL database per patient
            sJoin = "imaging_series_assignments " + ...
                "JOIN dicom_series ON fk_imaging_series_assignments_id_dicom_series = id_dicom_series "+ ...
                "JOIN dicom_studies ON fk_dicom_series_id_dicom_studies = id_dicom_studies " + ...
                "JOIN patients ON fk_dicom_studies_patient_study_id = patient_study_id";
            vsColumns = ["id_imaging_series_assignments", "dicom_sop_instance_uid", "dicom_series.dicom_instance_uid", "patient_study_id"];
            sWhere = "WHERE assignment_type = '" + eImagingSeriesAssignmentType.GetMySQLEnumValue() + "'";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoin, vsColumns, sWhere);
            
            vdPatientIdsPerRow_Existing = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tOutput.patient_study_id);
            vsSeriesInstanceUIDPerRow_Existing = string(tOutput.dicom_instance_uid);
            
            c1sSopInstanceUidPerRow_Existing = tOutput.dicom_sop_instance_uid;
            
            for dRowIndex=1:length(c1sSopInstanceUidPerRow_Existing)
                if isempty(c1sSopInstanceUidPerRow_Existing{dRowIndex})
                    c1sSopInstanceUidPerRow_Existing{dRowIndex} = "";
                end
            end
            
            vsSopInstanceUidPerRow_Existing = string(c1sSopInstanceUidPerRow_Existing);
            
            % delete rows from Existing that aren't in New and mark rows in
            % New that are already in DB
            vbNewRowAlreadyInDatabase = false(size(vdPatientIdsPerRow_New));
            
            for dExistingRowIndex=1:length(vdPatientIdsPerRow_Existing)
                vbMatchingRowsInNew = ...
                    vdPatientIdsPerRow_Existing(dExistingRowIndex) == vdPatientIdsPerRow_New & ...
                    vsSeriesInstanceUIDPerRow_Existing(dExistingRowIndex) == vsSeriesInstanceUIDPerRow_New & ...
                    vsSopInstanceUidPerRow_Existing(dExistingRowIndex) == vsSopInstanceUidPerRow_New;
                
                if ~any(vbMatchingRowsInNew)
                    sQuery = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), 'imaging_series_assignments', "id_imaging_series_assignments = " + string(tOutput.id_imaging_series_assignments{dExistingRowIndex}));
                    vsQueries = [vsQueries; sQuery];
                else
                    vbNewRowAlreadyInDatabase(vbMatchingRowsInNew) = true;
                end
            end
            
            % add rows from New
            vdPatientIdsPerRow_New = vdPatientIdsPerRow_New(~vbNewRowAlreadyInDatabase);
            vsSeriesInstanceUIDPerRow_New = vsSeriesInstanceUIDPerRow_New(~vbNewRowAlreadyInDatabase);
            vsSopInstanceUidPerRow_New = vsSopInstanceUidPerRow_New(~vbNewRowAlreadyInDatabase);
            
            for dNewRowIndex=1:length(vdPatientIdsPerRow_New)
                tSeriesIdOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), 'dicom_series', "id_dicom_series", "WHERE dicom_instance_uid = '" + vsSeriesInstanceUIDPerRow_New(dNewRowIndex) + "'");
                
                if isempty(tSeriesIdOutput) || size(tSeriesIdOutput,1) > 1
                    error(...
                        'MySQLDatabase:UpdateFromImagingSeriesAssignmentsSheet:UniqueDicomSeriesNotFound',...
                        'Either no or multiple Dicom series were found with the requested series instance UID.');
                end                
                
                dDicomSeriesId = tSeriesIdOutput.id_dicom_series{1};
                
                vsInsertColumns = [
                    "fk_imaging_series_assignments_id_dicom_series"
                    "assignment_type"
                    "dicom_sop_instance_uid"];
                c1xInsertValues = {
                    dDicomSeriesId
                    eImagingSeriesAssignmentType.GetMySQLEnumValue()
                    vsSopInstanceUidPerRow_New(dNewRowIndex)};
                
                [~,sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(),"imaging_series_assignments",vsInsertColumns,c1xInsertValues);
                vsQueries = [vsQueries; sQuery];
            end
        end
        
        function bBool = ObjectVectorsEqualIgnoreOrder(voVector1, voVector2)
            arguments
                voVector1 (:,1)
                voVector2 (:,1)
            end
            
            if numel(voVector1) ~= numel(voVector2)
                bBool = false;
            else
                bBool = true;
                
                while numel(voVector1) ~= 0
                    oElem1 = voVector1(1);
                    
                    bMatchFoundInVector2 = false;
                    
                    for dSearchIndex=1:length(voVector2)
                        if oElem1 == voVector2(dSearchIndex)
                            bMatchFoundInVector2 = true;
                            
                            voVector1(1) = [];
                            voVector2(dSearchIndex) = [];
                            break;
                        end
                    end
                    
                    if ~bMatchFoundInVector2
                        bBool = false;
                        break;
                    end
                end
            end
        end
        
        function bBool = RowsInCellArraysEqualIgnoreOrder(c2xCellArray1, c2xCellArray2)
            if any(size(c2xCellArray1) ~= size(c2xCellArray2))
                bBool = false;
            else
                bBool = true;
                
                while size(c2xCellArray1,1) ~= 0
                    c1xRow1 = c2xCellArray1(1,:);
                    
                    bMatchFoundInCellArray2 = false;
                    
                    for dSearchIndex=1:size(c2xCellArray2,1)
                        if CellArrayUtils.AreEqual(c1xRow1, c2xCellArray2(dSearchIndex,:))
                            bMatchFoundInCellArray2 = true;
                            
                            c2xCellArray1(1,:) = [];
                            c2xCellArray2(dSearchIndex,:) = [];
                            break;
                        end
                    end
                    
                    if ~bMatchFoundInCellArray2
                        bBool = false;
                        break;
                    end
                end
            end
        end
        
        function vsQueries = UpdateWithTreatmentPlanningSystemData(vdPatientIdPerPrescription, vsPlanNamePerPrescription, vsBeamSetNamePerPrescription, vsPrescriptionNamePerPrescription, vdPrescribedDosePerPrescription_Gy, vdPrescribedFractionsPerPrescription, c1vsGTVNamesPerPrescription, eTreatmentPlanningSystem)
            vsQueries = string.empty;
            
            vdUniquePatientIds = unique(vdPatientIdPerPrescription);
            
            for dPatientIndex=1:length(vdUniquePatientIds)
                dPatientId = vdUniquePatientIds(dPatientIndex);
                oPatient = Patient.LoadFromDatabase(dPatientId);
                
                vsPlanNamePerPrescriptionForPatient = vsPlanNamePerPrescription(vdPatientIdPerPrescription == vdUniquePatientIds(dPatientIndex));
                vsBeamSetNamePerPrescriptionForPatient = vsBeamSetNamePerPrescription(vdPatientIdPerPrescription == vdUniquePatientIds(dPatientIndex));
                
                if ~isempty(vsPrescriptionNamePerPrescription)
                    vsPrescriptionNamePerPrescriptionForPatient = vsPrescriptionNamePerPrescription(vdPatientIdPerPrescription == vdUniquePatientIds(dPatientIndex));
                else
                    vsPrescriptionNamePerPrescriptionForPatient = [];
                end
                    
                vdPrescribedDosePerPrescriptionForPatient_Gy = vdPrescribedDosePerPrescription_Gy(vdPatientIdPerPrescription == vdUniquePatientIds(dPatientIndex));
                vdPrescribedFractionsPerPrescriptionForPatient = vdPrescribedFractionsPerPrescription(vdPatientIdPerPrescription == vdUniquePatientIds(dPatientIndex));
                c1vsGTVNamesPerPrescriptionForPatient = c1vsGTVNamesPerPrescription(vdPatientIdPerPrescription == vdUniquePatientIds(dPatientIndex));
                
                tExistingBMData = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastases", [], "WHERE fk_brain_metastases_patient_study_id = " + string(dPatientId));
                
                tExistingTPSData = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(),...
                    "brain_radiation_courses " + ...
                    "JOIN brain_radiation_plans ON brain_radiation_courses.id_brain_radiation_courses = brain_radiation_plans.fk_brain_radiation_plans_id_brain_radiation_courses " + ...
                    "JOIN brain_radiation_beam_sets ON brain_radiation_plans.id_brain_radiation_plans = brain_radiation_beam_sets.fk_brain_radiation_beam_sets_id_brain_radiation_plans " +...
                    "JOIN brain_metastasis_prescriptions ON brain_radiation_beam_sets.id_brain_radiation_beam_sets = brain_metastasis_prescriptions.fk_bm_prescriptions_id_brain_radiation_beam_sets",...
                    [],...
                    "WHERE brain_radiation_courses.fk_brain_radiation_courses_patient_study_id = " + string(dPatientId));
                                
                % brain_metastases
                vdBMNumbersExisting = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tExistingBMData.brain_metastasis_number);
                
                dNumBMs = 0;
                
                for dPrescriptionIndex=1:length(c1vsGTVNamesPerPrescriptionForPatient)
                    dNumBMs = dNumBMs + length(c1vsGTVNamesPerPrescriptionForPatient{dPrescriptionIndex});
                end
                
                vdBMNumbersToInsert = (1:dNumBMs)';
                
                if MySQLDatabase.ObjectVectorsEqualIgnoreOrder(vdBMNumbersExisting, vdBMNumbersToInsert)
                    % do nothing
                else
                    % not equal, delete all, then reinsert
                    if ~isempty(vdBMNumbersExisting)
                        sQuery = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), 'brain_metastases', "fk_brain_metastases_patient_study_id = " + string(dPatientId));
                        vsQueries = [vsQueries; sQuery];
                    end
                    
                    for dBMNumber=1:dNumBMs
                        [~,sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "brain_metastases", ["fk_brain_metastases_patient_study_id" "brain_metastasis_number"], {dPatientId, dBMNumber});
                        vsQueries = [vsQueries; sQuery];
                    end
                end
                                
                % compare TPS data to existing TPS data
                % - all or nothing: if all data is equal, no changes, if
                % one thing changes, delete it all and reset
                c2xTPSDataToInsert = cell(dNumBMs,9);
                
                dPrescriptionIndex = 1;
                dGTVNameIndex = 1;
                
                for dBMNumber=1:dNumBMs
                    if isempty(vsPrescriptionNamePerPrescriptionForPatient)
                        sPrescriptionName = string.empty;
                    else
                        sPrescriptionName = vsPrescriptionNamePerPrescriptionForPatient(dPrescriptionIndex);
                    end
                    
                    c2xTPSDataToInsert(dBMNumber,:) = {
                        oPatient.GetFirstBrainRadiationTherapyDate()
                        vsPlanNamePerPrescriptionForPatient(dPrescriptionIndex)
                        eTreatmentPlanningSystem.GetMySQLEnumValue()
                        vsBeamSetNamePerPrescriptionForPatient(dPrescriptionIndex)
                        sPrescriptionName
                        dBMNumber
                        vdPrescribedDosePerPrescriptionForPatient_Gy(dPrescriptionIndex)
                        vdPrescribedFractionsPerPrescriptionForPatient(dPrescriptionIndex)
                        c1vsGTVNamesPerPrescriptionForPatient{dPrescriptionIndex}(dGTVNameIndex)};
                                       
                    if dGTVNameIndex == length(c1vsGTVNamesPerPrescriptionForPatient{dPrescriptionIndex})
                        dPrescriptionIndex = dPrescriptionIndex + 1;
                        dGTVNameIndex = 1;
                    else
                        dGTVNameIndex = dGTVNameIndex + 1;
                    end
                end
                
                c2xExistingTPSData = table2cell(tExistingTPSData);
                
                vsExistingTPSDataColumnNames = string(tExistingTPSData.Properties.VariableNames);
                
                vbIncludeColumn = ...
                    vsExistingTPSDataColumnNames == "course_date" | ...
                    vsExistingTPSDataColumnNames == "plan_name" | ...
                    vsExistingTPSDataColumnNames == "treatment_planning_system" | ...
                    vsExistingTPSDataColumnNames == "beam_set_name" | ...
                    vsExistingTPSDataColumnNames == "prescription_name" | ...
                    vsExistingTPSDataColumnNames == "fk_bm_prescriptions_brain_metastasis_number" | ...
                    vsExistingTPSDataColumnNames == "dose_gy" | ...
                    vsExistingTPSDataColumnNames == "number_of_fractions" | ...
                    vsExistingTPSDataColumnNames == "gtv_structure_name";                    
                
                if ~MySQLDatabase.RowsInCellArraysEqualIgnoreOrder(c2xExistingTPSData(:,vbIncludeColumn), c2xTPSDataToInsert)
                    if ~isempty(c2xExistingTPSData)
                        % delete all TPS data
                        % - brain_radiation_courses
                        % -- will propogate to:
                        % --- brain_radiation_plans
                        % --- brain_radiation_beam_sets
                        % --- brain_metastasis_prescriptions
                        
                        vdUniqueCourseIds = unique(CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tExistingTPSData.id_brain_radiation_courses));
                        
                        for dCourseIndex=1:length(vdUniqueCourseIds)
                            sQuery = SQLUtilities.DeleteFromDatabase(MySQLDatabase.GetConnection(), "brain_radiation_courses", "id_brain_radiation_courses = " + string(vdUniqueCourseIds(dCourseIndex)));
                            vsQueries = [vsQueries; sQuery];
                        end
                    end
                    
                    % insert data
                    % - brain_radiation_courses
                    [dInsertedCourseId, sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "brain_radiation_courses", ["course_date", "fk_brain_radiation_courses_patient_study_id"], {oPatient.GetFirstBrainRadiationTherapyDate(), dPatientId});
                    vsQueries = [vsQueries; sQuery];
                    
                    % - brain_radiation_plans
                    vsUniquePlanNames = unique(vsPlanNamePerPrescriptionForPatient);
                    vdInsertedPlanIds = zeros(size(vsUniquePlanNames));
                    
                    for dPlanIndex=1:length(vsUniquePlanNames)
                        [vdInsertedPlanIds(dPlanIndex), sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "brain_radiation_plans", ["plan_name", "treatment_planning_system", "fk_brain_radiation_plans_id_brain_radiation_courses"], {vsUniquePlanNames(dPlanIndex), eTreatmentPlanningSystem, dInsertedCourseId});
                        vsQueries = [vsQueries; sQuery];
                    end
                    
                    % - brain_radiation_beam_sets
                    vsUniqueBeamSetNames = unique(vsBeamSetNamePerPrescriptionForPatient);
                    vdInsertedBeamSetIds = zeros(size(vsUniqueBeamSetNames));
                    
                    for dBeamSetIndex=1:length(vsUniqueBeamSetNames)
                        dOriginalPerPrescriptionIndex = find(vsUniqueBeamSetNames(dBeamSetIndex) == vsBeamSetNamePerPrescriptionForPatient, 1);
                        
                        if isempty(vsPrescriptionNamePerPrescriptionForPatient)
                            sPrescriptionName = string.empty;
                        else
                            sPrescriptionName = vsPrescriptionNamePerPrescriptionForPatient(dOriginalPerPrescriptionIndex);
                        end
                        
                        [vdInsertedBeamSetIds(dBeamSetIndex), sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "brain_radiation_beam_sets", ["beam_set_name", "prescription_name", "fk_brain_radiation_beam_sets_id_brain_radiation_plans"], {vsUniqueBeamSetNames(dBeamSetIndex), sPrescriptionName, vdInsertedPlanIds(vsUniquePlanNames == vsPlanNamePerPrescriptionForPatient(dOriginalPerPrescriptionIndex))});
                        vsQueries = [vsQueries; sQuery];
                    end
                    
                    % - brain_metastasis_prescriptions         
                    dBMNumber = 1;
                    
                    for dPrescriptionIndex=1:length(vdPrescribedDosePerPrescriptionForPatient_Gy)
                        dBeamSetForeignKeyId = vdInsertedBeamSetIds(vsUniqueBeamSetNames == vsBeamSetNamePerPrescriptionForPatient(dPrescriptionIndex));
                        
                        for dBMIndex=1:length(c1vsGTVNamesPerPrescriptionForPatient{dPrescriptionIndex})
                            [~, sQuery] = SQLUtilities.InsertIntoDatabase(MySQLDatabase.GetConnection(), "brain_metastasis_prescriptions", ...
                                ["fk_bm_prescriptions_fk_brain_metastases_patient_study_id", "fk_bm_prescriptions_brain_metastasis_number", "fk_bm_prescriptions_id_brain_radiation_beam_sets", "dose_gy", "number_of_fractions", "gtv_structure_name"],...
                                {dPatientId, dBMNumber, dBeamSetForeignKeyId, vdPrescribedDosePerPrescriptionForPatient_Gy(dPrescriptionIndex), vdPrescribedFractionsPerPrescriptionForPatient(dPrescriptionIndex), c1vsGTVNamesPerPrescriptionForPatient{dPrescriptionIndex}(dBMIndex)}...
                                );
                            vsQueries = [vsQueries; sQuery];
                            dBMNumber = dBMNumber + 1;
                        end
                    end
                end
            end
        end
                
        function vbIncludeInQuery = ValueShouldBeIncludedInUpdateQuery(c1xNewValues, c1xExistingValues)
            dNumValues = length(c1xNewValues);
            
            vbIncludeInQuery = false(size(c1xNewValues));
            
            for dValueIndex=1:length(c1xNewValues)
                xNewValue = c1xNewValues{dValueIndex};
                xExistingValue = c1xExistingValues{dValueIndex};
                
                if ischar(xNewValue)
                    if isempty(xNewValue)
                        xNewValue = string.empty;
                    else
                        xNewValue = string(xNewValue);
                    end
                end
                
                bNewValueIsEmpty = isempty(xNewValue);
                bExistingValueIsEmpty = isempty(xExistingValue);
                
                if bNewValueIsEmpty && bExistingValueIsEmpty
                    vbIncludeInQuery(dValueIndex) = false;
                elseif ...
                        (bNewValueIsEmpty && ~bExistingValueIsEmpty) ||...
                        (~bNewValueIsEmpty && bExistingValueIsEmpty)
                    vbIncludeInQuery(dValueIndex) = true;
                else
                    if ~isscalar(xNewValue) || ~isscalar(xExistingValue)
                        if any(size(xNewValue) ~= size(xExistingValue))
                            vbIncludeInQuery(dValueIndex) = true;
                        else
                            vbIncludeInQuery(dValueIndex) = any(xNewValue ~= xExistingValue);
                        end
                    else
                        vbIncludeInQuery(dValueIndex) = xNewValue ~= xExistingValue;
                    end
                end
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

