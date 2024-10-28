classdef ExtracranialHistopathologySource
    %ExtracranialHistopathologySource
    
    properties
        sREDCapEnumValue
        sMySQLEnumValue
    end
    
    
    enumeration
        PrimaryCancer ("Primary Cancer", "primary cancer")
        ExtracranialMetastasis ("Extracranial Metastasis", "extracranial metastasis")
    end
    
    
    methods
        function enum = ExtracranialHistopathologySource(sREDCapEnumValue, sMySQLEnumValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sREDCapEnumValue = GetREDCapEnumValue(enum)
            sREDCapEnumValue = enum.sREDCapEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('ExtracranialHistopathologySource');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'ExtracranialHistopathologySource:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

