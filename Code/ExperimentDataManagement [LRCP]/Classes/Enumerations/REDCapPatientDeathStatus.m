classdef REDCapPatientDeathStatus
    %REDCapPatientDeathStatus
    
    properties
        dREDCapCode
        sMySQLEnumCode
    end
    
    
    enumeration
        Deceased (1, "yes")
        LikelyDeceased (2, "likely")
        NotDeceased (0, "no")
    end
    
    
    methods
        function enum = REDCapPatientDeathStatus(dREDCapCode, sMySQLEnumCode)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumCode = sMySQLEnumCode;
        end
        
        
    end
    
    
    methods (Static)
        
        function enum = GetFromMySQLEnumCode(sMySQLEnumCode)
            veEnums = enumeration('REDCapPatientDeathStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumCode == sMySQLEnumCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapPatientDeathStatus:GetFromMySQLEnumCode:MatchNotFound',...
                    "No match for MySQL Code: " + sMySQLEnumCode);
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapPatientDeathStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapPatientDeathStatus:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

