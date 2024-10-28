classdef NonMalignantBrainMetastasisHistopathologyReport < BrainMetastasisHistopathologyReport
    %NonMalignantBrainMetastasisHistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = NonMalignantBrainMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, oSampledBM, bNecrosisPresent)
            %obj = NonMalignantBrainMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, oSampledBM, bNecrosisPresent)
            
            obj@BrainMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, oSampledBM, bNecrosisPresent);
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
            voValidationRecords = ValidateReport@BrainMetastasisHistopathologyReport(obj, oParentPatient, voValidationRecords);
            
            % - dtDate
            % -- should only be after first brain metastasis radiation, as
            % would be malignant otherwise
            if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), obj.dtDate)) < 0
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(obj, "dtDate", "Non-malignant brain metastasis before treatment"));
            end
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

