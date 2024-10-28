classdef REDCapRadiologyAssessment
    %REDCapRadiologyAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dtDate (1,1) datetime
        
        dRANOMeasurement_mm (1,1) double {mustBeNonnegative}
        
        dMaxAnteriorPosteriorDiameterMeasurement_mm (1,1) double {mustBeNonnegative}
        dMaxMediolateralDiameterMeasurement_mm (1,1) double {mustBeNonnegative}
        dMaxCraniocaudalDiameterMeasurement_mm (1,1) double {mustBeNonnegative}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm)
            %obj = REDCapRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm)
            
            obj.dtDate = dtDate;
            
            obj.dRANOMeasurement_mm = dRANOMeasurement_mm;
            
            obj.dMaxAnteriorPosteriorDiameterMeasurement_mm = dMaxAnteriorPosteriorDiameterMeasurement_mm;
            obj.dMaxMediolateralDiameterMeasurement_mm = dMaxMediolateralDiameterMeasurement_mm;
            obj.dMaxCraniocaudalDiameterMeasurement_mm = dMaxCraniocaudalDiameterMeasurement_mm;  
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDate = GetDate(obj)
            dtDate = obj.dtDate;
        end
        
        function [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] = GetPerpendicularMaxDiameterMeasurements_mm(obj)
            dMaxAnteriorPosteriorDiameterMeasurement_mm = obj.dMaxAnteriorPosteriorDiameterMeasurement_mm;
            dMaxMediolateralDiameterMeasurement_mm = obj.dMaxMediolateralDiameterMeasurement_mm;
            dMaxCraniocaudalDiameterMeasurement_mm = obj.dMaxCraniocaudalDiameterMeasurement_mm;
        end
        
        function dPseudoVolumetricMeasurement_mm = GetPseudoVolumetricMeasurement_mm(obj)
            dPseudoVolumetricMeasurement_mm = obj.dMaxAnteriorPosteriorDiameterMeasurement_mm * obj.dMaxMediolateralDiameterMeasurement_mm * obj.dMaxCraniocaudalDiameterMeasurement_mm;
        end
        
        function dRANOMeasurement_mm = GetRANOMeasurement_mm(obj)
            dRANOMeasurement_mm = obj.dRANOMeasurement_mm;
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

