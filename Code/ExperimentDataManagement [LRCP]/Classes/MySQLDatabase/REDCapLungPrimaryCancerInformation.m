classdef REDCapLungPrimaryCancerInformation < REDCapPrimaryCancerInformation
    %REDCapLungPrimaryCancerInformation
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        ePDL1Status (1,1) REDCapPDL1Status
        eALKStatus (1,1) REDCapBiomarkerStatus
        eEGFRStatus (1,1) REDCapBiomarkerStatus
        eROS1Status (1,1) REDCapBiomarkerStatus
        eBRAFStatus (1,1) REDCapBiomarkerStatus
        eKRASStatus (1,1) REDCapBiomarkerStatus
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapLungPrimaryCancerInformation(ePrimaryCancerSite, dtHistopathologyDate, eHistopathologyDifferentiation, eHistopathologyType, ePDL1Status, eALKStatus, eEGFRStatus, eROS1Status, eBRAFStatus, eKRASStatus)
            %obj = REDCapLungPrimaryCancerInformation(ePrimaryCancerSite, dtHistopathologyDate, eHistopathologyDifferentiation, eHistopathologyType, ePDL1Status, eALKStatus, eEGFRStatus, eROS1Status, eBRAFStatus, eKRASStatus)
            
            obj@REDCapPrimaryCancerInformation(ePrimaryCancerSite, dtHistopathologyDate, eHistopathologyDifferentiation, eHistopathologyType);
            
            
            obj.ePDL1Status = ePDL1Status;
            obj.eALKStatus = eALKStatus;
            obj.eEGFRStatus = eEGFRStatus;
            obj.eROS1Status = eROS1Status;
            obj.eBRAFStatus = eBRAFStatus;
            obj.eKRASStatus = eKRASStatus;
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

