classdef Gender
    %Gender
    
    properties
        sAbbreviation
        sName
        sImportLabel
    end
    
    enumeration
        Male("M", "Male", "M");
        Female("F", "Female", "F");
        Unknown("U", "Unknown", "?");
    end
    
    methods
        function enum = Gender(chAbrev, sName, sImportLabel)
            enum.sAbbreviation = chAbrev;
            enum.sName = sName;
            enum.sImportLabel = sImportLabel;
        end
        
        function chString = GetString(enum)
            chString = enum.sAbbreviation;
        end
    end
    
    methods (Static)
        function enum = GetEnumFromImportLabel(sImportLabel)
            switch sImportLabel
                case Gender.Male.sImportLabel
                    enum = Gender.Male;
                case Gender.Female.sImportLabel
                    enum = Gender.Female;
                case Gender.Unknown.sImportLabel
                    enum = Gender.Unknown;
                otherwise
                    error("Invalid import label: " + label);
            end
        end
    end
end

