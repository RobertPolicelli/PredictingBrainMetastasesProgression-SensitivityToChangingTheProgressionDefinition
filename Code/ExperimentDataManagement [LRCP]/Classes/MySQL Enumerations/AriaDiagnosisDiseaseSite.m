classdef AriaDiagnosisDiseaseSite
    %AriaDiagnosisDiseaseSite
    
    properties
        sSiteName
        vsSiteCodes
        sMySQLEnumValue
    end
    
    
    enumeration
        Lung("Lung", "C34.9", "lung")
        Breast("Breast", ["174.4", "C50.9", "D24"], "breast")
        Renal("Renal", ["C64", "C64.9"], "renal")
        Skin("Skin", ["C43.4", "C43.9", "C44.9", "C54.9", "D03.9", "L57.0"], "skin")
        Colorectal("Colorectal", ["C18.9", "C20"], "colorectal")
        Oesophageal("Oesophageal", "C15.9", "oesophageal")
        Thyroid("Thyroid", ["C73", "C73.9"], "thyroid")
        Oral("Oral", ["C02.9", "C06.9", "C30.0", "C32.9"], "oral")
        GI("GI", ["C16.9", "C17.9", "C18.0"], "gastrointestinal")
        Liver("Liver", "C22.9", "liver")
        Pancreas("Pancreas", "C25.9", "pancreas")
        Gynecological("Gynecological", "C54.1", "gynecological")
        Ovarian("Ovary", ["C56", "C56.9"], "ovary")
        Prostate("Prostate", "C61", "prostate")
        Testicular("Testis", "C62.9", "testis")
        Urinary("Urinary", ["C67.9", "C68"], "urinary")
        BrainCNS("Brain/CNS", ["C70.9", "C71.9", "C72.4", "C72.9"], "brain cns")
        HeadAndNeck("Head and Neck", "C76.0", "head and neck")
        Mesothelioma("Mesothelioma", "C45.9", "mesothelioma")
        MultipleMyeloma("Multiple Myeloma", "C90.0", "multiple myeloma")
        Unspecified("Unspecified", ["C80", "C80.0"], "unspecified")
        Unknown("Unknown", "R69", "unknown")
    end
    
    
    methods
        function enum = AriaDiagnosisDiseaseSite(sSiteName, vsSiteCodes, sMySQLEnumValue)
            enum.sSiteName = sSiteName;
            enum.vsSiteCodes = vsSiteCodes;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sString = GetString(enum)
            sString = enum.sSiteName;
        end
        
        function vsSiteCodes = GetImportSiteCodes(enum)
            vsSiteCodes = enum.vsSiteCodes;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromSiteCode(sSiteCode)
            veEnums = enumeration('AriaDiagnosisDiseaseSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if any(veEnums(dEnumIndex).vsSiteCodes == sSiteCode)
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'AriaDiagnosisDiseaseSite:GetEnumFromImportLabel:MatchNotFound',...
                    "No match for site code: " + sSiteCode);
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            veEnums = enumeration('AriaDiagnosisDiseaseSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if any(veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue)
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'AriaDiagnosisDiseaseSite:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL enum value: " + sMySQLEnumValue);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

