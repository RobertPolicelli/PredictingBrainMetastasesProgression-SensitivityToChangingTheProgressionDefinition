classdef BreastCancerBrainMetastasisHistopathologyReport < MalignantBrainMetastasisHistopathologyReport & BreastCancerHistopathologyReport
    %BreastCancerBrainMetastasisHistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BreastCancerBrainMetastasisHistopathologyReport(dtDate, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, eEstrogenReceptorStatus, eProgesteroneReceptorStatus, eHer2NeuReceptorStatus, oSampledBM, bNecrosisPresent)
            %obj = BreastCancerBrainMetastasisHistopathologyReport(dtDate, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKeym eHistopathologyDifferentiation, eHistopathologyType, eEstrogenReceptorStatus, eProgesteroneReceptorStatus, eHer2NeuReceptorStatus, oSampledBM, bNecrosisPresent)
            
            obj@BreastCancerHistopathologyReport(dtDate, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, eEstrogenReceptorStatus, eProgesteroneReceptorStatus, eHer2NeuReceptorStatus);
            obj@MalignantBrainMetastasisHistopathologyReport(dtDate, PrimaryCancerSite.Breast, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, oSampledBM, bNecrosisPresent);
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
            voValidationRecords = ValidateReport@MalignantBrainMetastasisHistopathologyReport(obj, oParentPatient, voValidationRecords);
            voValidationRecords = ValidateReport@BreastCancerHistopathologyReport(obj, oParentPatient, voValidationRecords);
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

