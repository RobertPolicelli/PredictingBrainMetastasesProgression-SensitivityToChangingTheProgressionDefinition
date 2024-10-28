classdef REDCapLungCancerHistopathologyType
    %REDCapLungCancerHistopathologyType
    
    properties
        dREDCapCode
        sMySQLEnumString
    end
    
    
    enumeration
        SCLCPure (0, "SCLC (pure)")
        SCLCCombined (1, "SCLC (combined)")
        NSCLCAdeno (2, "NSCLC (adeno)")
        NSCLCSquamous (3, "NSCLC (squamous)")
        NSCLCLargeCell (4, "NSCLC (large cell)")
        NSCLCOther (5, "NSCLC (other)")
        Unknown (6, "unknown")
    end
    
    
    methods
        function enum = REDCapLungCancerHistopathologyType(dREDCapCode, sMySQLEnumString)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumString = sMySQLEnumString;
        end
        
        function sMySQLEnumString = GetMySQLEnumString(enum)
            sMySQLEnumString = enum.sMySQLEnumString;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapLungCancerHistopathologyType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapLungCancerHistopathologyType:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

