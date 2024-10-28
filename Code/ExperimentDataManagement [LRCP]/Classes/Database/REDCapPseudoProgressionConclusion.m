classdef REDCapPseudoProgressionConclusion
    %REDCapPseudoProgressionConclusion
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        eConfirmationStatus (1,1) REDCapPseudoProgressionConfirmationStatus
        
        eRadiationNecrosisStatus REDCapPsuedoProgressionSubTypeStatus {ValidationUtils.MustBeEmptyOrScalar} % only set if eConfirmationStatus is Yes
        eAdverseRadiationEffectStatus REDCapPsuedoProgressionSubTypeStatus {ValidationUtils.MustBeEmptyOrScalar} % only set if eConfirmationStatus is Yes
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapPseudoProgressionConclusion(eConfirmationStatus, eRadiationNecrosisStatus, eAdverseRadiationEffectStatus)
            %obj = REDCapPseudoProgressionConclusion(eConfirmationStatus, eRadiationNecrosisStatus, eAdverseRadiationEffectStatus)
            
            if eConfirmationStatus == REDCapPseudoProgressionConfirmationStatus.Yes
                if isempty(eRadiationNecrosisStatus) || isempty(eAdverseRadiationEffectStatus)
                    error(...
                        'REDCapPseudoProgressionConclusion:Constructor:ConfirmationDetailsMissing',...
                        'If eConfirmationStatus is Yes, then eRadiationNecrosisStatus and eAdverseRadiationEffectStatus must be provided.');
                end
            end
            
            obj.eConfirmationStatus = eConfirmationStatus;
            obj.eRadiationNecrosisStatus = eRadiationNecrosisStatus;
            obj.eAdverseRadiationEffectStatus = eAdverseRadiationEffectStatus;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function eConfirmationStatus = GetConfirmationStatus(obj)
            eConfirmationStatus = obj.eConfirmationStatus;
        end
    end
    
    
    methods (Access = public, Static)
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

