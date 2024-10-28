classdef DataValidationRecordReviewStatus
    %DataValidationRecordReviewStatus
    
    properties
        sSpreadsheetEnumValue
    end
    
    
    enumeration
        NotReviewed (string.empty)
        Ignore ("Ignore")
        IgnoreCorrectionRequired ("Ignore correction needed")
        Error ("Error")
    end
    
    
    methods
        function enum = DataValidationRecordReviewStatus(sSpreadsheetEnumValue)
            enum.sSpreadsheetEnumValue = sSpreadsheetEnumValue;
        end
    end
    
    
    methods (Static) 
        
        function enum = GetEnumFromSpreadsheetEnumValue(sSpreadsheetEnumValue)
            veEnums = enumeration('DataValidationRecordReviewStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sSpreadsheetEnumValue == sSpreadsheetEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'DataValidationRecordReviewStatus:GetEnumFromSpreadsheetEnumValue:MatchNotFound',...
                    "No match for spreadsheet enum value: " + string(sSpreadsheetEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

