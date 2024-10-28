classdef REDCapPrimaryCancerSite
    %REDCapPrimaryCancerSite
    
    properties
        dREDCapCode
    end
    
    
    enumeration
        Lung (0)
        Breast (1)
        Renal (2)
        Skin (3)
        Colorectal (4)
        Oesophageal (5)
        Thyroid (6)
        Oral (7)
        GI (8)
        Liver (9)
        Pancreas (10)
        Gynecological (11)
        Ovarian (12)
        Prostate (13)
        Testicular (14)
        Urinary (15)
        HeadAndNeck (16)
        Other (17)
        Unknown (18)
    end
    
    
    methods
        function enum = REDCapPrimaryCancerSite(dREDCapCode)
            enum.dREDCapCode = dREDCapCode;
        end
        
        function dREDCapCode = GetREDCapCode(enum)
            dREDCapCode = enum.dREDCapCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapPrimaryCancerSite');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapPrimaryCancerSite:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

