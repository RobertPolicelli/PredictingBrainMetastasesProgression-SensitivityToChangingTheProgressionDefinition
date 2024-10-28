classdef BrainMetastasisPrescription
    %BrainMetastasisPrescription
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dDose_Gy (1,1) double {mustBePositive, mustBeFinite} = 1
        dNumberOfFractions (1,1) double {mustBePositive, mustBeInteger} = 1
        
        sGTVStructureName (1,1) string        
        
        oBrainMetastasis BrainMetastasis {ValidationUtils.MustBeEmptyOrScalar}
        
        vdMySQLPrimaryKey (1,:) double
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainMetastasisPrescription(dDose_Gy, dNumberOfFractions, sGTVStructureName, oBrainMetastasis, vdMySQLPrimaryKey)
            %obj = BrainMetastasisPrescription(dDose_Gy, dNumberOfFractions, sGTVStructureName, oBrainMetastasis, vdMySQLPrimaryKey)
            arguments
                dDose_Gy
                dNumberOfFractions
                sGTVStructureName
                oBrainMetastasis (1,1) BrainMetastasis
                vdMySQLPrimaryKey
            end
            
            obj.dDose_Gy = dDose_Gy;
            obj.dNumberOfFractions = dNumberOfFractions;
            
            obj.sGTVStructureName = sGTVStructureName;
            
            obj.oBrainMetastasis = oBrainMetastasis;
            
            obj.vdMySQLPrimaryKey = vdMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function sGTVStructureName = GetGTVStructureName(obj)
            sGTVStructureName = obj.sGTVStructureName;
        end
        
        function oBrainMetastasis = GetBrainMetastasis(obj)
            oBrainMetastasis = obj.oBrainMetastasis;
        end
        
        function vdMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            vdMySQLPrimaryKey = obj.vdMySQLPrimaryKey;
        end
        
        function dDose_Gy = GetDose_Gy(obj)
            dDose_Gy = obj.dDose_Gy;
        end
        
        function dNumberOfFractions = GetNumberOfFractions(obj)
            dNumberOfFractions = obj.dNumberOfFractions;
        end
    end
    
    
    methods (Access = public, Static)
                
        function voPrescriptions = LoadFromDatabaseByBrainRadiationBeamSetId(dBrainRadiationBeamSetId)
            arguments
                dBrainRadiationBeamSetId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastasis_prescriptions", [], "WHERE fk_bm_prescriptions_id_brain_radiation_beam_sets = " + string(dBrainRadiationBeamSetId));
            
            dNumPrescriptions = size(tOutput,1);
            
            if dNumPrescriptions == 0
                voPrescriptions = BrainMetastasisPrescription.empty;
            else
                c1oPrescriptions = cell(dNumPrescriptions,1);
                
                for dPrescriptionIndex=1:dNumPrescriptions
                    c1oPrescriptions{dPrescriptionIndex} = BrainMetastasisPrescription(...
                        tOutput.dose_gy{dPrescriptionIndex},...
                        tOutput.number_of_fractions{dPrescriptionIndex},...
                        tOutput.gtv_structure_name{dPrescriptionIndex},...
                        BrainMetastasis.LoadFromDatabaseByPatientStudyIdAndBrainMetastasisNumber(...
                        tOutput.fk_bm_prescriptions_fk_brain_metastases_patient_study_id{dPrescriptionIndex}, tOutput.fk_bm_prescriptions_brain_metastasis_number{dPrescriptionIndex}),...
                        [tOutput.fk_bm_prescriptions_fk_brain_metastases_patient_study_id{dPrescriptionIndex}, tOutput.fk_bm_prescriptions_brain_metastasis_number{dPrescriptionIndex}, tOutput.fk_bm_prescriptions_id_brain_radiation_beam_sets{dPrescriptionIndex}]);
                end
            
                voPrescriptions = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPrescriptions);
            end            
        end   
        
        function voValidationRecords = Validate(voBrainMetastasisPrescriptions, oParentPatient, oParentBrainRadiationCourse, oParentBrainRadiationPlan, oParentBrainRadiationBeamSet, voValidationRecords)
            for dPrescriptionIndex=1:length(voBrainMetastasisPrescriptions)            
                oPrescription = voBrainMetastasisPrescriptions(dPrescriptionIndex);
                
                % - dDose_Gy
                % -- > 35
                if oPrescription.dDose_Gy > 35
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPrescription, "dDose_Gy", "Greater than 35 Gy"));
                end
                
                % -- < 15
                if oPrescription.dDose_Gy < 15
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPrescription, "dDose_Gy", "Less than 15 Gy"));
                end
                
                % - dNumberOfFractions
                % -- not equal to 1, 3 nor 5
                if oPrescription.dNumberOfFractions ~= 1 && oPrescription.dNumberOfFractions ~= 3 && oPrescription.dNumberOfFractions ~= 5
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPrescription, "dNumberOfFractions", "Number of fractions not 1, 3 nor 5"));
                end                
                
                % - sGTVStructureName
                % none (already validated to be unique across all plans in
                % BrainRadiationPlan.Validate)
                
                % - oBrainMetastasis
                % none (already validated that all brain metastasis numbers
                % appear across plans in BrainRadiationPlan.Validate)
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

