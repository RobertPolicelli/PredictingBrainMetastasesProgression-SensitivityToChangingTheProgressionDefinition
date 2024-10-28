classdef RadiologyAssessment
    %RadiologyAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voBrainMetastasisRadiologyAssessmentPerBrainMetastasis (:,1) BrainMetastasisRadiologyAssessment {BrainMetastasisRadiologyAssessment.MustAllHaveSameScanDate} = BrainMetastasisFollowUpRadiologyAssessment.empty(0,1)
                
        sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar} = string.empty     
        
        dMySQLPrimaryKey (1,1) double
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RadiologyAssessment(voBrainMetastasisRadiologyAssessmentPerBrainMetastasis, sREDCapDataCollectionNotes, dMySQLPrimaryKey)
            %obj = RadiologyAssessment(voBrainMetastasisRadiologyAssessmentPerBrainMetastasis, sREDCapDataCollectionNotes, dMySQLPrimaryKey)
            
            obj.voBrainMetastasisRadiologyAssessmentPerBrainMetastasis = voBrainMetastasisRadiologyAssessmentPerBrainMetastasis;
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDate = GetScanDate(obj)
            dtDate = obj.voBrainMetastasisRadiologyAssessmentPerBrainMetastasis(1).GetScanDate();
        end
        
        function voBrainMetastasisRadiologyAssessmentPerBrainMetastasis = GetBrainMetastasisRadiologyAssessmentPerBrainMetastasis(obj)
            voBrainMetastasisRadiologyAssessmentPerBrainMetastasis = obj.voBrainMetastasisRadiologyAssessmentPerBrainMetastasis;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
        
        function oBrainMetastasisRadiologyAssessment = GetBrainMetastasisRadiologyAssessmentForBrainMetastasis(obj, dBrainMetastasisNumber)
            arguments
                obj (1,1) RadiologyAssessment
                dBrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
            oBrainMetastasisRadiologyAssessment = obj.voBrainMetastasisRadiologyAssessmentPerBrainMetastasis(dBrainMetastasisNumber);
        end
    end
    
    
    methods (Access = public, Static)
        
        function oAssessment = LoadFromDatabaseByPatientStudyId(dPatientStudyId, eRadiologyAssessmentType)
            arguments
                dPatientStudyId (1,1) double {mustBeInteger, mustBePositive}
                eRadiologyAssessmentType (1,1) RadiologyAssessmentType 
            end
            
            if eRadiologyAssessmentType == RadiologyAssessmentType.FollowUp
                error(...
                    'RadiologyAssessment:LoadFromDatabaseByPatientStudyId:InvalidRadiologyAssessmentType',...
                    'RadiologyAssessmentType.FollowUp should be loaded using FollowUpRadiologyAssessment.FollowUp');
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "radiology_assessments", [], ...
                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                ["fk_radiology_assessments_patient_study_id", "type"],...
                {dPatientStudyId, eRadiologyAssessmentType}),...
                "ORDER BY scan_date");
            
            if size(tOutput,1) > 1
                error(...
                    'RadiologyAssessment:GetFromDatabaseByPatientStudyId:NonUniqueEntry',...
                    'Multiple assessments matching the patient ID were found.');
            elseif size(tOutput,1) == 0
                oAssessment = RadiologyAssessment.empty;                
            else
                dRadiologyAssessmentId = tOutput.id_radiology_assessments{1};
                
                switch eRadiologyAssessmentType
                    case RadiologyAssessmentType.PreResection
                        voBMAssessments = BrainMetastasisPreTreatmentRadiologyAssessment.LoadFromDatabaseByRadiologyAssessmentId(dRadiologyAssessmentId);
                    case RadiologyAssessmentType.PreRadiation
                        voBMAssessments = BrainMetastasisPreRadiationRadiologyAssessment.LoadFromDatabaseByRadiologyAssessmentId(dRadiologyAssessmentId);
                    otherwise
                        voBMAssessments = BrainMetastasisFollowUpRadiologyAssessment.LoadFromDatabaseByRadiologyAssessmentId(dRadiologyAssessmentId);
                end
                
                oAssessment = RadiologyAssessment(...
                    voBMAssessments,...
                    tOutput.data_collection_notes{1},...
                    dRadiologyAssessmentId);
            end
        end
        
        function voValidationRecords = Validate(oRadiologyAssessment, oParentPatient, sValidationMode, voValidationRecords)
            switch sValidationMode
                case "PreResection"
                    % - GetScanDate()
                    % -- after the pre-radiation radiology assessment
                    if oRadiologyAssessment.GetScanDate() > oParentPatient.GetPreRadiationRadiologyAssessment().GetScanDate()
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Pre-resection radiology assessment took place after the pre-radiation assessment"));
                    end
                    
                    % -- more than 6 months before first brain radiotherapy
                    if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oRadiologyAssessment.GetScanDate())) < -6
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Pre-resection radiology assessment took place more than 6 months before the first brain radiation therapy"));
                    end
                    
                case "PreRadiation"
                    % - GetScanDate()
                    % -- month after treatment month
                    if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oRadiologyAssessment.GetScanDate())) > 0
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Is 1 or more months after first brain radiation therapy date"));
                    end
                    
                    % -- > 1 month before treatment month
                    if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oRadiologyAssessment.GetScanDate())) < -1
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Is 2 or more months before first brain radiation therapy date"));
                    end
                    
                case "FollowUp"
                    % - GetScanDate()
                    % -- before or same month as treatment
                    if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oRadiologyAssessment.GetScanDate())) <= 0
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Is same month or before first brain radiation therapy date"));
                    end
                    
                    % -- after date of death
                    if ~isempty(oParentPatient.GetApproximateDateOfDeath())
                        if calmonths(between(oParentPatient.GetApproximateDateOfDeath(), oRadiologyAssessment.GetScanDate())) > 0
                            voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Is after the patient's approximate date of death"));
                        end
                    end
                    
                    % -- after 2 years post treatment (should be in "post
                    % 2-year follow-up)
                    if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oRadiologyAssessment.GetScanDate())) > 24 % 2 years
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Is more than 2 years after the first brain radiation therapy treatment"));
                    end
                case "Post2YearFollowUp"
                    % - GetScanDate()
                    % -- Less than 2 years post treatment
                    if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oRadiologyAssessment.GetScanDate())) <= 24 % 2 years
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Less than 2 years after the first brain radiation therapy treatment"));
                    end
                    
                    if ~isempty(oParentPatient.GetApproximateDateOfDeath())
                        % -- After approximate date of death
                        if calmonths(between(oParentPatient.GetApproximateDateOfDeath(), oRadiologyAssessment.GetScanDate())) > 0
                            voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Is after the patient's approximate date of death"));
                        end
                        
                        % -- More than 6 months before approximate date of
                        % death
                        if calmonths(between(oParentPatient.GetApproximateDateOfDeath(), oRadiologyAssessment.GetScanDate())) < -6
                            voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "GetScanDate", "Post 2 year follow-up more than 6 months before approximate date of death"));
                        end
                    end
                otherwise
                    error(...
                        'RadiologyAssessment:Validate:InvalidValidationMode',...
                        'Unknown validation mode.');
            end
            
            % - voBrainMetastasisRadiologyAssessmentPerBrainMetastasis
            % -- not all BMs assessed
            dNumBMs = oParentPatient.GetNumberOfBrainMetastases();
            
            if dNumBMs ~= length(oRadiologyAssessment.voBrainMetastasisRadiologyAssessmentPerBrainMetastasis)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oRadiologyAssessment, "voBrainMetastasisRadiologyAssessmentPerBrainMetastasis", "Not all brain metastases assessed in radiology assessment"));
            end
            
            voValidationRecords = oRadiologyAssessment.voBrainMetastasisRadiologyAssessmentPerBrainMetastasis.Validate(oRadiologyAssessment.voBrainMetastasisRadiologyAssessmentPerBrainMetastasis, oParentPatient, oRadiologyAssessment, voValidationRecords);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
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

