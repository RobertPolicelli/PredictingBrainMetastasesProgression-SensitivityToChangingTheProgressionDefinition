classdef BreastCancerHistopathologyReport < MalignantHistopathologyReport
    %BreastCancerHistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eEstrogenReceptorStatus (1,1) BiomarkerStatus
        eProgesteroneReceptorStatus (1,1) BiomarkerStatus
        eHer2NeuReceptorStatus (1,1) BiomarkerStatus
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BreastCancerHistopathologyReport(dtDate, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, eEstrogenReceptorStatus, eProgesteroneReceptorStatus, eHer2NeuReceptorStatus)
            %obj = BreastCancerHistopathologyReport(dtDate, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, eEstrogenReceptorStatus, eProgesteroneReceptorStatus, eHer2NeuReceptorStatus)
            
            obj@MalignantHistopathologyReport(dtDate, PrimaryCancerSite.Breast, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType);
                        
            obj.eEstrogenReceptorStatus = eEstrogenReceptorStatus;
            obj.eProgesteroneReceptorStatus = eProgesteroneReceptorStatus;
            obj.eHer2NeuReceptorStatus = eHer2NeuReceptorStatus;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
    end
    
    
    methods (Access = public, Static)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                       PROTECTED METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function voValidationRecords = ValidateReport(obj, oParentPatient, voValidationRecords)            
            voValidationRecords = ValidateReport@MalignantHistopathologyReport(obj, oParentPatient, voValidationRecords);
            
            % - eEstrogenReceptorStatus
            % none
            
            % - eProgesteroneReceptorStatus
            % none
            
            % - eHer2NeuReceptorStatus
            % none
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

