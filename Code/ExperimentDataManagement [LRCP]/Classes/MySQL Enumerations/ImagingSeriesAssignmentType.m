classdef ImagingSeriesAssignmentType
    %ImagingSeriesAssignmentType
    
    properties
        sMySQLEnumValue
    end
    
    enumeration
        T1wPostContrast ("T1w post contrast")
        T1wPreContrast ("T1w pre contrast")
        T2w ("T2w")
        FLAIR ("FLAIR")
        ADC ("ADC")
        FA ("FA")
        PlanningCT ("Planning CT")
        Contours ("Contours")
    end
    
    
    methods
        function enum = ImagingSeriesAssignmentType(sMySQLEnumValue)
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            veEnums = enumeration('ImagingSeriesAssignmentType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'ImagingSeriesAssignmentType:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL Code: " + string(sMySQLEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

