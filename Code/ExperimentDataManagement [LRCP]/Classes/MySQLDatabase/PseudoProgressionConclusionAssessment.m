classdef PseudoProgressionConclusionAssessment
    %PseudoProgressionConclusionAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)      
        voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis (:,1) BrainMetastasisPseudoProgressionConclusion = BrainMetastasisPseudoProgressionConclusion.empty(0,1)
        
        sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}
        
        dMySQLPrimaryKey (1,1) double % patient_study_id
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = PseudoProgressionConclusionAssessment(voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis, sREDCapDataCollectionNotes, dMySQLPrimaryKey)
            %obj = PseudoProgressionConclusionAssessment(voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis, sREDCapDataCollectionNotes, dMySQLPrimaryKey)
            
            obj.voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis = voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis;
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
        
        function oBrainMetastasisPseudoProgressionConclusion = GetBrainMetastasisPseudoProgressionConclusionForBrainMetastasis(obj, dBrainMetastasisNumber)
            arguments
                obj (1,1) PseudoProgressionConclusionAssessment
                dBrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
            oBrainMetastasisPseudoProgressionConclusion = obj.voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis(dBrainMetastasisNumber);
        end
    end
    
    
    methods (Access = public, Static)
        
        function oConclusion = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double {mustBeInteger, mustBePositive}
            end
                        
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "pseudo_progression_conclusions", ["data_collection_notes"], ...
                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                "fk_pseudo_prog_conclusions_brain_metastases_patient_study_id",...
                {dPatientStudyId}));
            
            c1sDataCollectionNotes = tOutput.data_collection_notes;
            
            if isempty(c1sDataCollectionNotes)
                oConclusion = PseudoProgressionConclusionAssessment.empty;
            else
                for dNotesIndex=1:length(c1sDataCollectionNotes)
                    if isempty(c1sDataCollectionNotes{dNotesIndex})
                        if ~isempty(c1sDataCollectionNotes{1})
                            error(...
                                'PseudoProgressionConclusionAssessment:LoadFromDatabaseByPatientStudyId:DataCollectionNotes',...
                                'Data collection notes should be equivalent across all pseudo progression conclusions for the same patient.');
                        end
                    else
                        if isempty(c1sDataCollectionNotes{1}) || (c1sDataCollectionNotes{dNotesIndex} ~= c1sDataCollectionNotes{1})
                            error(...
                                'PseudoProgressionConclusionAssessment:LoadFromDatabaseByPatientStudyId:DataCollectionNotes',...
                                'Data collection notes should be equivalent across all pseudo progression conclusions for the same patient.');
                        end
                    end
                end
                
                voConclusionsPerBrainMetastases = BrainMetastasisPseudoProgressionConclusion.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                
                tBMOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastases", ["fk_brain_metastases_patient_study_id" "brain_metastasis_number"], ...
                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                    "brain_metastasis_number",...
                    {dPatientStudyId}));
                
                if size(tOutput,1) ~= length(voConclusionsPerBrainMetastases)
                    error(...
                        'PseudoProgressionConclusionAssessment:LoadFromDatabaseByPatientStudyId:NumberOfBrainMetastasesMismatch',...
                        'Number of conclusions per brain metastasis not equal to the number of brain metastases for the patient.');
                end
            
                oConclusion = PseudoProgressionConclusionAssessment(...
                    voConclusionsPerBrainMetastases,...
                    c1sDataCollectionNotes{1},...
                    dPatientStudyId);
            end
        end
        
        function voValidationRecords = Validate(oPseudoProgressionConclusionAssessment, oParentPatient, voValidationRecords)
            % - sREDCapDataCollectionNotes
            % none
            
            % - voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis
            % -- same length as number of brain metastases
            if length(oPseudoProgressionConclusionAssessment.voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis) ~= oParentPatient.GetNumberOfBrainMetastases()
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPseudoProgressionConclusionAssessment, "voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis", "Each brain metastasis not represented"));
            end
            
            voValidationRecords = BrainMetastasisPseudoProgressionConclusion.Validate(oPseudoProgressionConclusionAssessment.voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis, oParentPatient, oPseudoProgressionConclusionAssessment, voValidationRecords);
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

