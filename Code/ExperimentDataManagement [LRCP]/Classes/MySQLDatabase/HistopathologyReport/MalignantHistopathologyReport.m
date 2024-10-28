classdef (Abstract) MalignantHistopathologyReport < HistopathologyReport
    %HistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eHistopathologyDifferentiation (1,1) HistopathologyDifferentiation
        eHistopathologyType (1,1) HistopathologyType
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = MalignantHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType)
            %obj = MalignantHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType)
            
            obj@HistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey);
            
            obj.eHistopathologyDifferentiation = eHistopathologyDifferentiation;
            obj.eHistopathologyType = eHistopathologyType;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                
        function eHistopathologyDifferentiation = GetHistopathologyDifferentiation(obj)
            eHistopathologyDifferentiation = obj.eHistopathologyDifferentiation;
        end
        
        function eHistopathologyType = GetHistopathologyType(obj)
            eHistopathologyType = obj.eHistopathologyType;
        end
    end
    
    
    methods (Access = public, Static)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                       PROTECTED METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function voValidationRecords = ValidateReport(obj, oParentPatient, voValidationRecords)
            voValidationRecords = ValidateReport@HistopathologyReport(obj, oParentPatient, voValidationRecords);
            
            % - eHistopathologyDifferentiation
            % none
            
            % - eHistopathologyType
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

