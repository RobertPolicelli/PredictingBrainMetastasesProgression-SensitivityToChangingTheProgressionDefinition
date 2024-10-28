classdef UnifiedHistopathologyType
    %UnifiedHistopathologyType
    % Allows for REDCapHistopathologyType and
    % REDCapLungCancerHistopathologyType (which have overlapping REDCap
    % enumeration codes) to have unique enumeration codes, to allow for
    % them to be in the same column of a feature values object
    
    properties
        dCode
        c1eReferencedHistopathologyTypes
    end
    
    
    enumeration
        CarcinomaAdeno (0, {REDCapHistopathologyType.CarcinomaAdeno})
        CarcinomaSquamous (1, {REDCapHistopathologyType.CarcinomaSquamous})
        CarcinomaBasal (2, {REDCapHistopathologyType.CarcinomaBasal})
        CarcinomaPapillary (3, {REDCapHistopathologyType.CarcinomaPapillary})
        CarcinomaUrothelial (4, {REDCapHistopathologyType.CarcinomaUrothelial})
        CarcinomaRenal (5, {REDCapHistopathologyType.CarcinomaRenal})
        CarcinomaMammary (9, {REDCapHistopathologyType.CarcinomaMammary})
        Melanoma (6, {REDCapHistopathologyType.Melanoma})
        Sarcoma (7, {REDCapHistopathologyType.Sarcoma})
        Neuroendocrine (10, {REDCapHistopathologyType.Neuroendocrine})
        
        SCLCPure (11, {REDCapLungCancerHistopathologyType.SCLCPure})
        SCLCCombined (12, {REDCapLungCancerHistopathologyType.SCLCCombined})
        NSCLCAdeno (13, {REDCapLungCancerHistopathologyType.NSCLCAdeno})
        NSCLCSquamous (14, {REDCapLungCancerHistopathologyType.NSCLCSquamous})
        NSCLCLargeCell (15, {REDCapLungCancerHistopathologyType.NSCLCLargeCell})
        NSCLCOther (16, {REDCapLungCancerHistopathologyType.NSCLCOther})
                
        Unknown (8, {REDCapHistopathologyType.Unknown, REDCapLungCancerHistopathologyType.Unknown})
    end
    
    
    methods
        function enum = UnifiedHistopathologyType(dCode, c1eReferencedHistopathologyTypes)
            enum.dCode = dCode;
            enum.c1eReferencedHistopathologyTypes = c1eReferencedHistopathologyTypes;
        end
        
        function dCode = GetCode(enum)
            dCode = enum.dCode;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromBaseEnum(eBaseEnum)
            % eBaseEnum must be a REDCapHistopathologyType or REDCapLungCancerHistopathologyType
            
            veEnums = enumeration('UnifiedHistopathologyType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                c1eReferencedHistopathologyTypes = veEnums(dEnumIndex).c1eReferencedHistopathologyTypes;
                
                for dReferencedTypeIndex=1:length(c1eReferencedHistopathologyTypes)
                    if eBaseEnum == c1eReferencedHistopathologyTypes{dReferencedTypeIndex}
                        dMatchIndex = dEnumIndex;
                        break;
                    end
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'UnifiedHistopathologyType:GetEnumFromREDCap:MatchNotFound',...
                    "No match for " + string(eBaseEnum));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

