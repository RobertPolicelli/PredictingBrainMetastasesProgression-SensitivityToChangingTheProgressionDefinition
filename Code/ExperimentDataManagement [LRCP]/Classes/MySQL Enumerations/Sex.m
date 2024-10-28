classdef Sex
    %Sex
    
    properties
        sName
        sMySQLEnumValue
        sREDCapEnumValue
    end
    
    enumeration
        Male("Male", "male", "Male");
        Female("Female", "female", "Female");
    end
    
    methods
        function enum = Sex(sName, sMySQLEnumValue, sREDCapEnumValue)
            enum.sName = sName;
            enum.sMySQLEnumValue = sMySQLEnumValue;
            enum.sREDCapEnumValue = sREDCapEnumValue;
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
                enum = Sex.empty;
            else
                veEnums = enumeration('Sex');
                
                dMatchIndex = [];
                
                for dEnumIndex=1:length(veEnums)
                    if veEnums(dEnumIndex).sMySQLEnumValue == sMySQLEnumValue
                        dMatchIndex = dEnumIndex;
                        break;
                    end
                end
                
                if isempty(dMatchIndex)
                    error(...
                        'Sex:GetEnumFromMySQLEnumValue:MatchNotFound',...
                        "No match for MySQL enum value: " + sMySQLEnumValue);
                else
                    enum = veEnums(dMatchIndex);
                end
            end
        end
        
        function enum = GetEnumFromREDCapEnumValue(sREDCapEnumValue)
            veEnums = enumeration('Sex');
            
            dMatchIndex = [];
            
            for dEnumIndex=1:length(veEnums)
                if veEnums(dEnumIndex).sREDCapEnumValue == sREDCapEnumValue
                    dMatchIndex = dEnumIndex;
                    break;
                end
            end
            
            if isempty(dMatchIndex)
                error(...
                    'Sex:GetEnumFromREDCapEnumValue:MatchNotFound',...
                    "No match for REDCap enum value: " + sREDCapEnumValue);
            else
                enum = veEnums(dMatchIndex);
            end
        end
    end
end

