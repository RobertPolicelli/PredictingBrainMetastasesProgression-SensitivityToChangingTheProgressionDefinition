classdef BrainRadiationBeamSet
    %BrainRadiationBeamSet
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        sBeamSetName (1,1) string
        sPrescriptionName string {ValidationUtils.MustBeEmptyOrScalar(sPrescriptionName)} % only for data from Pinnacle
        
        voBrainMetastasisPrescriptions (:,1) BrainMetastasisPrescription
        
        dMySQLPrimaryKey (1,1) double
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainRadiationBeamSet(sBeamSetName, voBrainMetastasisPrescriptions, sPrescriptionName, dMySQLPrimaryKey)
            %obj = BrainRadiationBeamSet(sBeamSetName, voBrainMetastasisPrescriptions, sPrescriptionName, dMySQLPrimaryKey)
            arguments
                sBeamSetName
                voBrainMetastasisPrescriptions
                sPrescriptionName
                dMySQLPrimaryKey
            end
            
            obj.sBeamSetName = sBeamSetName;
            obj.voBrainMetastasisPrescriptions = voBrainMetastasisPrescriptions;
            
            obj.sPrescriptionName = sPrescriptionName;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function sBeamSetName = GetBeamSetName(obj)
            sBeamSetName = obj.sBeamSetName;
        end
           
        function voBrainMetastasisPrescriptions = GetBrainMetastasisPrescriptions(obj)
            voBrainMetastasisPrescriptions = obj.voBrainMetastasisPrescriptions;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
    end
    
    
    methods (Access = public, Static)
                
        function voBeamSets = LoadFromDatabaseByBrainRadiationPlanId(dBrainRadiationPlanId)
            arguments
                dBrainRadiationPlanId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_radiation_beam_sets", [], "WHERE fk_brain_radiation_beam_sets_id_brain_radiation_plans = " + string(dBrainRadiationPlanId));
            
            dNumBeamSets = size(tOutput,1);
            
            if dNumBeamSets == 0
                voBeamSets = BrainRadiationBeamSet.empty;
            else
                c1oBeamSets = cell(dNumBeamSets,1);
                
                for dBeamSetIndex=1:dNumBeamSets
                    c1oBeamSets{dBeamSetIndex} = BrainRadiationBeamSet(...
                        tOutput.beam_set_name{dBeamSetIndex},...
                        BrainMetastasisPrescription.LoadFromDatabaseByBrainRadiationBeamSetId(CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tOutput.id_brain_radiation_beam_sets(dBeamSetIndex))),...
                        tOutput.prescription_name{dBeamSetIndex},...
                        tOutput.id_brain_radiation_beam_sets{dBeamSetIndex});
                end
            
                voBeamSets = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBeamSets);
            end            
        end  
        
        function voValidationRecords = Validate(voBeamSets, oParentPatient, oParentBrainRadiationCourse, oParentBrainRadiationPlan, voValidationRecords)
            for dBeamSetIndex=1:length(voBeamSets)
                % - sBeamSetName
                % none (already checked for uniqueness in
                % BrainRadiationPlan.Validate)
                
                % - sPrescriptionName
                % none
                
                % - voBrainMetastasisPrescriptions
                voValidationRecords = BrainMetastasisPrescription.Validate(voBeamSets(dBeamSetIndex).voBrainMetastasisPrescriptions, oParentPatient, oParentBrainRadiationCourse, oParentBrainRadiationPlan, voBeamSets(dBeamSetIndex), voValidationRecords);
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

