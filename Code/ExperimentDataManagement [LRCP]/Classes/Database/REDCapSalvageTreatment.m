classdef REDCapSalvageTreatment
    %REDCapSalvageTreatment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dtDate (1,1) datetime
        
        eType (1,1) REDCapSalvageTreatmentType
        sTypeString string {ValidationUtils.MustBeEmptyOrScalar} % only needed if eType is Other
        
        bNewBrainMetastasesTargeted (1,1) logical
        
        vdBrainMetastasisNumbersTargeted (:,1) double {mustBePositive, mustBeInteger}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapSalvageTreatment(dtDate, eType, sTypeString, bNewBrainMetastasesTargeted, vdBrainMetastasisNumbersTargeted)
            %obj = REDCapSalvageTreatment(dtDate, eType, sTypeString, bNewBrainMetastasesTargeted, vdBrainMetastasisNumbersTargeted)
            
            if eType == REDCapSalvageTreatmentType.Other && isempty(sTypeString)
                error(...
                    'REDCapSalvageTreatment:Constructor:TypeStringNeededForOther',...
                    'If eType is Other, sTypeString must be provided');
            end
            
            if eType ~= REDCapSalvageTreatmentType.Other && ~isempty(sTypeString)
                error(...
                    'REDCapSalvageTreatment:Constructor:TypeStringNotNeededIfNotOther',...
                    'If eType is not Other, sTypeString should not be provided');
            end
            
            obj.dtDate = dtDate;
            obj.eType = eType;
            obj.sTypeString = sTypeString;
            obj.bNewBrainMetastasesTargeted = bNewBrainMetastasesTargeted;
            obj.vdBrainMetastasisNumbersTargeted = vdBrainMetastasisNumbersTargeted;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDate = GetDate(obj)
            dtDate = obj.dtDate;
        end
        
        function eType = GetType(obj)
            eType = obj.eType;
        end
        
        function sTypeString = GetTypeString(obj)
            sTypeString = obj.sTypeString;
        end
        
        function vdBrainMetastasisNumbersTargeted = GetBrainMetastasisNumbersTargeted(obj)
            vdBrainMetastasisNumbersTargeted = obj.vdBrainMetastasisNumbersTargeted;
        end
    end
    
    
    methods (Access = public, Static)
        
        function obj = CreateFromREDCapExport(c1xREDCapExportDataForSalvageTreatment, vsREDCapExportHeaders)
            dtDate = c1xREDCapExportDataForSalvageTreatment{vsREDCapExportHeaders == "salvage_treatment_date"};
            eType = REDCapSalvageTreatmentType.GetEnumFromREDCapCode(c1xREDCapExportDataForSalvageTreatment{vsREDCapExportHeaders == "salvage_treatment_type"});
            sTypeOther = c1xREDCapExportDataForSalvageTreatment{vsREDCapExportHeaders == "salvage_treatment_type_other"};
            bNewBMsTargeted = c1xREDCapExportDataForSalvageTreatment{vsREDCapExportHeaders == "salvage_treatment_new_bms_targeted"};
            
            if ismissing(sTypeOther)
                sTypeOther = string.empty();
            end
            
            dNumBMs = 0;
            dMaxNumBMs = 10;
            vbBMTargeted = false(dMaxNumBMs,1);
            
            for dBMIndex=1:dMaxNumBMs
                bBMTargeted = c1xREDCapExportDataForSalvageTreatment{vsREDCapExportHeaders == "salvage_treatment_bm" + string(dBMIndex) + "_targeted"};
                
                if ismissing(bBMTargeted)
                    dNumBMs = dBMIndex - 1;
                    break;
                else
                    vbBMTargeted(dBMIndex) = bBMTargeted;
                end
            end
            
            vbBMTargeted = vbBMTargeted(1:dNumBMs);
            
            obj = REDCapSalvageTreatment(dtDate, eType, sTypeOther, bNewBMsTargeted, find(vbBMTargeted));
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

