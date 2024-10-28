classdef REDCapSalvageTreatmentType
    %REDCapSalvageTreatmentType
    
    properties
        dREDCapCode
        sMySQLEnumString
    end
    
    
    enumeration
        Surgery (0, "surgery")
        WBRT (1, "WBRT")
        SRS (2, "SRS")
        SRT (3, "SRT")
        Other (4, "other")
    end
    
    
    methods
        function enum = REDCapSalvageTreatmentType(dREDCapCode, sMySQLEnumString)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumString = sMySQLEnumString;
        end
        
        function sMySQLEnumString = GetMySQLEnumString(enum)
            sMySQLEnumString = enum.sMySQLEnumString;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapSalvageTreatmentType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapSalvageTreatmentType:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

