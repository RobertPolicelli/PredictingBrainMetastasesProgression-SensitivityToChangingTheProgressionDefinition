classdef REDCapFirstBrainRadiationCourseBeamSet < REDCapBeamSet
    %REDCapFirstBrainRadiationCourseBeamSet
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dPrescribedDose_Gy (1,1) double {mustBeInteger, mustBePositive} = 1
        
        vdBrainMetastasisNumbersTargeted (:,1) double {mustBeInteger, mustBePositive}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapFirstBrainRadiationCourseBeamSet(dPrescribedDose_Gy, dNumberOfFractions, vdBrainMetastasisNumbersTargeted)
            %obj = REDCapFirstBrainRadiationCourseBeamSet(dPrescribedDose_Gy, dNumberOfFractions, vdBrainMetastasisNumbersTargeted)
            obj@REDCapBeamSet(dNumberOfFractions);
            
            obj.dPrescribedDose_Gy = dPrescribedDose_Gy;
            obj.vdBrainMetastasisNumbersTargeted = vdBrainMetastasisNumbersTargeted;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        
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

