classdef DiseaseSite
    %DiseaseSite
    
    properties
        sSiteName
        vsImportSiteCodes
    end
    
    
    enumeration
        Lung("Lung", "C34.9")
        Breast("Breast", ["174.4", "C50.9", "D24"])
        Renal("Renal", ["C64", "C64.9"])
        Skin("Skin", ["C43.4", "C43.9", "C44.9", "C54.9", "D03.9", "L57.0"])
        Colorectal("Colorectal", ["C18.9", "C20"])
        Oesophageal("Oesophageal", "C15.9")
        Thyroid("Thyroid", ["C73", "C73.9"])
        Oral("Oral", ["C02.9", "C06.9", "C30.0", "C32.9"])
        GI("GI", ["C16.9", "C17.9", "C18.0"])
        Liver("Liver", "C22.9")
        Pancreas("Pancreas", "C25.9")
        Gynecological("Gynecological", "C54.1")
        Ovary("Ovary", ["C56", "C56.9"])
        Prostate("Prostate", "C61")
        Testis("Testis", "C62.9")
        Urinary("Urinary", ["C67.9", "C68"])
        BrainCNS("Brain/CNS", ["C70.9", "C71.9", "C72.4", "C72.9"])
        HeadAndNeck("Head and Neck", "C76.0")
        Other("Other", ["C45.9", "C90.0"])
        Unspecified("Unspecified", ["C80", "C80.0"])
        Unknown("Unknown", "R69")
    end
    
    
    methods
        function enum = DiseaseSite(sSiteName, vsImportSiteCodes)
            enum.sSiteName = sSiteName;
            enum.vsImportSiteCodes = vsImportSiteCodes;
        end
        
        function sString = GetString(enum)
            sString = enum.sSiteName;
        end
        
        function vsImportSiteCodes = GetImportSiteCodes(enum)
            vsImportSiteCodes = enum.vsImportSiteCodes;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromImportLabel(sImportLabel)
            veEnums = enumeration('DiseaseSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if any(veEnums(dEnumIndex).vsImportSiteCodes == sImportLabel)
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'DiseaseSite:GetEnumFromImportLabel:MatchNotFound',...
                    "No match for import label: " + sImportLabel);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

