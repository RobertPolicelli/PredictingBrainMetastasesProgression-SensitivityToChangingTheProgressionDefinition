classdef AriaLungRadiationTherapyCoursePlan < AriaRadiationTherapyCoursePlan
    %AriaLungRadiationTherapyCoursePlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eSite (1,1) AriaLungRadiationSite
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = AriaLungRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, eSite, dMySQLPrimaryKey)
            %obj = AriaLungRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, eSite, dMySQLPrimaryKey)
            arguments
                dtTreatmentDate
                eIntent
                dCalculatedDoseAtNormalizationPoint_Gy
                dNumberOfFractionsPrescribed
                dNumberOfFractionsDelivered
                eSite
                dMySQLPrimaryKey = []
            end
            
            
            obj@AriaRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, dMySQLPrimaryKey);
            
            obj.eSite = eSite;
        end
             
        function bBool = eq(obj1, obj2)
            bBool = eq@AriaRadiationTherapyCoursePlan(obj1, obj2);
            
            bBool = ...
                bBool &&...
                obj1.eSite == obj2.eSite;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                
        function eSite = GetSite(obj)
            eSite = obj.eSite;
        end
    end
    
    methods (Access = public, Static = true)
        
        function voPlans = LoadFromDatabase(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double {mustBeInteger, mustBePositive}
            end
           
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "aria_lung_radiation_therapy_course_plans", [], "WHERE fk_aria_lung_radiation_therapy_course_plans_patient_study_id = " + string(dPatientStudyId) + " ORDER BY treatment_date");
            
            dNumPlans = size(tOutput,1);
            
            if dNumPlans == 0
                voPlans = AriaLungRadiationTherapyCoursePlan.empty;
            else
                c1oPlans = cell(dNumPlans,1);
                
                for dPlanIndex=1:dNumPlans     
                    dtTreatmentDate = tOutput.treatment_date{dPlanIndex};
                    eIntent = AriaRadiationCourseIntent.GetEnumFromMySQLEnumValue(tOutput.intent{dPlanIndex});
                    
                    dCalculatedDoseAtNormalizationPoint_Gy = tOutput.calculated_dose_at_normalization_point_gy{dPlanIndex};
                    dNumberOfFractionsPrescribed = tOutput.number_of_fractions_prescribed{dPlanIndex};
                    dNumberOfFractionsDelivered = tOutput.number_of_fractions_delivered{dPlanIndex};
                                        
                    eSite = AriaLungRadiationSite.GetEnumFromMySQLEnumValue(tOutput.site{dPlanIndex});
                    
                    dMySQLPrimaryKey = tOutput.id_aria_lung_radiation_therapy_course_plans{dPlanIndex};
                    
                    c1oPlans{dPlanIndex} = AriaLungRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, eSite, dMySQLPrimaryKey);                    
                end
                
                voPlans = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPlans);
            end
        end
        
        function obj = CreateFromSpreadsheetData(sIntentCode, dDateYear, dDateMonth, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, sSiteCode)
            eIntent = AriaRadiationCourseIntent.GetEnumFromImportLabel(sIntentCode);
            eSite = AriaLungRadiationSite.GetEnumFromImportLabel(sSiteCode);
            dtTreatmentDate = datetime(dDateYear, dDateMonth,1);
            
            obj = AriaLungRadiationTherapyCoursePlan(dtTreatmentDate, eIntent, dCalculatedDoseAtNormalizationPoint_Gy, dNumberOfFractionsPrescribed, dNumberOfFractionsDelivered, eSite);
        end  
        
        function voValidationRecords = Validate(voPlans, oParentPatient, voValidationRecords)
            voValidationRecords = Validate@AriaRadiationTherapyCoursePlan(voPlans, "Lung", oParentPatient, voValidationRecords);
            
            for dPlanIndex=1:length(voPlans)
                oPlan = voPlans(dPlanIndex);
                
                % - eSite
                % -- none                               
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

