classdef RadiologyAssessmentType
    %RadiologyAssessmentType
    
    properties
        sMySQLEnumValue
    end
    
    
    enumeration
        PreResection ("pre-resection")
        PreRadiation ("pre-radiation")
        FollowUp ("follow-up")
        Post2YearFollowUp (">2 year follow-up")
    end
    
    
    methods
        function enum = RadiologyAssessmentType(sMySQLEnumValue)
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
    end
end

