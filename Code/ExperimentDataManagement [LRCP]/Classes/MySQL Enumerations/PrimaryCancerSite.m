classdef PrimaryCancerSite
    %PrimaryCancerSite
    
    properties
        sREDCapEnumValue
        sMySQLEnumValue
    end
    
    
    enumeration
        Lung ("Lung", "lung")
        Breast ("Breast", 'breast')
        Renal ("Renal", "renal")
        Skin ("Skin", "skin")
        Colorectal ("Colorectal", "colorectal")
        Oesophageal ("Oesophageal", "oesophageal")
        Thyroid ("Thyroid", "thyroid")
        Oral ("Oral", "oral")
        GI ("GI", "GI")
        Liver ("Liver", "liver")
        Pancreas ("Pancreas", "pancreas")
        Gynecological ("Gynecological", "gynecological")
        Ovarian ("Ovarian", "ovarian")
        Prostate ("Prostate", "prostate")
        Testicular ("Testicular", "testicular")
        Urinary ("Urinary", "urinary")
        HeadAndNeck ("Head & Neck", "head and neck")
        Other ("Other", "other")
        Unknown ("Unknown", "unknown")
    end
    
    
    methods
        function enum = PrimaryCancerSite(sREDCapEnumValue, sMySQLEnumValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
                
        function sREDCapEnumValue = GetREDCapCode(enum)
            sREDCapEnumValue = enum.sREDCapEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('PrimaryCancerSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'PrimaryCancerSite:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            arguments
                sMySQLEnumValue (1,1) string
            end
            
            veEnums = enumeration('PrimaryCancerSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'PrimaryCancerSite:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL Code: " + string(sMySQLEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

