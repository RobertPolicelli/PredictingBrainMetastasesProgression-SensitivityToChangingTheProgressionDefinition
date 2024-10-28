classdef RadiationCourseIntent
    %RadiationCourseIntent
    
    properties
        sName
        sImportLabel
        dREDCapCoding % treatment intent in REDCap is stored as an itemized list from 0 to 4
    end
    
    enumeration
        Curative("Curative", "C", 1)
        CurativeWithChemotherapy("Curative with Chemotherapy", "C w/ C", 2)
        Palliative("Palliative", "P", 0)
        Radical("Radical", "R", 3)
        Unknown("Unknown", "U", 4)
    end
    
    methods
        function enum = RadiationCourseIntent(sName, sImportLabel, dREDCapCoding)
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
            veEnums = enumeration('RadiationCourseIntent');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sImportLabel == sImportLabel
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'RadiationCourseIntent:GetEnumFromImportLabel:MatchNotFound',...
                    "No match for import label: " + sImportLabel);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
    
    
end

