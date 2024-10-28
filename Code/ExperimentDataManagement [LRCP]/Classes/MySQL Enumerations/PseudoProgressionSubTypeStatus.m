classdef PseudoProgressionSubTypeStatus
    %PseudoProgressionSubTypeStatus
    
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
        function enum = PseudoProgressionSubTypeStatus(sREDCapEnumValue, sMySQLEnumValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('PseudoProgressionSubTypeStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'PseudoProgressionSubTypeStatus:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            if isempty(sMySQLEnumValue)
                enum = PseudoProgressionSubTypeStatus.empty;
            else
                veEnums = enumeration('PseudoProgressionSubTypeStatus');
                
                dMatchIndex = [];
                
                for dEnumIndex=1:length(veEnums)
                    if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                        dMatchIndex = dEnumIndex;
                        break;
                    end
                end
                
                if isempty(dMatchIndex)
                    error(...
                        'PseudoProgressionSubTypeStatus:GetEnumFromMySQLEnumValue:MatchNotFound',...
                        "No match for MySQL Code: " + string(sMySQLEnumValue));
                else
                    enum = veEnums(dMatchIndex);
                end
            end
        end
    end
end

