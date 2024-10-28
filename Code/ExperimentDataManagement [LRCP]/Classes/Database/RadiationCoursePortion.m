classdef RadiationCoursePortion
    %RadiationCoursePortion
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dDose_Gy (1,1) double {mustBePositive} = 1
        
        dNumberOfFractionsPrescribed (1,1) double = 1
        dNumberOfFractionsDelivered (1,1) double = 0
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RadiationCoursePortion(dDose_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered)
            %obj = RadiationCoursePortion(dDose_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered)
            
            if dDose_Gy < 1 || dDose_Gy > 100
                error(...
                    'RadiationCoursePortion:Constructor:InvalidDose',...
                    'Invalid Dose');
            end
            
            if ~isnan(dNumberOfFractionsPrescribed) && (dNumberOfFractionsPrescribed <= 0 || dNumberOfFractionsPrescribed > 40)                
                error(...
                    'RadiationCoursePortion:Constructor:InvalidNumberOfFractionsPrescribed',...
                    'Invalid NumberOfFractionsPrescribed');
            end
            
            if ~isnan(dNumberOfFractionsDelivered) && (dNumberOfFractionsDelivered < 0 || dNumberOfFractionsDelivered > dNumberOfFractionsPrescribed)
                error(...
                    'RadiationCoursePortion:Constructor:InvalidNumberOfFractionsDelivered',...
                    'Invalid NumberOfFractionsDelivered');
            end
            
            obj.dDose_Gy = dDose_Gy;
            obj.dNumberOfFractionsPrescribed = dNumberOfFractionsPrescribed;
            obj.dNumberOfFractionsDelivered = dNumberOfFractionsDelivered;
        end 
                
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                
        function dDose_Gy = GetDose_Gy(obj)
            dDose_Gy = obj.dDose_Gy;
        end
        
        function dNumberOfFractionsPrescribed = GetNumberOfFractionsPrescribed(obj)
            dNumberOfFractionsPrescribed = obj.dNumberOfFractionsPrescribed;
        end
        
        function dNumberOfFractionsDelivered = GetNumberOfFractionsDelivered(obj)
            dNumberOfFractionsDelivered = obj.dNumberOfFractionsDelivered;
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

