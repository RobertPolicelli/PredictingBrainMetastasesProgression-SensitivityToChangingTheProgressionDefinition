classdef BrainRadiationCourse
    %BrainRadiationCourse
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dtDate (1,1) datetime
        
        voPlans (:,1) BrainRadiationPlan = BrainRadiationPlan.empty(0,1)
        
        dMySQLPrimaryKey (1,1) double
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainRadiationCourse(dtDate, voPlans, dMySQLPrimaryKey)
            %obj = BrainRadiationCourse(dtDate, voPlans, dMySQLPrimaryKey)
            
            obj.dtDate = dtDate;
            obj.voPlans = voPlans;
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDate = GetDate(obj)
            dtDate = obj.dtDate;
        end
        
        function voPlans = GetPlans(obj)
            voPlans = obj.voPlans;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
        
        function voBrainMetastasisPrescriptions = GetPrescriptionPerBrainMetastasis(obj)
            voBrainMetastasisPrescriptions = BrainMetastasisPrescription.empty;
            
            for dPlanIndex=1:length(obj.voPlans)
                oPlan = obj.voPlans(dPlanIndex);
                voBeamSets = oPlan.GetBeamSets();                
                
                for dBeamSetIndex=1:length(voBeamSets)
                    voBrainMetastasisPrescriptions = [voBrainMetastasisPrescriptions; voBeamSets(dBeamSetIndex).GetBrainMetastasisPrescriptions()];
                end
            end
            
            vdBMNumberPerPrescription = zeros(size(voBrainMetastasisPrescriptions));
            
            for dPrescriptionIndex=1:length(voBrainMetastasisPrescriptions)
                vdBMNumberPerPrescription(dPrescriptionIndex) = voBrainMetastasisPrescriptions(dPrescriptionIndex).GetBrainMetastasis().GetBrainMetastasisNumber();
            end
            
            [~,vdSortIndices] = sort(vdBMNumberPerPrescription,'ascend');
            voBrainMetastasisPrescriptions = voBrainMetastasisPrescriptions(vdSortIndices);
        end
        
        function oPrescription = GetPrescriptionForBrainMetastasis(obj, dBrainMetastasisNumber)
            arguments
                obj (1,1) BrainRadiationCourse
                dBrainMetastasisNumber (1,1) double {mustBeInteger, mustBePositive}
            end
            
            voBrainMetastasisPrescriptions = obj.GetPrescriptionPerBrainMetastasis();
            oPrescription = voBrainMetastasisPrescriptions(dBrainMetastasisNumber);
        end
    end
    
    
    methods (Access = public, Static)
                
        function oCourse = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_radiation_courses", [], "WHERE fk_brain_radiation_courses_patient_study_id = " + string(dPatientStudyId));
            
            if size(tOutput,1) > 1
                error(...
                    'BrainRadiationCourse:GetFromDatabaseByPatientStudyId:NonUniqueEntry',...
                    'Multiple courses matching the patient ID were found.');
            elseif size(tOutput,1) == 0
                oCourse = BrainRadiationCourse.empty;                
            else
                oCourse = BrainRadiationCourse(...
                    tOutput.course_date{1},...
                    BrainRadiationPlan.LoadFromDatabaseByBrainRadiationCourseId(CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tOutput.id_brain_radiation_courses)),...
                    tOutput.id_brain_radiation_courses{1});
            end
        end 
        
        function voValidationRecords = Validate(oBrainRadiationCourse, oParentPatient, sValidationMode, voValidationRecords)
            switch sValidationMode
                case "FirstBrainRadiationCourse"
                    % - dtDate
                    % -- within a month of the first Aria brain radiation
                    % course plan
                    if abs(days(oBrainRadiationCourse.dtDate - oParentPatient.GetFirstBrainRadiationTherapyDate())) > 31
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oBrainRadiationCourse, "dtDate", "More than 1 month from first brain radiotherapy listed in Aria"));
                    end
                    
                    % - voPlans
                    voValidationRecords = BrainRadiationPlan.Validate(oBrainRadiationCourse.voPlans, oParentPatient, oBrainRadiationCourse, voValidationRecords);
                otherwise
                    error(...
                        'BrainRadiationCourse:Validation:InvalidValidationMode',...
                        'Unknown validation mode.');
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

