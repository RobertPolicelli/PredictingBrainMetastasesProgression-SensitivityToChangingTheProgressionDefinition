classdef REDCapSystemicTherapyType
    %REDCapSystemicTherapyType
    
    properties
        dREDCapCode
        sMySQLEnumString
    end
    
    
    enumeration
        Chemotherapy (0, "chemotherapy")
        TargetedTherapy (1, "targeted therapy")
        HormoneTherapy (2, "hormone therapy")
        Immunotherapy (3, "immunotherapy")
        Other (4, "other")
    end
    
    
    methods
        function enum = REDCapSystemicTherapyType(dREDCapCode, sMySQLEnumString)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumString =sMySQLEnumString;
        end
        
        function sMySQLEnumString = GetMySQLEnumString(enum)
            sMySQLEnumString = enum.sMySQLEnumString;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapSystemicTherapyType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapSystemicTherapyType:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

