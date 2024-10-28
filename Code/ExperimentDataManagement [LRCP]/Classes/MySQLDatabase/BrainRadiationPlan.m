classdef BrainRadiationPlan
    %BrainRadiationPlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        sPlanName (1,1) string
        eTreatmentPlanningSystem (1,1) TreatmentPlanningSystem = TreatmentPlanningSystem.Eclipse 
        
        voBeamSets (:,1) BrainRadiationBeamSet
        
        dMySQLPrimaryKey (1,1) double
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainRadiationPlan(sPlanName, eTreatmentPlanningSystem, voBeamSets, dMySQLPrimaryKey)
            %obj = BrainRadiationPlan(sPlanName, eTreatmentPlanningSystem, voBeamSets, dMySQLPrimaryKey)
            
            obj.sPlanName = sPlanName;
            obj.eTreatmentPlanningSystem = eTreatmentPlanningSystem;
            obj.voBeamSets = voBeamSets;
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function sPlanName = GetPlanName(obj)
            sPlanName = obj.sPlanName;
        end
        
        function eTreatmentPlanningSystem = GetTreatmentPlanningSystem(obj)
            eTreatmentPlanningSystem = obj.eTreatmentPlanningSystem;
        end
        
        function voBeamSets = GetBeamSets(obj)
            voBeamSets = obj.voBeamSets;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
        
    end
    
    
    methods (Access = public, Static)
                
        function voPlans = LoadFromDatabaseByBrainRadiationCourseId(dBrainRadiationCourseId)
            arguments
                dBrainRadiationCourseId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_radiation_plans", [], "WHERE fk_brain_radiation_plans_id_brain_radiation_courses = " + string(dBrainRadiationCourseId));
            
            dNumPlans = size(tOutput,1);
            
            if dNumPlans == 0
                voPlans = BrainRadiationPlan.empty;
            else
                c1oPlans = cell(dNumPlans,1);
                
                for dPlanIndex=1:dNumPlans
                    c1oPlans{dPlanIndex} = BrainRadiationPlan(...
                        tOutput.plan_name{dPlanIndex},...
                        TreatmentPlanningSystem.GetEnumFromMySQLEnumValue(tOutput.treatment_planning_system{dPlanIndex}),...
                        BrainRadiationBeamSet.LoadFromDatabaseByBrainRadiationPlanId(CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tOutput.id_brain_radiation_plans(dPlanIndex))),...
                        tOutput.id_brain_radiation_plans{dPlanIndex});
                end
                
                voPlans = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPlans);
            end            
        end     
        
        function voValidationRecords = Validate(voPlans, oParentPatient, oParentBrainRadiationCourse, voValidationRecords)
            dNumPlans = length(voPlans);
                        
            vsPlanNames = strings(dNumPlans,1);
            c1eTPSs = cell(dNumPlans,1);
            
            for dPlanIndex=1:dNumPlans
                vsPlanNames(dPlanIndex) = voPlans(dPlanIndex).sPlanName;
                c1eTPSs{dPlanIndex} = voPlans(dPlanIndex).eTreatmentPlanningSystem;
            end
                
            veTPSs = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1eTPSs);
            
            % - sPlanName
            % -- no duplicated names
            if length(unique(vsPlanNames)) ~= length(vsPlanNames)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voPlans, "sPlanName", "Non-unique plan names across all plans"));
            end
                         
            % - eTreatmentPlanningSystem
            % -- all the same TPS
            if ~all(veTPSs(1) == veTPSs)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voPlans, "eTreatmentPlanningSystem", "Multiple treatment plannning systems across all plans"));
            end
                        
            % per plan:
            for dPlanIndex=1:dNumPlans
                % - voBeamSets            
                voValidationRecords = BrainRadiationBeamSet.Validate(voPlans(dPlanIndex).voBeamSets, oParentPatient, oParentBrainRadiationCourse, voPlans(dPlanIndex), voValidationRecords);
            end
            
            % -- unique beam set names across all plans
            vsBeamSetNames = string.empty;
            voBeamSets = BrainRadiationBeamSet.empty;
            
            for dPlanIndex=1:dNumPlans         
                voBeamSetsPerPlan = voPlans(dPlanIndex).voBeamSets;
                dNumBeamSets = length(voBeamSetsPerPlan);
                
                vsBeamSetNamesPerPlan = strings(dNumBeamSets,1);
                
                for dBeamSetIndex=1:dNumBeamSets
                    vsBeamSetNamesPerPlan(dBeamSetIndex) = voBeamSetsPerPlan(dBeamSetIndex).GetBeamSetName();
                end
                
                vsBeamSetNames = [vsBeamSetNames; vsBeamSetNamesPerPlan];
                voBeamSets = [voBeamSets; voBeamSetsPerPlan];
            end
            
            if length(unique(vsBeamSetNames)) ~= length(vsBeamSetNames)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voBeamSets, "sBeamSetName", "Non-unique beam set names across all beam sets across all plans"));
            end
            
            % -- unique brain metastasis GTV structure names across all
            % plans            
            % -- all BMs represented across all plans
            dNumBMs = oParentPatient.GetNumberOfBrainMetastases();
            vsGTVStructureNames = strings(dNumBMs,1);
            vbBMPresent = false(dNumBMs,1);
            c1oPrescriptions = cell(dNumBMs,1);
            
            for dPlanIndex=1:dNumPlans
                voBeamSetsPerPlan = voPlans(dPlanIndex).voBeamSets;
                dNumBeamSets = length(voBeamSetsPerPlan);
                
                for dBeamSetIndex=1:dNumBeamSets
                    voBrainMetastasisPrescriptions = voBeamSetsPerPlan(dBeamSetIndex).GetBrainMetastasisPrescriptions();
                    
                    for dPrescriptionIndex=1:length(voBrainMetastasisPrescriptions)
                        dBMNumber = voBrainMetastasisPrescriptions(dPrescriptionIndex).GetBrainMetastasis().GetBrainMetastasisNumber();
                        c1oPrescriptions{dBMNumber} = voBrainMetastasisPrescriptions(dPrescriptionIndex);
                        
                        vbBMPresent(dBMNumber) = true;
                        vsGTVStructureNames(dBMNumber) = voBrainMetastasisPrescriptions(dPrescriptionIndex).GetGTVStructureName();
                    end
                end
            end
            
            voPrescriptions = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPrescriptions);
            
            if length(unique(vsGTVStructureNames)) ~= length(vsGTVStructureNames)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voPrescriptions, "sGTVStructureName", "Non-unique GTV structure names across all prescriptions across all beam sets across all plans"));
            end
                
            if any(~vbBMPresent)
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voPrescriptions, "oBrainMetastasis", "Not all brain metastasis numbers represented across all prescriptions across all beam sets across all plans"));
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

