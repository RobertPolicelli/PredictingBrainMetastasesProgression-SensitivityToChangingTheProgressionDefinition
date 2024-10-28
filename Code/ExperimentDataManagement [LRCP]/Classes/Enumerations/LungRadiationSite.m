classdef LungRadiationSite
    %LungRadiationSite
    
    properties
        sName
        sImportLabel
        dREDCapCoding
    end
    
    enumeration
        LungRight("Lung Right", "LUNR", 1)
        LungLeft("Lung Left", "LUNL", 0)
        LungBottom("Lung Bottom", "LUNB", 2)
        ChestLeft("Chest Left", "CHEL", 3)
        ChestRight("Chest Right", "CHER", 4)
        ChestBottom("Chest Bottom", "CHEB", 5)
        Mediastinum("Mediastinum", "MEDI", 6)
    end
    
    methods
        function enum = LungRadiationSite(sName, sImportLabel, dREDCapCoding)
            enum.sName = sName;
            enum.sImportLabel = sImportLabel;
            enum.dREDCapCoding = dREDCapCoding;
        end
        
        function sName = GetString(enum)
            sName = enum.sName;
        end
        
        function dREDCapCoding = GetREDCapCoding(enum)
            dREDCapCoding = enum.dREDCapCoding;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromImportLabel(sImportLabel)
            veEnums = enumeration('LungRadiationSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sImportLabel == sImportLabel
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'LungRadiationSite:GetEnumFromImportLabel:MatchNotFound',...
                    "No match for import label: " + sImportLabel);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

