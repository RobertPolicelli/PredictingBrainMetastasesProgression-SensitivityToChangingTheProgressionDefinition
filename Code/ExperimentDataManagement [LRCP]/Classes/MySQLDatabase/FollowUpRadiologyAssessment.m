classdef FollowUpRadiologyAssessment < RadiologyAssessment
    %FollowUpRadiologyAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dNumberOfNewBrainMetastases (1,1) double {mustBeNonnegative} % inf indicates uncountable
        dNumberOfSuspectedNewBrainMetastases (1,1) double {mustBeNonnegative} % inf indicates uncountable
        
        bPreviouslyMissedBrainMetastasesPresent (1,1) logical
        
        dREDCapRepeatInstance (1,1) double {mustBePositive, mustBeInteger} = 1
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = FollowUpRadiologyAssessment(voBrainMetastasisRadiologyAssessmentPerBrainMetastasis, sREDCapDataCollectionNotes, dMySQLPrimaryKey, dNumberOfNewBrainMetastases, dNumberOfSuspectedNewBrainMetastases, bPreviouslyMissedBrainMetastasesPresent, dREDCapRepeatInstance)
            %obj = FollowUpRadiologyAssessment(voBrainMetastasisRadiologyAssessmentPerBrainMetastasis, sREDCapDataCollectionNotes, dMySQLPrimaryKey, dNumberOfNewBrainMetastases, dNumberOfSuspectedNewBrainMetastases, bPreviouslyMissedBrainMetastasesPresent, dREDCapRepeatInstance)
            
            obj@RadiologyAssessment(voBrainMetastasisRadiologyAssessmentPerBrainMetastasis, sREDCapDataCollectionNotes, dMySQLPrimaryKey);
            
            obj.dNumberOfNewBrainMetastases = dNumberOfNewBrainMetastases;
            obj.dNumberOfSuspectedNewBrainMetastases = dNumberOfSuspectedNewBrainMetastases;
            
            obj.bPreviouslyMissedBrainMetastasesPresent = bPreviouslyMissedBrainMetastasesPresent;
            
            obj.dREDCapRepeatInstance = dREDCapRepeatInstance;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<        
    end
    
    
    methods (Access = public, Static)
        
        function voAssessments = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double {mustBeInteger, mustBePositive}
            end
                        
            sJoinStatement = "radiology_assessments JOIN new_metastases_counts " + ...
                "ON radiology_assessments.id_radiology_assessments = new_metastases_counts.fk_new_metastases_counts_id_radiology_assessments";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoinStatement, [], ...
                SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues(...
                ["fk_radiology_assessments_patient_study_id", "type"],...
                {dPatientStudyId, RadiologyAssessmentType.FollowUp}),...
                "ORDER BY scan_date");
            
            dNumAssessments = size(tOutput,1);
            
            if dNumAssessments == 0
                voAssessments = FollowUpRadiologyAssessment.empty;                
            else
                c1oAssessments = cell(dNumAssessments,1);
                
                for dAssessmentIndex=1:dNumAssessments
                    dRadiologyAssessmentId = tOutput.id_radiology_assessments{dAssessmentIndex};          
                    
                    voBMAssessments = BrainMetastasisFollowUpRadiologyAssessment.LoadFromDatabaseByRadiologyAssessmentId(dRadiologyAssessmentId);
                    
                    if tOutput.number_new_metastases_countable{dAssessmentIndex}
                        dNumberOfNewBrainMetastases = tOutput.number_new_metastases{dAssessmentIndex};
                    else
                        dNumberOfNewBrainMetastases = inf;
                    end
                    
                    if tOutput.number_suspected_new_metastases_countable{dAssessmentIndex}
                        dNumberOfSuspectedNewBrainMetastases = tOutput.number_suspected_new_metastases{dAssessmentIndex};
                    else
                        dNumberOfSuspectedNewBrainMetastases = inf;
                    end
                    
                    c1oAssessments{dAssessmentIndex} = FollowUpRadiologyAssessment(...
                        voBMAssessments,...
                        tOutput.data_collection_notes{dAssessmentIndex},...
                        tOutput.id_radiology_assessments{dAssessmentIndex},...
                        dNumberOfNewBrainMetastases,...
                        dNumberOfSuspectedNewBrainMetastases,...
                        tOutput.metastases_present_missed_in_previous_followup{dAssessmentIndex},...
                        tOutput.redcap_repeat_instance{dAssessmentIndex});
                end
                
                voAssessments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oAssessments);
            end
        end
        
        function voValidationRecords = Validate(voRadiologyAssessments, oParentPatient, voValidationRecords)
            dNumFollowUps = length(voRadiologyAssessments);
            vdtFollowUpDates = NaT(dNumFollowUps,1);
            
            for dFollowUpIndex=1:dNumFollowUps
                vdtFollowUpDates(dFollowUpIndex) = voRadiologyAssessments(dFollowUpIndex).GetScanDate();
            end
            
            vdNumberOfMonthsBetweenFollowUps = zeros(dNumFollowUps-1,1);
            
            for dFollowUpIndex=1:dNumFollowUps-1
                vdNumberOfMonthsBetweenFollowUps(dFollowUpIndex) = calmonths(between(vdtFollowUpDates(dFollowUpIndex), vdtFollowUpDates(dFollowUpIndex+1)));
            end
            
            % -- follow-ups occuring within 1 months of each other
            if any(vdNumberOfMonthsBetweenFollowUps <= 1)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voRadiologyAssessments, "GetScanDate", "Follow-up scans within 1 month of each other"));
            end
            
            % -- gaps of more than 6 months between imaging (with first
            % brain radiation therapy and approximate DOD/2 years marking
            % the cut-off)
            dtEndDate = min(oParentPatient.GetFirstBrainRadiationTherapyDate()+years(2), oParentPatient.GetApproximateDateOfDeath());
            dtStartDate = oParentPatient.GetFirstBrainRadiationTherapyDate();
            
            vdNumberOfMonthsBetweenFollowUps = [...
                calmonths(between(dtStartDate, vdtFollowUpDates(1)));
                vdNumberOfMonthsBetweenFollowUps;
                calmonths(between(vdtFollowUpDates(end), dtEndDate))];            
            
            if any(vdNumberOfMonthsBetweenFollowUps > 6)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voRadiologyAssessments, "GetScanDate", "More than 6 month gap between imaging follow-ups, or first brain radiation, or 2 years post-treatment/date of death"));
            end
            
            
            for dAssessmentIndex=1:length(voRadiologyAssessments)
                oRadiologyAssessment = voRadiologyAssessments(dAssessmentIndex);
                
                % super-class validator
                voValidationRecords = Validate@RadiologyAssessment(oRadiologyAssessment, oParentPatient, "FollowUp", voValidationRecords);
                
                % - dNumberOfNewBrainMetastases
                % none
                
                % - dNumberOfSuspectedNewBrainMetastases
                % none
        
                % - bPreviouslyMissedBrainMetastasesPresent
                % none
        
                % - dREDCapRepeatInstance
                % none
            end
            
            
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

