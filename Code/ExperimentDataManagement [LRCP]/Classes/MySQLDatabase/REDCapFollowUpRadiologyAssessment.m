classdef REDCapFollowUpRadiologyAssessment < REDCapRadiologyAssessment
    %REDCapFollowUpRadiologyAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        
        ePseudoProgressionStatus (1,1) REDCapPseudoProgressionStatus
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapFollowUpRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, ePseudoProgressionStatus)
            %obj = REDCapFollowUpRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, ePseudoProgressionStatus)
            
            obj@REDCapRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm);         
            
            obj.ePseudoProgressionStatus = ePseudoProgressionStatus;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function ePseudoProgressionStatus = GetPseudoProgressionStatus(obj)
            ePseudoProgressionStatus = obj.ePseudoProgressionStatus;
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

