classdef BiomarkerStatus
    %BiomarkerStatus
    
    properties
        sREDCapEnumValue
        sMySQLEnumValue
    end
    
    
    enumeration
        Positive ("Positive", "positive")
        Negative ("Negative", "negative")
        Unknown ("Unknown", "unknown")
    end
    
    
    methods
        function enum = BiomarkerStatus(sREDCapEnumValue, sMySQLEnumValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('BiomarkerStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'BiomarkerStatus:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            arguments
                sMySQLEnumValue (1,1) string
            end
            
            veEnums = enumeration('BiomarkerStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'BiomarkerStatus:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL Code: " + string(sMySQLEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

