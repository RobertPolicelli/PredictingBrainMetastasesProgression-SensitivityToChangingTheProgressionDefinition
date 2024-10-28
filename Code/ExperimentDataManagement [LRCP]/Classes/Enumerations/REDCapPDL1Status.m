classdef REDCapPDL1Status
    %REDCapPDL1Status
    
    properties
        dREDCapCode
        sMySQLEnumString
    end
    
    
    enumeration
        StronglyPositive (2, "strongly positive")
        WeaklyPositive (1, "weakly positive")
        Negative (0, "negative")
        Unknown (3, "unknown")
    end
    
    
    methods
        function enum = REDCapPDL1Status(dREDCapCode, sMySQLEnumString)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumString = sMySQLEnumString;
        end
        
        function sMySQLEnumString = GetMySQLEnumString(enum)
            sMySQLEnumString = enum.sMySQLEnumString;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapPDL1Status');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapPDL1Status:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

