classdef REDCapGender
    %REDCapGender
    
    properties
        dREDCapCode
        sMySQLEnumCode
    end
    
    
    enumeration
        Male (0, "male")
        Female (1, "female")
    end
    
    
    methods
        function enum = REDCapGender(dREDCapCode, sMySQLEnumCode)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumCode = sMySQLEnumCode;
        end
        
        function dREDCapCode = GetREDCapCode(enum)
            dREDCapCode = enum.dREDCapCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetFromMySQLEnumCode(sMySQLEnumCode)
            veEnums = enumeration('REDCapGender');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumCode == sMySQLEnumCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapGender:GetFromMySQLEnumCode:MatchNotFound',...
                    "No match for MySQL Code: " + sMySQLEnumCode);
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapGender');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapGender:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

