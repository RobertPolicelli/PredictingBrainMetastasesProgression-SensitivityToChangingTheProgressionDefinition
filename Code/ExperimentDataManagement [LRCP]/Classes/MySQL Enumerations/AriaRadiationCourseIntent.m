classdef AriaRadiationCourseIntent
    %AriaRadiationCourseIntent
    
    properties
        sName
        sImportLabel
        sMySQLEnumValue
    end
    
    enumeration
        Curative("Curative", "C", "curative")
        CurativeWithChemotherapy("Curative with Chemotherapy", "C w/ C", "curative with chemotherapy")
        Palliative("Palliative", "P", "palliative")
        Radical("Radical", "R", "radical")
        Unknown("Unknown", "U", "unknown")
    end
    
    methods
        function enum = AriaRadiationCourseIntent(sName, sImportLabel, sMySQLEnumValue)
            enum.sName = sName;
            enum.sImportLabel = sImportLabel;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sName = GetString(enum)
            sName = enum.sName;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromImportLabel(sImportLabel)
            veEnums = enumeration('AriaRadiationCourseIntent');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sImportLabel == sImportLabel
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'AriaRadiationCourseIntent:GetEnumFromImportLabel:MatchNotFound',...
                    "No match for import label: " + sImportLabel);
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            veEnums = enumeration('AriaRadiationCourseIntent');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'AriaRadiationCourseIntent:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL enum value: " + sMySQLEnumValue);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
    
    
end

