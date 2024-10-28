classdef BrainMetastasisPreTreatmentRadiologyAssessment < BrainMetastasisRadiologyAssessment
    %BrainMetastasisPreTreatmentRadiologyAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        bIsParenchymal (1,1) logical
        bEdemaPresent (1,1) logical
        bModerateOrHighMassEffectPresent (1,1) logical
        
        eAppearanceScore (1,1) BrainMetastasisAppearanceScore
        
        % vdMySQLPrimaryKey (1,:) double % [id_size_measurements, id_qualitative_measurements]
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainMetastasisPreTreatmentRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, bIsParenchymal,  bEdemaPresent, bModerateOrHighMassEffectPresent, eAppearanceScore, vdMySQLPrimaryKey)
            %obj = BrainMetastasisPreTreatmentRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, bIsParenchymal, bEdemaPresent, bModerateOrHighMassEffectPresent, eAppearanceScore, vdMySQLPrimaryKey)
            
            obj@BrainMetastasisRadiologyAssessment(dtDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, vdMySQLPrimaryKey(1));
            
            obj.bIsParenchymal = bIsParenchymal;
            obj.bEdemaPresent = bEdemaPresent;
            obj.bModerateOrHighMassEffectPresent = bModerateOrHighMassEffectPresent;
            
            obj.eAppearanceScore = eAppearanceScore;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function bIsParenchymal = IsParenchymal(obj)
            bIsParenchymal = obj.bIsParenchymal;
        end
        
        function eAppearanceScore = GetAppearanceScore(obj)
            eAppearanceScore = obj.eAppearanceScore;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voBrainMetastasisAssessments = LoadFromDatabaseByRadiologyAssessmentId(dRadiologyAssessmentId)
            arguments
                dRadiologyAssessmentId (1,1) double {mustBeInteger, mustBePositive}
            end
            
            tScanDateOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "radiology_assessments", "scan_date", SQLUtilities.CreateWhereStatementForEqualityOnAllColumnValues("id_radiology_assessments", {dRadiologyAssessmentId}));
            dtScanDate = tScanDateOutput.scan_date{1};
                        
            sJoinStatement = " size_measurements JOIN qualitative_measurements ON " + ...
                "size_measurements.fk_size_measurements_id_radiology_assessments = qualitative_measurements.fk_qualitative_measurements_id_radiology_assessments AND " + ...
                "size_measurements.fk_size_measurements_brain_metastases_patient_study_id = qualitative_measurements.fk_qualitative_measurements_brain_metastases_patient_study_id AND " + ...
                "size_measurements.fk_size_measurements_brain_metastasis_number = qualitative_measurements.fk_qualitative_measurements_brain_metastasis_number";
            sWhereStatement = "WHERE size_measurements.fk_size_measurements_id_radiology_assessments = " + string(dRadiologyAssessmentId);        
            sOrderSatement = "ORDER BY size_measurements.fk_size_measurements_brain_metastasis_number";
            
            vsColumns = ["id_size_measurements" "id_qualitative_measurements" "fk_size_measurements_brain_metastasis_number" "rano_bm_measurement_mm" "anterior_posterior_diameter_mm" "mediolateral_diameter_mm" "craniocaudal_diameter_mm" "metastasis_is_parenchymal" "edema_present" "mass_effect_present" "appearance"];
            
            tAssessmentOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoinStatement, vsColumns, sWhereStatement, sOrderSatement);
            
            vdBMNumbers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tAssessmentOutput.fk_size_measurements_brain_metastasis_number);
            
            if ~all(vdBMNumbers == (1:length(vdBMNumbers))')
                error(...
                    'BrainMetastasisPreTreatmentRadiologyAssessment:LoadFromDatabaseByRadiologyAssessmentId:InvalidBMNumbers',...
                    'BM numbers should be 1 to number of BMs.');
            end
            
            if isempty(vdBMNumbers)
                voBrainMetastasisAssessments = BrainMetastasisPreTreatmentRadiologyAssessment.empty;
            else
                dNumBMs = length(vdBMNumbers);
                
                c1oBrainMetastasisAssessments = cell(dNumBMs,1);
                
                for dBMIndex=1:dNumBMs
                    c1oBrainMetastasisAssessments{dBMIndex,1} = BrainMetastasisPreTreatmentRadiologyAssessment(...
                        dtScanDate,...
                        tAssessmentOutput.rano_bm_measurement_mm{dBMIndex},...
                        tAssessmentOutput.anterior_posterior_diameter_mm{dBMIndex},...
                    	tAssessmentOutput.mediolateral_diameter_mm{dBMIndex},...
                        tAssessmentOutput.craniocaudal_diameter_mm{dBMIndex},...
                        tAssessmentOutput.metastasis_is_parenchymal{dBMIndex},...
                        tAssessmentOutput.edema_present{dBMIndex},...
                        tAssessmentOutput.mass_effect_present{dBMIndex},...
                        BrainMetastasisAppearanceScore.GetEnumFromMySQLEnumValue(tAssessmentOutput.appearance{dBMIndex}),...
                        [tAssessmentOutput.id_size_measurements{dBMIndex}, tAssessmentOutput.id_qualitative_measurements{dBMIndex}]);
                end
                
                voBrainMetastasisAssessments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBrainMetastasisAssessments);
            end
        end
        
        function voValidationRecords = Validate(voBrainMetastasisRadiologyAssessments, oParentPatient, oParentRadiologyAssessment, voValidationRecords)
            voValidationRecords = Validate@BrainMetastasisRadiologyAssessment(voBrainMetastasisRadiologyAssessments, oParentPatient, oParentRadiologyAssessment, voValidationRecords);
            
            for dAssesssmentIndex=1:length(voBrainMetastasisRadiologyAssessments)
                oAssessment = voBrainMetastasisRadiologyAssessments(dAssesssmentIndex);
                
                % - bIsParenchymal
                % none
                
                % - bEdemaPresent
                % none
                
                % - bModerateOrHighMassEffectPresent                
                % none
                
                % - eAppearanceScore
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

