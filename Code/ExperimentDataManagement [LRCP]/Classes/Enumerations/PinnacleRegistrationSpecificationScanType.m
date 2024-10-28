classdef PinnacleRegistrationSpecificationScanType
    %PinnacleRegistrationSpecificationScanType
    
    properties
        sName
        sImportLabel
    end
    
    enumeration
        T2("T2", "T2")
        T1Post("T1 Post", "T1 Post")
        T1Pre("T1 Pre", "T1 Pre")
        ADC("ADC","ADC")
        
        T2_PreOP("T2 (Pre-op)", "T2 (Pre-op)")
        T1Post_PreOP("T1 Post (Pre-op)", "T1 Post (Pre-op)")
        T1Pre_PreOP("T1 Pre (Pre-op)", "T1 Pre (Pre-op)")
        
        CT("CT", "CT")
        PET("PET", "PET")
        
        None("None", "")
    end
    
    methods
        function enum = PinnacleRegistrationSpecificationScanType(sName, sImportLabel)
            enum.sName = sName;
            enum.sImportLabel = sImportLabel;
        end
        
        function sName = GetString(enum)
            sName = enum.sName;
        end
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromImportLabel(sImportLabel)
            veEnums = enumeration('PinnacleRegistrationSpecificationScanType');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sImportLabel == sImportLabel
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'PinnacleRegistrationSpecificationScanType:GetEnumFromImportLabel:MatchNotFound',...
                    "No match for import label: " + sImportLabel);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
    
    
end

