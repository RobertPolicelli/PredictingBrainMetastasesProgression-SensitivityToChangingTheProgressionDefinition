classdef REDCapRadiationCourseIntent
    %REDCapRadiationCourseIntent
    
    properties
        dREDCapCode
    end
    
    
    enumeration
        Palliative (0)
        Curative (1)
        CurativeWithChemotherapy (2)
        Radical (3)
        Unknown (4)
    end
    
    
    methods
        function enum = REDCapRadiationCourseIntent(dREDCapCode)
            enum.dREDCapCode = dREDCapCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapRadiationCourseIntent');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapRadiationCourseIntent:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

