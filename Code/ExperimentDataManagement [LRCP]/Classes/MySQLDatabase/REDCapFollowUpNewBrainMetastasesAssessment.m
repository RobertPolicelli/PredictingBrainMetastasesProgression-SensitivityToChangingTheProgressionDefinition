classdef REDCapFollowUpNewBrainMetastasesAssessment
    %REDCapFollowUpNewBrainMetastasesAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dtDate
        
        bIsNumberOfNewBrainMetastasesCountable (1,1) logical
        dNumberOfNewBrainMetastases double {ValidationUtils.MustBeEmptyOrScalar} % only set if bIsNumberOfNewBrainMetastasesCountable is true
        
        bIsNumberOfSuspectedNewBrainMetastasesCountable (1,1) logical
        dNumberOfSuspectedNewBrainMetastases double {ValidationUtils.MustBeEmptyOrScalar} % only set if bIsNumberOfSuspectedNewBrainMetastasesCountable is true
        
        bBMsPresentThatWereMissedInPreviousFollowup (1,1) logical
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapFollowUpNewBrainMetastasesAssessment(dtDate, bIsNumberOfNewBrainMetastasesCountable, dNumberOfNewBrainMetastases, bIsNumberOfSuspectedNewBrainMetastasesCountable, dNumberOfSuspectedNewBrainMetastases, bBMsPresentThatWereMissedInPreviousFollowup)
            %obj = REDCapFollowUpNewBrainMetastasesAssessment(dtDate, bIsNumberOfNewBrainMetastasesCountable, dNumberOfNewBrainMetastases, bIsNumberOfSuspectedNewBrainMetastasesCountable, dNumberOfSuspectedNewBrainMetastases, bBMsPresentThatWereMissedInPreviousFollowup)
            
            if ismissing(dNumberOfNewBrainMetastases)
                dNumberOfNewBrainMetastases = [];
            end
            
            if ismissing(dNumberOfSuspectedNewBrainMetastases)
                dNumberOfSuspectedNewBrainMetastases = [];
            end
            
            if ...
                    (bIsNumberOfNewBrainMetastasesCountable && isempty(dNumberOfNewBrainMetastases)) ||...
                    (~bIsNumberOfNewBrainMetastasesCountable && ~isempty(dNumberOfNewBrainMetastases))
                error(...
                    'REDCapFollowUpNewBrainMetastasesAssessment:Constructor:NumberOfNewBMsInvalid',...
                    'If the number of new BMs is countable, the number should be given, otherwise is should be left empty.');
            end
            
            if ...
                    (bIsNumberOfSuspectedNewBrainMetastasesCountable && isempty(dNumberOfSuspectedNewBrainMetastases)) ||...
                    (~bIsNumberOfSuspectedNewBrainMetastasesCountable && ~isempty(dNumberOfSuspectedNewBrainMetastases))
                error(...
                    'REDCapFollowUpNewBrainMetastasesAssessment:Constructor:NumberOfNewSuspectedBMsInvalid',...
                    'If the number of new suspected BMs is countable, the number should be given, otherwise is should be left empty.');
            end
            
            obj.dtDate = dtDate;
            
            obj.bIsNumberOfNewBrainMetastasesCountable = bIsNumberOfNewBrainMetastasesCountable;
            obj.dNumberOfNewBrainMetastases = dNumberOfNewBrainMetastases;
            
            obj.bIsNumberOfSuspectedNewBrainMetastasesCountable = bIsNumberOfSuspectedNewBrainMetastasesCountable;
            obj.dNumberOfSuspectedNewBrainMetastases = dNumberOfSuspectedNewBrainMetastases;
            
            obj.bBMsPresentThatWereMissedInPreviousFollowup;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDate = GetDate(obj)
            dtDate = obj.dtDate;
        end
    end
    
    
    methods (Access = public, Static)
        
        function obj = CreateFromREDCapExport(c1xREDCapExportDataForAssessment, vsREDCapExportHeaders)
            dtDate = c1xREDCapExportDataForAssessment{vsREDCapExportHeaders == "brain_radiology_followup_date"};
            bNumNewBMsCountable = c1xREDCapExportDataForAssessment{vsREDCapExportHeaders == "brain_radiology_followup_number_of_new_bms_countable"};
            dNumNewBMs = c1xREDCapExportDataForAssessment{vsREDCapExportHeaders == "brain_radiology_followup_number_new_bms"};
            bNumSuspectedNewBMsCountable = c1xREDCapExportDataForAssessment{vsREDCapExportHeaders == "brain_radiology_followup_number_of_suspected_new_bms_countable"};
            dNumSuspectedNewBMs = c1xREDCapExportDataForAssessment{vsREDCapExportHeaders == "brain_radiology_followup_number_suspected_new_bms"};
            bBMsPresentThatWereMissed = c1xREDCapExportDataForAssessment{vsREDCapExportHeaders == "brain_radiology_followup_bms_present_missed_in_previous_followup"};	
            	
            obj = REDCapFollowUpNewBrainMetastasesAssessment(dtDate, bNumNewBMsCountable, dNumNewBMs, bNumSuspectedNewBMsCountable, dNumSuspectedNewBMs, bBMsPresentThatWereMissed);
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

