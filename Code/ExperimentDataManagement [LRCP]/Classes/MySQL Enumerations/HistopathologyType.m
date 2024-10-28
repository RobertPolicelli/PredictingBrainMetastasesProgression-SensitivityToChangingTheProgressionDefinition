classdef HistopathologyType
    %HistopathologyType
    
    properties
        sREDCapEnumValue
        sMySQLEnumValue
    end
    
    
    enumeration
        CarcinomaAdeno ("Carcinoma (Adeno)", "carcinoma (adeno)")
        CarcinomaSquamous ("Carcinoma (Squamous)", "carcinoma (squamous)")
        CarcinomaBasal ("Carcinoma (Basal)", "carcinoma (basal)")
        CarcinomaPapillary ("Carcinoma (Papillary)", "carcinoma (papillary)")
        CarcinomaUrothelial ("Carcinoma (Urothelial)", "carcinoma (urothelial)")
        CarcinomaRenal ("Carcinoma (Renal)", "carcinoma (renal)")
        CarcinomaMammary ("Carcinoma (Mammary)", "carcinoma (mammary)")
        Melanoma ("Melanoma", "melanoma")
        Sarcoma ("Sarcoma", "sarcoma")
        Neuroendocrine ("Neuroendocrine", "neuroendocrine")
        GermCell ("Germ Cell", "germ cell")
        
        SCLCPure ("SCLC (Pure)", "SCLC (pure)")
        SCLCCombined ("SCLC (Combined)", "SCLC (combined)")
        NSCLCAdeno ("NSCLC (Adeno)", "NSCLC (adeno)")
        NSCLCSquamous ("NSCLC (Squamous)", "NSCLC (squamous)")
        NSCLCLargeCell ("NSCLC (Large Cell)", "NSCLC (large cell)")
        NSCLCOther ("NSCLC (Other)", "NSCLC (other)")
                
        Unknown ("Unknown", "unknown")
    end
    
    
    methods
        function enum = HistopathologyType(sREDCapEnumValue, sMySQLEnumValue)
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
            veEnums = enumeration('HistopathologyType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'HistopathologyType:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            arguments
                sMySQLEnumValue (1,1) string
            end
            
            veEnums = enumeration('HistopathologyType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'HistopathologyType:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL Code: " + string(sMySQLEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

