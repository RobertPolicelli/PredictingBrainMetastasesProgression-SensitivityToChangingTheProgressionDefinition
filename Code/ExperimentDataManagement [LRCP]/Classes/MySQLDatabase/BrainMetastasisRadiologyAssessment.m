classdef (Abstract) BrainMetastasisRadiologyAssessment
    %BrainMetastasisRadiologyAssessment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dtScanDate (1,1) datetime
        
        dRANOMeasurement_mm (1,1) double {mustBeNonnegative}
        
        dMaxAnteriorPosteriorDiameterMeasurement_mm (1,1) double {mustBeNonnegative}
        dMaxMediolateralDiameterMeasurement_mm (1,1) double {mustBeNonnegative}
        dMaxCraniocaudalDiameterMeasurement_mm (1,1) double {mustBeNonnegative}
        
        vdMySQLPrimaryKey (1,:) double % id_size_measurements
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainMetastasisRadiologyAssessment(dtScanDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, vdMySQLPrimaryKey)
            %obj = BrainMetastasisRadiologyAssessment(dtScanDate, dRANOMeasurement_mm, dMaxAnteriorPosteriorDiameterMeasurement_mm,dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm, vdMySQLPrimaryKey)
            
            obj.dtScanDate = dtScanDate;
            
            obj.dRANOMeasurement_mm = dRANOMeasurement_mm;
            
            obj.dMaxAnteriorPosteriorDiameterMeasurement_mm = dMaxAnteriorPosteriorDiameterMeasurement_mm;
            obj.dMaxMediolateralDiameterMeasurement_mm = dMaxMediolateralDiameterMeasurement_mm;
            obj.dMaxCraniocaudalDiameterMeasurement_mm = dMaxCraniocaudalDiameterMeasurement_mm;  
            
            obj.vdMySQLPrimaryKey = vdMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtScanDate = GetScanDate(obj)
            dtScanDate = obj.dtScanDate;
        end
        
        function [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] = GetPerpendicularMaxDiameterMeasurements_mm(obj)
            dMaxAnteriorPosteriorDiameterMeasurement_mm = obj.dMaxAnteriorPosteriorDiameterMeasurement_mm;
            dMaxMediolateralDiameterMeasurement_mm = obj.dMaxMediolateralDiameterMeasurement_mm;
            dMaxCraniocaudalDiameterMeasurement_mm = obj.dMaxCraniocaudalDiameterMeasurement_mm;
        end
        
        function dPseudoVolumetricMeasurement_mm = GetPseudoVolumetricMeasurement_mm(obj)
            dPseudoVolumetricMeasurement_mm = obj.dMaxAnteriorPosteriorDiameterMeasurement_mm * obj.dMaxMediolateralDiameterMeasurement_mm * obj.dMaxCraniocaudalDiameterMeasurement_mm;
        end
        
        function dLongestDiameter_mm = GetLongestDiameter_mm(obj)
            dLongestDiameter_mm = [obj.dMaxAnteriorPosteriorDiameterMeasurement_mm, obj.dMaxMediolateralDiameterMeasurement_mm, obj.dMaxCraniocaudalDiameterMeasurement_mm];
            dLongestDiameter_mm = max(dLongestDiameter_mm);
        end
        
        function dLongestDiameterAxial_mm = GetLongestDiameterAxial_mm(obj)
            dLongestDiameterAxial_mm = [obj.dMaxAnteriorPosteriorDiameterMeasurement_mm, obj.dMaxMediolateralDiameterMeasurement_mm];
            dLongestDiameterAxial_mm = max(dLongestDiameterAxial_mm);
        end
        
        function dSumofDiameter_mm = GetSumofDiameter_mm(obj)
            dSumofDiameter_mm = obj.dMaxAnteriorPosteriorDiameterMeasurement_mm + obj.dMaxMediolateralDiameterMeasurement_mm + obj.dMaxCraniocaudalDiameterMeasurement_mm;
        end
        
        function dRANOMeasurement_mm = GetRANOMeasurement_mm(obj)
            dRANOMeasurement_mm = obj.dRANOMeasurement_mm;
        end
        
        function vdMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            vdMySQLPrimaryKey = obj.vdMySQLPrimaryKey;
        end
    end
    
    
    methods (Access = public, Static)

        function MustAllHaveSameScanDate(voObjs)
            arguments
                voObjs (:,1) BrainMetastasisRadiologyAssessment
            end

            if ~isempty(voObjs)
                dtScanDate = voObjs(1).dtScanDate;

                for dObjIndex=2:length(voObjs)
                    if dtScanDate ~= voObjs(dObjIndex).dtScanDate
                        error(...
                            'BrainMetastasisRadiologyAssessment:MustAllHaveSameScanDate:DifferentScanDates',...
                            'All assessments must have the same scan date.');
                    end
                end
            end
        end
        
        function voValidationRecords = Validate(voBrainMetastasisRadiologyAssessments, oParentPatient, oParentRadiologyAssessment, voValidationRecords)
            for dAssesssmentIndex=1:length(voBrainMetastasisRadiologyAssessments)
                oAssessment = voBrainMetastasisRadiologyAssessments(dAssesssmentIndex);
                
                % - dtScanDate
                % -- not the same as oParentRadiologyAssessment (which had
                % further validation performed)
                if oAssessment.dtScanDate ~= oParentRadiologyAssessment.GetScanDate()
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oAssessment, "dtScanDate", "Does not match parent radiology assessment scan date"));
                end
                
                % - dRANOMeasurement_mm
                % -- > 100mm
                if oAssessment.dRANOMeasurement_mm > 100
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oAssessment, "dRANOMeasurement_mm", "Value exceeds 100mm"));
                end
                
                % - dMaxAnteriorPosteriorDiameterMeasurement_mm
                % -- > 100mm
                if oAssessment.dMaxAnteriorPosteriorDiameterMeasurement_mm > 100
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oAssessment, "dMaxAnteriorPosteriorDiameterMeasurement_mm", "Value exceeds 100mm"));
                end
                
                % - dMaxMediolateralDiameterMeasurement_mm
                % -- > 100mm
                if oAssessment.dMaxMediolateralDiameterMeasurement_mm > 100
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oAssessment, "dMaxMediolateralDiameterMeasurement_mm", "Value exceeds 100mm"));
                end
                
                % - dMaxCraniocaudalDiameterMeasurement_mm
                % -- > 100mm
                if oAssessment.dMaxCraniocaudalDiameterMeasurement_mm > 100
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oAssessment, "dMaxCraniocaudalDiameterMeasurement_mm", "Value exceeds 100mm"));
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

