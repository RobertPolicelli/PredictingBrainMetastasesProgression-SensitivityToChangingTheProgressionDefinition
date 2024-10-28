classdef CountableUncountable
    %CountableUncountable
    
    properties
        sREDCapEnumValue
        sMySQLValue
    end
    
    
    enumeration
        Countable ("Countable", true)
        Uncountable ("Uncountable", false)
    end
    
    
    methods
        function enum = CountableUncountable(sREDCapEnumValue, sMySQLValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sMySQLValue = sMySQLValue;
        end
                
        function sREDCapEnumValue = GetREDCapCode(enum)
            sREDCapEnumValue = enum.sREDCapEnumValue;
        end
        
        function sMySQLValue = GetMySQLValue(enum)
            sMySQLValue = enum.sMySQLValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('CountableUncountable');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'CountableUncountable:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

