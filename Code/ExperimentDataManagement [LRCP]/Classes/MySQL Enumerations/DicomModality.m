classdef DicomModality
    %DicomModality
    
    properties
        sMySQLEnumValue
        sDefaultDicomFilenamePrefix
    end
    
    enumeration
        CT ("CT", "CT")
        MR ("MR", "MR")
        REG ("REG", "RE")
        RTPLAN ("RTPLAN", "RT")
        RTDOSE ("RTDOSE", "RT")
        RTSTRUCT ("RTSTRUCT", "RT")
    end
    
    
    methods
        function enum = DicomModality(sMySQLEnumValue, sDefaultDicomFilenamePrefix)
            enum.sMySQLEnumValue = sMySQLEnumValue;
            enum.sDefaultDicomFilenamePrefix = sDefaultDicomFilenamePrefix;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
        
        function sDefaultDicomFilenamePrefix = GetDefaultDicomFilenamePrefix(enum)
            sDefaultDicomFilenamePrefix = enum.sDefaultDicomFilenamePrefix;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            arguments
                sMySQLEnumValue (1,1) string
            end
            
            veEnums = enumeration('DicomModality');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'DicomModality:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL Code: " + string(sMySQLEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

