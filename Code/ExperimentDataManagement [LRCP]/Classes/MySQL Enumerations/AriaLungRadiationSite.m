classdef AriaLungRadiationSite
    %AriaLungRadiationSite
    
    properties
        sName
        sImportLabel
        sMySQLEnumValue
    end
    
    enumeration
        LungRight("Lung Right", "LUNR", "lung right")
        LungLeft("Lung Left", "LUNL", "lung left")
        LungBottom("Lung Bottom", "LUNB", "lung bottom")
        ChestLeft("Chest Left", "CHEL", "chest left")
        ChestRight("Chest Right", "CHER", "chest right")
        ChestBottom("Chest Bottom", "CHEB", "chest bottom")
        Mediastinum("Mediastinum", "MEDI", "mediastinum")
    end
    
    methods
        function enum = AriaLungRadiationSite(sName, sImportLabel, sMySQLEnumValue)
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
            veEnums = enumeration('AriaLungRadiationSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sImportLabel == sImportLabel
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'AriaLungRadiationSite:GetEnumFromImportLabel:MatchNotFound',...
                    "No match for import label: " + sImportLabel);
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            veEnums = enumeration('AriaLungRadiationSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'AriaLungRadiationSite:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL enum value: " + sMySQLEnumValue);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

