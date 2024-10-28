classdef PseudoProgressionConclusion
    %PseudoProgressionConclusion
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)      
        voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis (:,1) BrainMetastasisPseudoProgressionConclusion = BrainMetastasisPseudoProgressionConclusion.empty(0,1)
        
        sREDCapDataCollectionNotes (1,1) string
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = PseudoProgressionConclusion(voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis, sREDCapDataCollectionNotes)
            %obj = PseudoProgressionConclusion(voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis, sREDCapDataCollectionNotes)
            
            obj.voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis = voBrainMetastasisPseudoProgressionConclusionPerBrainMetastasis;
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
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
            
            vsDataCollectionNotes = string(tOutput.data_collection_notes);
            
            if isempty(vsDataCollectionNotes)
                oConclusion = PseudoProgressionConclusion.empty;
            else
                if ~all(vsDataCollectionNotes == vsDataCollectionNotes(1))
                    error(...
                        'PseudoProgressionConclusion:LoadFromDatabaseByPatientStudyId:DataCollectionNotes',...
                        'Data collection notes should be equivalent across all pseudo progression conclusions for the same patient.');
                end
                
                voConclusionsPerBrainMetastases = BrainMetastasisPseudoProgressionConclusion.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                
                tBMOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastases", ["fk_brain_metastases_patient_study_id" "brain_metastasis_number"], ...
                    SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                    "brain_metastasis_number",...
                    {dPatientStudyId}));
                
                if size(tOutput,1) ~= length(voConclusionsPerBrainMetastases)
                    error(...
                        'PseudoProgressionConclusion:LoadFromDatabaseByPatientStudyId:NumberOfBrainMetastasesMismatch',...
                        'Number of conclusions per brain metastasis not equal to the number of brain metastases for the patient.');
                end
            
                oConclusion = PseudoProgressionConclusion(...
                    voConclusionsPerBrainMetastases,...
                    vsDataCollectionNotes(1));
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

