classdef DeceasedStatus
    %DeceasedStatus
    
    properties
        sREDCapEnumValue
        sMySQLEnumValue
    end
    
    
    enumeration
        Deceased ("Yes", "yes")
        LikelyDeceased ("Likely", "likely")
        NotDeceased ("No", "no")
    end
    
    
    methods
        function enum = DeceasedStatus(sREDCapEnumValue, sMySQLEnumValue)
            enum.sREDCapEnumValue = sREDCapEnumValue;
            enum.sMySQLEnumValue = sMySQLEnumValue;
        end
        
        function sMySQLEnumValue = GetMySQLEnumValue(enum)
            sMySQLEnumValue = enum.sMySQLEnumValue;
        end
        
        function sREDCapEnumValue = GetREDCapEnumValue(enum)
            sREDCapEnumValue = enum.sREDCapEnumValue;
        end        
    end
    
    
    methods (Static)
        
        function enum = GetEnumFromMySQLEnumValue(sMySQLEnumValue)
            
            if isempty(sMySQLEnumValue)
                enum = DeceasedStatus.empty;
            else
                veEnums = enumeration('DeceasedStatus');
                
                dMatchIndex = [];
                
                for dEnumIndex=1:length(veEnums)
                    if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                        dMatchIndex = dEnumIndex;
                        break;
                    end
                end
                
                if isempty(dMatchIndex)
                    error(...
                        'DeceasedStatus:GetEnumFromMySQLEnumValue:MatchNotFound',...
                        "No match for MySQL Code: " + sMySQLEnumValue);
                else
                    enum = veEnums(dMatchIndex);
                end
            end
        end
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('DeceasedStatus');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'DeceasedStatus:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap Code: " + string(sREDCapEnumValue));
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

