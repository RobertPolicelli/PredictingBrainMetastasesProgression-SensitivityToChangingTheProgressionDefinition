classdef DataValidationRecord
    %DataValidationRecord
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sObjectClass (1,1) string
        m2dPrimaryKeyPerObjectPerKey (:,:) double
                
        sObjectProperty (1,1) string
        sValidationErrorCode (1,1) string       
                
        eReviewStatus (1,1) DataValidationRecordReviewStatus = DataValidationRecordReviewStatus.NotReviewed
        sReviewNotes (1,1) string = ""
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DataValidationRecord(varargin)
            %obj = DataValidationRecord(oObject, sObjectProperty, sValidationErrorCode)
            %obj = DataValidationRecord(sObjectClass, m2dPrimaryKeyPerObjectPerKey, sObjectProperty, sValidationErrorCode, eReviewStatus, sReviewNotes)
            
            if nargin == 3
                voObjects = varargin{1};
                sObjectProperty = varargin{2};
                sValidationErrorCode = varargin{3};
                
                obj.sObjectClass = class(voObjects(1));
                
                vdPrimaryKeys = voObjects(1).GetMySQLPrimaryKey();
                dNumObjects = length(voObjects);
                
                m2dPrimaryKeyPerObjectPerKey = zeros(dNumObjects,length(vdPrimaryKeys));
                
                for dObjIndex=1:dNumObjects
                    m2dPrimaryKeyPerObjectPerKey(dObjIndex,:) = voObjects(dObjIndex).GetMySQLPrimaryKey();
                end
                
                obj.m2dPrimaryKeyPerObjectPerKey = m2dPrimaryKeyPerObjectPerKey;
                obj.sObjectProperty = sObjectProperty;
                obj.sValidationErrorCode = sValidationErrorCode;
            else
                obj.sObjectClass = varargin{1};
                obj.m2dPrimaryKeyPerObjectPerKey = varargin{2};
                obj.sObjectProperty = varargin{3};
                obj.sValidationErrorCode = varargin{4};
                obj.eReviewStatus = varargin{5};
                obj.sReviewNotes = varargin{6};
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        
    end
    
    
    methods (Access = public, Static)
        
        function voValidationRecords = ProcessValidationError(voValidationRecords, oDataValidationRecord)
            % check if record already exists, if not added it
            
            bFound = false;
            
            for dSearchIndex=1:length(voValidationRecords)
                if voValidationRecords(dSearchIndex).Matches(oDataValidationRecord)
                    bFound = true;
                    break;
                end
            end
            
            if ~bFound
                voValidationRecords = [voValidationRecords; oDataValidationRecord];
            end
        end
        
        function voValidationRecords = LoadFromSpreadsheet(sFilepath)
            c2xSpreadsheetData = readcell(sFilepath);
            
            vsHeaders = string(c2xSpreadsheetData(1,:));            
            c2xSpreadsheetData = c2xSpreadsheetData(2:end,:);
            dNumRecords = size(c2xSpreadsheetData,1);
            
            c1oValidationRecords = cell(dNumRecords,1);
            
            for dRecordIndex=1:dNumRecords
                c1oValidationRecords{dRecordIndex} = DataValidationRecord(...
                    c2xSpreadsheetData{dRecordIndex, vsHeaders == "Object Class"},...
                    transpose(str2double(string(strsplit(c2xSpreadsheetData{dRecordIndex, vsHeaders == "MySQL Primary Key"},',')))),...
                    c2xSpreadsheetData{dRecordIndex, vsHeaders == "Object Property"},...
                    c2xSpreadsheetData{dRecordIndex, vsHeaders == "Validation Error"},...
                    DataValidationRecordReviewStatus.GetEnumFromSpreadsheetEnumValue(c2xSpreadsheetData{dRecordIndex, vsHeaders == "Response"}),...
                    c2xSpreadsheetData{dRecordIndex, vsHeaders == "Notes"});
            end
            
            voValidationRecords = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oValidationRecords);
        end
        
        function SaveToSpreadsheet(voValidationRecords, sFilePath)
            vsHeaders = ["Object Class", "MySQL Primary Key", "Object Property", "Validation Error"];
            c2xData = cell(length(voValidationRecords),4);
            
            for dRecordIndex=1:length(voValidationRecords)
                c2xData{dRecordIndex,1} = voValidationRecords(dRecordIndex).sObjectClass;
                c2xData{dRecordIndex,2} = strjoin(string(voValidationRecords(dRecordIndex).m2dPrimaryKeyPerObjectPerKey), ", ");
                c2xData{dRecordIndex,3} = voValidationRecords(dRecordIndex).sObjectProperty;
                c2xData{dRecordIndex,4} = voValidationRecords(dRecordIndex).sValidationErrorCode;
            end
            
            writematrix(vsHeaders, sFilePath);
            writecell(c2xData, sFilePath, 'Range', 'A2');
        end
        
        function voValidationRecords = RemoveNonIgnoredRecords(voValidationRecords)
            vbRemove = false(size(voValidationRecords));
            
            for dValidationIndex=1:length(voValidationRecords)
                if voValidationRecords(dValidationIndex).eReviewStatus == DataValidationRecordReviewStatus.Error || voValidationRecords(dValidationIndex).eReviewStatus == DataValidationRecordReviewStatus.NotReviewed
                    vbRemove(dValidationIndex) = true;
                end
            end
            
            voValidationRecords = voValidationRecords(~vbRemove);
        end
        
        function MustHaveNoErrors(voValidationRecords)
            for dValidationIndex=1:length(voValidationRecords)
                if voValidationRecords(dValidationIndex).eReviewStatus == DataValidationRecordReviewStatus.Error || voValidationRecords(dValidationIndex).eReviewStatus == DataValidationRecordReviewStatus.NotReviewed
                    error(...
                        'DataValidationRecord:MustHaveNoErrors:ErrorOrNoReviewFound',...
                        'Data validation record with error or not reviewed found.');
                end
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function bBool = Matches(obj, oCompareObj)
            bBool =...
                obj.sObjectClass == oCompareObj.sObjectClass &&...
                all(size(obj.m2dPrimaryKeyPerObjectPerKey) == size(oCompareObj.m2dPrimaryKeyPerObjectPerKey)) &&...
                all(obj.m2dPrimaryKeyPerObjectPerKey(:) == oCompareObj.m2dPrimaryKeyPerObjectPerKey(:)) &&...
                obj.sObjectProperty == oCompareObj.sObjectProperty &&...
                obj.sValidationErrorCode == oCompareObj.sValidationErrorCode;            
        end
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

