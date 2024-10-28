classdef REDCapBrainMetastasisAppearanceScore
    %REDCapBrainMetastasisAppearanceScore
    
    properties
        dREDCapCode
        dREDCapSubCode
        dUnifiedCode % allows for all the enums to be referenced by a single code instead of the REDCap code and sub-code
        sMySQLEnumString
    end
    
    
    enumeration
        Homogeneous (0, [], 0, "homogeneous")
        Heterogeneous (1, [], 1, "heterogeneous")
        RimEnhancingSingleCystic (2, 0, 2, "rim-enhancing (single cystic)")
        RimEnhancingMultiCystic (2, 1, 3, "rim-enhancing (multi-cystic)")
        RimEnhancingNecroticCore (2, 2, 4, "rim-enhancing (necrotic core)")
    end
    
    
    methods
        function enum = REDCapBrainMetastasisAppearanceScore(dREDCapCode, dREDCapSubCode, dUnifiedCode, sMySQLEnumString)
            enum.dREDCapCode = dREDCapCode;
            enum.dREDCapSubCode = dREDCapSubCode;
            enum.dUnifiedCode = dUnifiedCode;
            enum.sMySQLEnumString = sMySQLEnumString;
        end
        
        function sMySQLEnumString = GetMySQLEnumString(enum)
            sMySQLEnumString = enum.sMySQLEnumString;
        end
        
        function dUnifiedCode = GetUnifiedCode(enum)
            dUnifiedCode = enum.dUnifiedCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapCode(dREDCapCode, dREDCapSubCode)
            if ismissing(dREDCapSubCode)
                dREDCapSubCode = [];
            end
            
            veEnums = enumeration('REDCapBrainMetastasisAppearanceScore');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).dREDCapCode == dREDCapCode && (isempty(dREDCapSubCode) && isempty(veEnums(dEnumIndex).dREDCapSubCode) || dREDCapSubCode == veEnums(dEnumIndex).dREDCapSubCode)
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'REDCapBrainMetastasisAppearanceScore:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code & Sub-Code: " + string(dREDCapCode) + " - " + string(dREDCapSubCode));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

