classdef TreatmentPlanningSystem
    %TreatmentPlanningSystem
    
    properties
        sMySQLEnumValue
    end
    
    
    enumeration
        RayStation ("RayStation")
        Pinnacle ("Pinnacle")
        Eclipse ("Eclipse")
    end
    
    
    methods
        function enum = TreatmentPlanningSystem(sMySQLEnumValue)
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
                
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            veEnums = enumeration('TreatmentPlanningSystem');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'TreatmentPlanningSystem:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL enum value: " + sMySQLEnumValue);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

