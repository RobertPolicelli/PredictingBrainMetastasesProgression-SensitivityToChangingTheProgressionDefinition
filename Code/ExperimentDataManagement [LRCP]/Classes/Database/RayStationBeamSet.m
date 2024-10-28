classdef RayStationBeamSet
    %RayStationBeamSet
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sName (1,1) string
        
        dPrescriptionDose_Gy (1,1) double
        dPrescriptionFractions (1,1) double
        
        vdTargetedBrainMetastasisNumbers (:,1) double {mustBeInteger, mustBePositive}
        vsTargetedBrainMetastasisRegionOfInterestNames (:,1) string % the names of the ROIs targeted by the beam set
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RayStationBeamSet(sName, dPrescriptionDose_Gy, dPrescriptionFractions, vdTargetedBrainMetastasisNumbers, vsTargetedBrainMetastasisRegionOfInterestNames) 
            arguments
                sName (1,1) string
                dPrescriptionDose_Gy (1,1) double {mustBePositive, mustBeFinite, mustBeLessThanOrEqual(dPrescriptionDose_Gy, 100)}
                dPrescriptionFractions (1,1) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(dPrescriptionFractions, 100)}
                vdTargetedBrainMetastasisNumbers (:,1) double {mustBeInteger, mustBePositive}
                vsTargetedBrainMetastasisRegionOfInterestNames (:,1) string
            end
            
            if sName == ""
                error(...
                    'RayStationBeamSet:Constructor:EmptyString',...
                    'The name string cannot be empty.');                
            end
                        
            if length(vsTargetedBrainMetastasisRegionOfInterestNames) ~= length(vdTargetedBrainMetastasisNumbers)
                error(...
                    'RayStationBeamSet:Constructor:ROINamesBMNumbersMismatch',...
                    'The length of vsTargetedRegionsOfInterestNames and vdBrainMetastasisNumbers must be equal.');
            end
            
            if length(unique(vdTargetedBrainMetastasisNumbers)) ~= length(vdTargetedBrainMetastasisNumbers)
                error(...
                    'RayStationBeamSet:Constructor:InvalidBrainMetNumbers',...
                    'There can be no duplicate values in vdBrainMetastasisNumbers.');                
            end
            
            obj.sName = sName;
            obj.dPrescriptionDose_Gy = dPrescriptionDose_Gy;
            obj.dPrescriptionFractions = dPrescriptionFractions;
            obj.vdTargetedBrainMetastasisNumbers = vdTargetedBrainMetastasisNumbers;
            obj.vsTargetedBrainMetastasisRegionOfInterestNames = vsTargetedBrainMetastasisRegionOfInterestNames;
        end
        
        function sName = GetName(obj)
            sName = obj.sName;
        end
        
        function dPrescriptionDose_Gy = GetPrescriptionDose_Gy(obj)
            dPrescriptionDose_Gy = obj.dPrescriptionDose_Gy;
        end
        
        function dPrescriptionFractions = GetPrescriptionFractions(obj)
            dPrescriptionFractions = obj.dPrescriptionFractions;
        end
        
        function vdTargetedBrainMetastasisNumbers = GetTargetedBrainMetastasisNumbers(obj)
            vdTargetedBrainMetastasisNumbers = obj.vdTargetedBrainMetastasisNumbers;
        end
        
        function dNumBrainMets = GetNumberOfTargetedBrainMetastases(obj)
            dNumBrainMets = length(obj.vdTargetedBrainMetastasisNumbers);
        end
        
        function vsROINames = GetRegionOfInterestNamePerTargetedBrainMetastasis(obj)
            vsROINames = obj.vsTargetedBrainMetastasisRegionOfInterestNames;
        end
        
        function bBool = ContainsTargetedBrainMetastatsisNumber(obj, dTargetedBrainMetNumber)
            bBool = any(obj.vdTargetedBrainMetastasisNumbers == dTargetedBrainMetNumber);
        end
        
        function sROIName = GetRegionOfInterestNameByTargetedBrainMetastasisNumber(obj, dTargetedBrainMetNumber)
            sROIName = obj.vsTargetedBrainMetastasisRegionOfInterestNames(obj.vdTargetedBrainMetastasisNumbers == dTargetedBrainMetNumber);
            
            if isempty(sROIName)
                error(...
                    'RayStationBeamSet:GetRegionOfInterestNameByTargetedBrainMetastasisNumber:NotFound',...
                    'Targeted brain metastasis number not in found.');
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

