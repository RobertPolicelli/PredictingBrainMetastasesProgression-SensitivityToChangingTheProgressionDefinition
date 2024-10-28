classdef REDCapSystemicTherapy
    %REDCapSystemicTherapy
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eType (1,1) REDCapSystemicTherapyType
        sTypeString string {ValidationUtils.MustBeEmptyOrScalar} % only needed if eType is Other
        
        bUsedForRadiosensitizing (1,1) logical
        
        dtStartDate datetime {ValidationUtils.MustBeEmptyOrScalar} % may be empty if start date unknown
        
        sTherapyAgent string {ValidationUtils.MustBeEmptyOrScalar} % may be empty if therapy agent unknwon
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapSystemicTherapy(eType, sTypeString, bUsedForRadiosensitizing, dtStartDate, sTherapyAgent)
            %obj = REDCapSystemicTherapy(eType, sTypeString, bUsedForRadiosensitizing, dtStartDate, sTherapyAgent)            
            if eType == REDCapSystemicTherapyType.Other && isempty(sTypeString)
                error(...
                    'REDCapSystemicTherapy:Constructor:TypeStringNeededForOther',...
                    'If eType is Other, sTypeString must be provided');
            end
            
            if eType ~= REDCapSystemicTherapyType.Other && ~isempty(sTypeString)
                error(...
                    'REDCapSystemicTherapy:Constructor:TypeStringNotNeededIfNotOther',...
                    'If eType is not Other, sTypeString should not be provided');
            end
            
            obj.eType = eType;
            obj.sTypeString = sTypeString;
            obj.bUsedForRadiosensitizing = bUsedForRadiosensitizing;
            obj.dtStartDate = dtStartDate;
            obj.sTherapyAgent = sTherapyAgent;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtStartDate = GetStartDate(obj)
            dtStartDate = obj.dtStartDate;
        end
        
        function eType = GetType(obj)
            eType = obj.eType;
        end
        
        function sTypeString = GetTypeString(obj)
            sTypeString = obj.sTypeString;
        end
        
        function sTherapyAgent = GetTherapyAgent(obj)
            sTherapyAgent = obj.sTherapyAgent;
        end
        
        function bUsedForRadiosensitizing = UsedForRadiosensitizing(obj)
            bUsedForRadiosensitizing = obj.bUsedForRadiosensitizing;
        end
    end
    
    
    methods (Access = public, Static)
        
        function obj = CreateFromREDCapExport(c1xREDCapExportDataForSystemicTherapy, vsREDCapExportHeaders)
            eType = REDCapSystemicTherapyType.GetEnumFromREDCapCode(c1xREDCapExportDataForSystemicTherapy{vsREDCapExportHeaders == "systemic_therapy_type"});
            sOtherType = c1xREDCapExportDataForSystemicTherapy{vsREDCapExportHeaders == "systemic_therapy_type_other"};
            bWasRadiosensitizer = logical(c1xREDCapExportDataForSystemicTherapy{vsREDCapExportHeaders == "systemic_therapy_was_radiosensitizer"});
            	
            if ismissing(sOtherType)
                sOtherType = string.empty;
            end
            
            if logical(c1xREDCapExportDataForSystemicTherapy{vsREDCapExportHeaders == "systemic_therapy_start_date_known"})
                dtDate = c1xREDCapExportDataForSystemicTherapy{vsREDCapExportHeaders == "systemic_therapy_start_date"};
            else
                dtDate = datetime.empty;
            end
            
            if logical(c1xREDCapExportDataForSystemicTherapy{vsREDCapExportHeaders == "systemic_therapy_agent_known"})
                sAgent = c1xREDCapExportDataForSystemicTherapy{vsREDCapExportHeaders == "systemic_therapy_agent"};
            else
                sAgent = string.empty;
            end
            	
            obj = REDCapSystemicTherapy(eType, sOtherType, bWasRadiosensitizer, dtDate, sAgent);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

