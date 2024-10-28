classdef ImagingSeriesRegistrationSource
    %ImagingSeriesRegistrationSource
    
    properties
        sMySQLEnumValue
    end
    
    enumeration
        Pinnacle ("Pinnacle")
        Eclipse ("Eclipse")
        RayStation ("RayStation")
        MIM ("MIM")
    end
    
    
    methods
        function enum = ImagingSeriesRegistrationSource(sMySQLEnumValue)
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            veEnums = enumeration('ImagingSeriesRegistrationSource');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'ImagingSeriesRegistrationSource:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL Code: " + string(sMySQLEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

