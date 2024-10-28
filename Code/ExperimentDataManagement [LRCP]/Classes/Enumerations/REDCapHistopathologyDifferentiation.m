classdef REDCapHistopathologyDifferentiation
    %REDCapHistopathologyDifferentiation
    
    properties
        dREDCapCode
    end
    
    
    enumeration
        PoorlyDifferentiated (0)
        ModeratelyDifferentiated (1)
        HighlyDifferentiated (2)
        Unknown (3)
    end
    
    
    methods
        function enum = REDCapHistopathologyDifferentiation(dREDCapCode)
            enum.dREDCapCode = dREDCapCode;
        end
        
        function dREDCapCode = GetREDCapCode(enum)
            dREDCapCode = enum.dREDCapCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapHistopathologyDifferentiation');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapHistopathologyDifferentiation:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

