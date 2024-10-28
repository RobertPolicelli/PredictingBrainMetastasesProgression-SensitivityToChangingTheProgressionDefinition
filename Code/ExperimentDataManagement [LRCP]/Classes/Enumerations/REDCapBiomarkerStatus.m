classdef REDCapBiomarkerStatus
    %REDCapBiomarkerStatus
    
    properties
        dREDCapCode
    end
    
    
    enumeration
        Positive (1)
        Negative (0)
        Unknown (2)
    end
    
    
    methods
        function enum = REDCapBiomarkerStatus(dREDCapCode)
            enum.dREDCapCode = dREDCapCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapBiomarkerStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapBiomarkerStatus:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

