classdef REDCapPreTreatmentRadiologyAssessment < REDCapRadiologyAssessment
    %REDCapPreTreatmentRadiologyAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        bIsParenchymal (1,1) logical
        bSurgicalCavityPresent (1,1) logical
        bEdemaPresent (1,1) logical
        bModerateOrHighMassEffectPresent (1,1) logical
        eAppearanceScore (1,1) REDCapBrainMetastasisAppearanceScore
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapPreTreatmentRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, bIsParenchymal, bSurgicalCavityPresent, bEdemaPresent, bModerateOrHighMassEffectPresent, eAppearanceScore)
            %obj = REDCapPreTreatmentRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, bIsParenchymal, bSurgicalCavityPresent, bEdemaPresent, bModerateOrHighMassEffectPresent, eAppearanceScore
            
            obj@REDCapRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm);
            
            obj.bIsParenchymal = bIsParenchymal;
            obj.bSurgicalCavityPresent = bSurgicalCavityPresent;
            obj.bEdemaPresent = bEdemaPresent;
            obj.bModerateOrHighMassEffectPresent = bModerateOrHighMassEffectPresent;
            obj.eAppearanceScore = eAppearanceScore;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function bIsParenchymal = IsParenchymal(obj)
            bIsParenchymal = obj.bIsParenchymal;
        end
        
        function bSurgicalCavityPresent = IsSurgicalCavityPresent(obj)
            bSurgicalCavityPresent = obj.bSurgicalCavityPresent;
        end
        
        function eAppearanceScore = GetAppearanceScore(obj)
            eAppearanceScore = obj.eAppearanceScore;
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

