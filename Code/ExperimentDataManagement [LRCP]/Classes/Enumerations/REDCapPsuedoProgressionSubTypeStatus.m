classdef REDCapPsuedoProgressionSubTypeStatus
    %REDCapPsuedoProgressionSubTypeStatus
    
    properties
        dREDCapCode
    end
    
    
    enumeration
        No (0)
        Suspected (2)
        Yes (1)
        Unknown (3)
    end
    
    
    methods
        function enum = REDCapPsuedoProgressionSubTypeStatus(dREDCapCode)
            enum.dREDCapCode = dREDCapCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapPsuedoProgressionSubTypeStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapPsuedoProgressionSubTypeStatus:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

