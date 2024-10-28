classdef REDCapPseudoProgressionConfirmationStatus
    %REDCapPseudoProgressionConfirmationStatus
    
    properties
        dREDCapCode
        sMySQLEnumString
    end
    
    
    enumeration
        No (0, "no")
        Yes (1, "yes")
        Unknown (2, "unknown")
        NoProgressionOrPsuedoProgressionWasObserved (3, "no progression or psuedo-progression was observed")
    end
    
    
    methods
        function enum = REDCapPseudoProgressionConfirmationStatus(dREDCapCode, sMySQLEnumString)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumString = sMySQLEnumString;
        end
        
        function sMySQLEnumString = GetMySQLEnumString(enum)
            sMySQLEnumString = enum.sMySQLEnumString;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapPseudoProgressionConfirmationStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapPseudoProgressionConfirmationStatus:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

