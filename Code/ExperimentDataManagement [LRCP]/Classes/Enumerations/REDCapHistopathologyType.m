classdef REDCapHistopathologyType
    %REDCapHistopathologyType
    
    properties
        dREDCapCode
        sMySQLEnumString
    end
    
    
    enumeration
        CarcinomaAdeno (0, "carcinoma (adeno)")
        CarcinomaSquamous (1, "carcinoma (squamous)")
        CarcinomaBasal (2, "carcinoma (basal)")
        CarcinomaPapillary (3, "carcinoma (papillary)")
        CarcinomaUrothelial (4, "carcinoma (urothelial)")
        CarcinomaRenal (5, "carcinoma (renal)")
        CarcinomaMammary (9, "carcinoma (mammary)")
        Melanoma (6, "melanoma")
        Sarcoma (7, "sarcoma")
        Neuroendocrine (10, "neuroendocrine")
        Unknown (8, "unknown")
    end
    
    
    methods
        function enum = REDCapHistopathologyType(dREDCapCode, sMySQLEnumString)
            enum.dREDCapCode = dREDCapCode;
            enum.sMySQLEnumString = sMySQLEnumString;
        end
        
        function sMySQLEnumString = GetMySQLEnumString(enum)
            sMySQLEnumString = enum.sMySQLEnumString;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode)
            veEnums = enumeration('REDCapHistopathologyType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapHistopathologyType:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code: " + string(dREDCapCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

