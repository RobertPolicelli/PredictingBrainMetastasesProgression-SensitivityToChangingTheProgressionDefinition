classdef BrainMetastasisAppearanceScore
    %BrainMetastasisAppearanceScore
    
    properties
        sREDCapEnumValue
        sREDCapSubEnumValue
        sMySQLEnumValue
    end
    
    
    enumeration
        Homogeneous ("Homogeneous", string.empty, "homogeneous")
        Heterogeneous ("Heterogeneous", string.empty, "heterogeneous")
        RimEnhancingSingleCystic ("Rim-Enhancing", "Single Cystic", "rim-enhancing (single cystic)")
        RimEnhancingMultiCystic ("Rim-Enhancing", "Multi-Cystic", "rim-enhancing (multi-cystic)")
        RimEnhancingNecroticCore ("Rim-Enhancing", "Necrotic Core", "rim-enhancing (necrotic core)")
    end
    
    
    methods
        function enum = BrainMetastasisAppearanceScore(sREDCapEnumValue, sREDCapSubEnumValue, sMySQLEnumValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sREDCapSubEnumValue = sREDCapSubEnumValue;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromREDCapEnumValues(sREDCapEnumValue, sREDCapSubEnumValue)
            if ismissing(sREDCapSubEnumValue)
                sREDCapSubEnumValue = [];
            end
            
            veEnums = enumeration('BrainMetastasisAppearanceScore');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue && (isempty(sREDCapSubEnumValue) && isempty(veEnums(dEnumIndex).sREDCapSubEnumValue) || sREDCapSubEnumValue == veEnums(dEnumIndex).sREDCapSubEnumValue)
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'BrainMetastasisAppearanceScore:GetEnumFromREDCap:MatchNotFound',...
                    "No match for REDCap Code & Sub-Code: " + sREDCapEnumValue + " - " + sREDCapSubEnumValue);
            else
                enum = veEnums(dMatchIndex);
            end
        end
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            veEnums = enumeration('BrainMetastasisAppearanceScore');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'BrainMetastasisAppearanceScore:GetEnumFromMySQLEnumValue:MatchNotFound',...
                    "No match for MySQL value: " + sMySQLEnumValue);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

