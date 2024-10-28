classdef REDCapPseudoProgressionStatus
    %REDCapPseudoProgressionStatus
    
    properties
        dREDCapCode
    end
    
    
    enumeration
        None (0)
        Suspected (1)
        Likely (2)
    end
    
    
    methods
        function enum = REDCapPseudoProgressionStatus(dREDCapCode)
            enum.dREDCapCode = dREDCapCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            arguments
                dREDCapCode (1,1) double
            end
            
            veEnums = enumeration('REDCapPseudoProgressionStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapPseudoProgressionStatus:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

