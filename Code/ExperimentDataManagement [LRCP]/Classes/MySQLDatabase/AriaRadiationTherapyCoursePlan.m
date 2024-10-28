classdef AriaRadiationTherapyCoursePlan
    %AriaRadiationTherapyCoursePlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dtTreatmentDate (1,1) datetime
        eIntent (1,1) AriaRadiationCourseIntent = AriaRadiationCourseIntent.Palliative
        
        dCalculatedDoseAtNormalizationPoint_Gy (1,1) double {mustBePositive} = 1
        
        dNumberOfFractionsPrescribed (1,1) double {mustBeInteger, mustBeNonnegative} = 1
        dNumberOfFractionsDelivered (1,1) double {mustBeInteger, mustBeNonnegative} = 0
        
        dMySQLPrimaryKey double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger, mustBeNonnegative}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = AriaRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, dMySQLPrimaryKey)
            %obj = AriaRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, dMySQLPrimaryKey)
            arguments
                dtTreatmentDate,
                eIntent
                dCalculatedDoseAtNormalizationPoint_Gy
                dNumberOfFractionsPrescribed
                dNumberOfFractionsDelivered
                dMySQLPrimaryKey = []
            end            
                        
            obj.dtTreatmentDate = dtTreatmentDate;
            obj.eIntent = eIntent;
            
            obj.dCalculatedDoseAtNormalizationPoint_Gy = dCalculatedDoseAtNormalizationPoint_Gy;
            obj.dNumberOfFractionsPrescribed = dNumberOfFractionsPrescribed;
            obj.dNumberOfFractionsDelivered = dNumberOfFractionsDelivered;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtTreatmentDate = GetTreatmentDate(obj)
            dtTreatmentDate = obj.dtTreatmentDate;
        end
        
        function eIntent = GetIntent(obj)
            eIntent = obj.eIntent;
        end
                     
        function dCalculatedDoseAtNormalizationPoint_Gy = GetCalculatedDoseAtNormalizationPoint_Gy(obj)
            dCalculatedDoseAtNormalizationPoint_Gy = obj.dCalculatedDoseAtNormalizationPoint_Gy;
        end
        
        function dNumberOfFractionsPrescribed = GetNumberOfFractionsPrescribed(obj)
            dNumberOfFractionsPrescribed = obj.dNumberOfFractionsPrescribed;
        end
        
        function dNumberOfFractionsDelivered = GetNumberOfFractionsDelivered(obj)
            dNumberOfFractionsDelivered = obj.dNumberOfFractionsDelivered;
        end
               
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
        
        function bBool = eq(obj1, obj2)
            bBool = ...
                obj1.dtTreatmentDate == obj2.dtTreatmentDate &&...
                obj1.eIntent == obj2.eIntent &&...
                obj1.dCalculatedDoseAtNormalizationPoint_Gy == obj2.dCalculatedDoseAtNormalizationPoint_Gy &&...
                obj1.dNumberOfFractionsPrescribed == obj2.dNumberOfFractionsPrescribed &&...
                obj1.dNumberOfFractionsDelivered == obj2.dNumberOfFractionsDelivered;
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function voPlans = LoadFromDatabase(dPatientStudyId, sTableName)
            arguments
                dPatientStudyId (1,1) double {mustBeInteger, mustBePositive}
                sTableName (1,1) string
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTableName, [], "WHERE fk_" + sTableName + "_patient_study_id = " + string(dPatientStudyId) + " ORDER BY treatment_date");
            
            dNumPlans = size(tOutput,1);
            
            if dNumPlans == 0
                voPlans = AriaRadiationTherapyCoursePlan.empty;
            else
                c1oPlans = cell(dNumPlans,1);
                
                for dPlanIndex=1:dNumPlans     
                    dtTreatmentDate = tOutput.treatment_date{dPlanIndex};
                    eIntent = AriaRadiationCourseIntent.GetEnumFromMySQLEnumValue(tOutput.intent{dPlanIndex});
                    
                    dCalculatedDoseAtNormalizationPoint_Gy = tOutput.calculated_dose_at_normalization_point_gy{dPlanIndex};
                    dNumberOfFractionsPrescribed = tOutput.number_of_fractions_prescribed{dPlanIndex};
                    dNumberOfFractionsDelivered = tOutput.number_of_fractions_delivered{dPlanIndex};
                                        
                    dMySQLPrimaryKey = tOutput.id_aria_brain_radiation_therapy_course_plans{dPlanIndex};
                    
                    c1oPlans{dPlanIndex} = AriaRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, dMySQLPrimaryKey);                    
                end
                
                voPlans = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPlans);
            end
        end
        
        function obj = CreateFromSpreadsheetData(sIntentCode, dDateYear, dDateMonth, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered)
            eIntent = AriaRadiationCourseIntent.GetEnumFromImportLabel(sIntentCode);
            dtTreatmentDate = datetime(dDateYear, dDateMonth,1);
            
            obj = AriaRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered);
        end     
        
        function voValidationRecords = Validate(voPlans, sValidationType, oParentPatient, voValidationRecords)
            % no duplicates
            bHasDuplicate = false;
            
            for dPlanIndex1=1:length(voPlans)
                for dPlanIndex2=dPlanIndex1+1:length(voPlans)
                    if voPlans(dPlanIndex1) == voPlans(dPlanIndex2)
                        bHasDuplicate = true;
                        break;
                    end
                end
            end
            
            if bHasDuplicate
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voPlans, "obj", "Duplicate values"));
            end
            
            % per plan:
            for dPlanIndex=1:length(voPlans)
                oPlan = voPlans(dPlanIndex);
                
                % - dtTreatmentDate
                % -- after date of death                
                if oParentPatient.GetDeceasedStatus() ~= DeceasedStatus.NotDeceased
                    if oPlan.dtTreatmentDate > oParentPatient.GetApproximateDateOfDeath()
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dtDate", "After date of death"));
                    end
                end
                
                % -- before 2010
                sValue = "dtTreatmentDate";
                sValidationCode = "After 2010";
                
                if oPlan.dtTreatmentDate.Year < 2010
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dtDate", "Before 2010"));
                end
                
                % eIntent
                % - none
                
                % - dCalculatedDoseAtNormalizationPoint_Gy
                if sValidationType == "Brain"
                    % -- > 40
                    if oPlan.dCalculatedDoseAtNormalizationPoint_Gy > 40
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dCalculatedDoseAtNormalizationPoint_Gy", "Greater than 40 Gy"));
                    end
                elseif sValidationType == "Lung"
                    % -- > 60
                    if oPlan.dCalculatedDoseAtNormalizationPoint_Gy > 80
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dCalculatedDoseAtNormalizationPoint_Gy", "Greater than 60 Gy"));
                    end
                else
                    error("Invalidation validation type");
                end
                
                % -- < 15
                if oPlan.dCalculatedDoseAtNormalizationPoint_Gy < 15
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dCalculatedDoseAtNormalizationPoint_Gy", "Less than 15 Gy"));
                end
        
                % - dNumberOfFractionsPrescribed
                % -- > 40
                if oPlan.dNumberOfFractionsPrescribed > 40
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dNumberOfFractionsPrescribed", "More than 40 fractions"));
                end
                
                % - dNumberOfFractionsDelivered
                % -- dNumberOfFractionsDelivered > dNumberOfFractionsPrescribed
                if oPlan.dNumberOfFractionsPrescribed > oPlan.dNumberOfFractionsPrescribed
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dNumberOfFractionsDelivered", "More fractions delivered than prescribed"));
                end
                
                % *if* it's the first brain radiation treatment
                if oPlan.dtTreatmentDate == voPlans(1).dtTreatmentDate && sValidationType == "Brain"               
                    % - dNumberOfFractionsPrescribed
                    % -- must be 1, 3 or 5
                    if oPlan.dNumberOfFractionsPrescribed ~= 1 && oPlan.dNumberOfFractionsPrescribed ~= 3 && oPlan.dNumberOfFractionsPrescribed ~= 5
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dNumberOfFractionsPrescribed", "Must be 1, 3, or 5 fractions for first brain radiotherapy"));
                    end
                    
                    % - dNumberOfFractionsDelivered
                    % -- dNumberOfFractionsDelivered == dNumberOfFractionsPrescribed
                    if oPlan.dNumberOfFractionsPrescribed ~= oPlan.dNumberOfFractionsDelivered
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPlan, "dNumberOfFractionsDelivered", "Not all of the first brain radiotherapy fractions delivered"));
                    end
                end
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

