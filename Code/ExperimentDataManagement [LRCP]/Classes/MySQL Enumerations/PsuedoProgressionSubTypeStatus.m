classdef PsuedoProgressionSubTypeStatus
    %PsuedoProgressionSubTypeStatus
    
    properties
        sREDCapEnumValue
        sMySQLEnumValue
    end

    
    enumeration
        No ("No", "no")
        Suspected ("Suspected", "suspected")
        Yes ("Yes", "yes")
        Unknown ("Unknown", "unknown")
    end
    
    
    methods
        function enum = PsuedoProgressionSubTypeStatus(sREDCapEnumValue, sMySQLEnumValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('PsuedoProgressionSubTypeStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'PsuedoProgressionSubTypeStatus:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

