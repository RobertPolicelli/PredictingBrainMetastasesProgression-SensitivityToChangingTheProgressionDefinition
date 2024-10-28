classdef YesNo
    %YesNo
    
    properties
        sREDCapEnumValue
        sMySQLValue
    end
    
    
    enumeration
        Yes ("Yes", true)
        No ("No", false)
        Null ("Null", logical.empty)
    end
    
    
    methods
        function enum = YesNo(sREDCapEnumValue, sMySQLValue)
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
            if ismissing(sREDCapEnumValue)
                sREDCapEnumValue = "Null";
            end
            
            veEnums = enumeration('YesNo');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'YesNo:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

