classdef SystemicTherapy
    %SystemicTherapy
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)   
        dtStartDate datetime {ValidationUtils.MustBeEmptyOrScalar} % if empty, start date was not known
        
        eType (1,1) SystemicTherapyType
        sTypeOther string {ValidationUtils.MustBeEmptyOrScalar} % only set if eType == SystemicTherapyType.Other
        
        bWasRadiosensitizer (1,1) logical
        
        sTherapyAgent string {ValidationUtils.MustBeEmptyOrScalar} % empty if not known
                   
        sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}        
        dREDCapRepeatInstance (1,1) double {mustBeInteger, mustBePositive} = 1
        
        dMySQLPrimaryKey (1,1) double % id_systemic_therapies
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = SystemicTherapy(dtStartDate, eType, sTypeOther, bWasRadiosensitizer, sTherapyAgent, sREDCapDataCollectionNotes, dREDCapRepeatInstance, dMySQLPrimaryKey)
            %obj = SystemicTherapy(dtStartDate, eType, sTypeOther, bWasRadiosensitizer, sTherapyAgent, sREDCapDataCollectionNotes, dREDCapRepeatInstance, dMySQLPrimaryKey)
            arguments
                dtStartDate datetime {ValidationUtils.MustBeEmptyOrScalar}                
                eType (1,1) SystemicTherapyType
                sTypeOther string {ValidationUtils.MustBeEmptyOrScalar}
                bWasRadiosensitizer (1,1) logical                
                sTherapyAgent string {ValidationUtils.MustBeEmptyOrScalar}
                sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}
                dREDCapRepeatInstance (1,1) double {mustBeInteger, mustBePositive}
                dMySQLPrimaryKey (1,1) double
            end
            
            obj.dtStartDate = dtStartDate;
            
            obj.eType = eType;
            obj.sTypeOther = sTypeOther;
            
            obj.bWasRadiosensitizer = bWasRadiosensitizer;
            
            obj.sTherapyAgent = sTherapyAgent;
            
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
            obj.dREDCapRepeatInstance = dREDCapRepeatInstance;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtStartDate = GetStartDate(obj)
            dtStartDate = obj.dtStartDate;
        end
        
        function eType = GetType(obj)
            eType = obj.eType;
        end
        
        function sTherapyAgent = GetTherapyAgent(obj)
            sTherapyAgent = obj.sTherapyAgent;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voTherapies = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            sTable = "systemic_therapies";
            sWhere = "WHERE systemic_therapies.fk_systemic_therapies_patient_study_id = " + string(dPatientStudyId);
            sOrderBy = "ORDER BY systemic_therapies.start_date";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTable, [], sWhere, sOrderBy);
            
            dNumTherapies = size(tOutput,1);
            
            if dNumTherapies == 0
                voTherapies = SystemicTherapy.empty;
            else
                c1oTherapies = cell(dNumTherapies,1);
                
                for dTherapyIndex=1:dNumTherapies
                    tOutputRow = tOutput(dTherapyIndex,:);
                    
                    dtStartDate = tOutputRow.start_date{1};
                    
                    eType = SystemicTherapyType.GetEnumFromMySQLEnumValue(tOutputRow.type{1});
                    sTypeOther = tOutputRow.type_other{1};
                    
                    bWasRadiosensitizer = tOutputRow.was_radiosensitizer{1};
                    
                    sTherapyAgent = tOutputRow.therapy_agent{1};
                    
                    chREDCapDataCollectionNotes = tOutputRow.data_collection_notes{1};
                    dREDCapRepeatInstance = tOutputRow.redcap_repeat_instance{1};
                    
                    c1oTherapies{dTherapyIndex} = SystemicTherapy(dtStartDate, eType, sTypeOther, bWasRadiosensitizer, sTherapyAgent, chREDCapDataCollectionNotes, dREDCapRepeatInstance, tOutputRow.id_systemic_therapies{1});
                end
                
                voTherapies = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oTherapies);
            end
        end
        
        function voValidationRecords = Validate(voSystemicTherapies, oParentPatient, voValidationRecords)
            for dTherapyIndex=1:length(voSystemicTherapies)
                oTherapy = voSystemicTherapies(dTherapyIndex);
                
                % - dtStartDate
                % -- is empty
                if isempty(oTherapy.dtStartDate)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTherapy, "dtStartDate", "Is empty"));
                end
                
                % -- more than 5 years before first brain radiation therapy
                if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oTherapy.dtStartDate)) < -5*12
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTherapy, "dtStartDate", "Is more than 5 years before the first brain radiation therapy"));
                end
                
                % -- after date of death
                if calmonths(between(oParentPatient.GetApproximateDateOfDeath(), oTherapy.dtStartDate)) > 0
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTherapy, "dtStartDate", "Is after the patient's approximate date of death"));
                end
                                
                % - eType
                % none
                
                % - sTypeOther
                % none
                
                % - bWasRadiosensitizer
                % none
                
                % - sTherapyAgent
                % none
                
                % - sREDCapDataCollectionNotes
                % none
                
                % - dREDCapRepeatInstance
                % none
            end
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

