classdef PinnacleRegistrationSpecification
    %PinnacleRegistrationSpecification
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sMRScanName (1,1) string = ""
        dtMRScanTime (1,1) duration
        eScanType (1,1) PinnacleRegistrationSpecificationScanType
        
        vdTransformTranslation_cm (1,3) double
        vdTransformRotation_deg (1,3) double
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = PinnacleRegistrationSpecification(sMRScanName, dtMRScanTime, eScanType, vdTransformTranslation_cm, vdTransformRotation_deg)        
            arguments
                sMRScanName (1,1) string
                dtMRScanTime (1,1) duration
                eScanType (1,1) PinnacleRegistrationSpecificationScanType
                vdTransformTranslation_cm (1,3) double {mustBeFinite}
                vdTransformRotation_deg (1,3) double {mustBeFinite}
            end
            
            obj.sMRScanName = sMRScanName;
            obj.dtMRScanTime = dtMRScanTime;
            obj.eScanType = eScanType;
            obj.vdTransformTranslation_cm = vdTransformTranslation_cm;
            obj.vdTransformRotation_deg = vdTransformRotation_deg;
        end
        
        function vdTransformRotation_deg = GetTransformRotation_deg(obj)
            vdTransformRotation_deg = obj.vdTransformRotation_deg;
        end
        
        function vdTransformTranslation_mm = GetTransformTranslation_mm(obj)
            vdTransformTranslation_mm = obj.vdTransformTranslation_cm .* (10 / 1); % cm to mm
        end
        
        function eScanType = GetScanType(obj)
            eScanType = obj.eScanType; 
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

