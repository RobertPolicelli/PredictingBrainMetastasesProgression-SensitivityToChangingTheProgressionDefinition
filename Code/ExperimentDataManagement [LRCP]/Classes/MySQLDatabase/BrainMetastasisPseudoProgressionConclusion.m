classdef BrainMetastasisPseudoProgressionConclusion
    %BrainMetastasisPseudoProgressionConclusion
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        eConfirmationStatus (1,1) PseudoProgressionConfirmationStatus
        
        eRadiationNecrosisStatus PseudoProgressionSubTypeStatus {ValidationUtils.MustBeEmptyOrScalar} = PseudoProgressionSubTypeStatus.empty % only set if eConfirmationStatus is Yes
        eAdverseRadiationEffectStatus PseudoProgressionSubTypeStatus {ValidationUtils.MustBeEmptyOrScalar} = PseudoProgressionSubTypeStatus.empty % only set if eConfirmationStatus is Yes
        
        sConfirmationMethod string {ValidationUtils.MustBeEmptyOrScalar}
        
        dMySQLPrimaryKey (1,1) double % id_pseudo_progression_conclusions
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainMetastasisPseudoProgressionConclusion(eConfirmationStatus, eRadiationNecrosisStatus, eAdverseRadiationEffectStatus, sConfirmationMethod, dMySQLPrimaryKey)
            %obj = BrainMetastasisPseudoProgressionConclusion(eConfirmationStatus, eRadiationNecrosisStatus, eAdverseRadiationEffectStatus, sConfirmationMethod, dMySQLPrimaryKey)
            
            if eConfirmationStatus == REDCapPseudoProgressionConfirmationStatus.Yes
                if isempty(eRadiationNecrosisStatus) || isempty(eAdverseRadiationEffectStatus)
                    error(...
                        'BrainMetastasisPseudoProgressionConclusion:Constructor:ConfirmationDetailsMissing',...
                        'If eConfirmationStatus is Yes, then eRadiationNecrosisStatus and eAdverseRadiationEffectStatus must be provided.');
                end
            end
            
            obj.eConfirmationStatus = eConfirmationStatus;
            obj.eRadiationNecrosisStatus = eRadiationNecrosisStatus;
            obj.eAdverseRadiationEffectStatus = eAdverseRadiationEffectStatus;
            obj.sConfirmationMethod = sConfirmationMethod;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function eConfirmationStatus = GetConfirmationStatus(obj)
            eConfirmationStatus = obj.eConfirmationStatus;
        end
        
        function eRadiationNecrosisStatus = GetRadiationNecrosisStatus(obj)
            eRadiationNecrosisStatus = obj.eRadiationNecrosisStatus;
        end
        
        function eAdverseRadiationEffectStatus = GetAdverseRadiationEffectStatus(obj)
            eAdverseRadiationEffectStatus = obj.eAdverseRadiationEffectStatus;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voConclusions = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double {mustBeInteger, mustBePositive}
            end
                        
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "pseudo_progression_conclusions", [], ...
                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                "fk_pseudo_prog_conclusions_brain_metastases_patient_study_id",...
                {dPatientStudyId}),...
                "ORDER BY fk_pseudo_prog_conclusions_brain_metastasis_number");
            
            dNumBMs = size(tOutput,1);
            
            if dNumBMs == 0
                voConclusions = BrainMetastasisPseudoProgressionConclusion.empty;
            else
                c1oConclusions = cell(dNumBMs,1);
                
                for dConclusionIndex=1:dNumBMs
                    c1oConclusions{dConclusionIndex} = BrainMetastasisPseudoProgressionConclusion(...
                        PseudoProgressionConfirmationStatus.GetEnumFromMySQLEnumValue(tOutput.pseudo_progression_confirmed{dConclusionIndex}),...
                        PseudoProgressionSubTypeStatus.GetEnumFromMySQLEnumValue(tOutput.is_radiation_necrosis{dConclusionIndex}),...
                        PseudoProgressionSubTypeStatus.GetEnumFromMySQLEnumValue(tOutput.is_adverse_radiation_effect{dConclusionIndex}),...
                        tOutput.confirmation_method{dConclusionIndex},...
                        tOutput.id_pseudo_progression_conclusions{dConclusionIndex});
                end
                
                voConclusions = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oConclusions);
            end
        end
        
        function voValidationRecords = Validate(voBrainMetastasisPseudoProgressionConclusions, oParentPatient, oParentPseudoProgressionConclusionAssessment, voValidationRecords)
            for dConclusionIndex=1:length(voBrainMetastasisPseudoProgressionConclusions)
                oBrainMetastasisPseudoProgressionConclusion = voBrainMetastasisPseudoProgressionConclusions(dConclusionIndex);
                
                % - eConfirmationStatus
                % -- is not
                % "PseudoProgressionConfirmationStatus.NoProgressionOrPsuedoProgressionWasObserved"
                % even though no follow-ups recorded
                if isempty(oParentPatient.GetFollowUpRadiologyAssessments()) &&...
                        isempty(oParentPatient.GetPost2YearFollowUpRadiologyAssessment()) &&...
                        oBrainMetastasisPseudoProgressionConclusion.eConfirmationStatus ~= PseudoProgressionConfirmationStatus.NoProgressionOrPsuedoProgressionWasObserved
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oBrainMetastasisPseudoProgressionConclusion, "eConfirmationStatus", "Must be NoProgressionOrPsuedoProgressionWasObserved if no follow-up radiology assessments were recorded"));
                end
                
                % - eRadiationNecrosisStatus
                % none
                
                % - eAdverseRadiationEffectStatus
                % none
                
                % - sConfirmationMethod
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

