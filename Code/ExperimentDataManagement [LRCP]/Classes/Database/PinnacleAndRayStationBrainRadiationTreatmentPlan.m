classdef PinnacleAndRayStationBrainRadiationTreatmentPlan < BrainRadiationTreatmentPlan
    %PinnacleAndRayStationBrainRadiationTreatmentPlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voPlans (:,1) RayStationPlan = RayStationPlan.empty(0,1)
        voPinnacleRegistrationSpecifications (:,1) PinnacleRegistrationSpecification = PinnacleRegistrationSpecification.empty(0,1)
             
        sCTSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        sMRT1wPreContrastSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRT1wPostContrastSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRT2wSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRFractionalAnisotropySeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRApparentDiffusionCoefficientSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        vsRegistrationDicomFilePathPerRegistrationSpecification (:,1) string
                
        sRTStructDicomFilePath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        vsRTDoseDicomFilePaths (1,:) string  = string.empty(1,0)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = PinnacleAndRayStationBrainRadiationTreatmentPlan(voPlans, voPinnacleRegistrationSpecifications)
            arguments
                voPlans (:,1) RayStationPlan
                voPinnacleRegistrationSpecifications (:,1) PinnacleRegistrationSpecification
            end
                        
            % validate plans
            vdBrainMetNumbers = [];
            
            for dPlanIndex=1:length(voPlans)
                voBeamSets = voPlans(dPlanIndex).GetBeamSets();
                
                for dPlanTrialIndex=1:length(voBeamSets)
                    vdBrainMetNumbers = [vdBrainMetNumbers; voBeamSets(dPlanTrialIndex).GetTargetedBrainMetastasisNumbers()];
                end
            end
            
            if ~all(sort(vdBrainMetNumbers, 'ascend') == (1:length(vdBrainMetNumbers))')
                error(...
                    'PinnacleAndRayStationBrainRadiationTreatmentPlan:Constructor:InvalidBrainMetNumbersAcrossPlansAndBeamSets',...
                    'The brain met numbers across all plans and plan trials must be non-duplicated and range from 1 to n, where is the total number of brain mets.');
            end
            
            % validate registration
            dNumT1PostRegistrations = 0;
            dNumT1PreRegistrations = 0;
            dNumT2Registrations = 0;
            
            for dRegIndex=1:length(voPinnacleRegistrationSpecifications)
                switch voPinnacleRegistrationSpecifications(dRegIndex).GetScanType()
                    case PinnacleRegistrationSpecificationScanType.T2
                        dNumT2Registrations = dNumT2Registrations + 1;
                    case PinnacleRegistrationSpecificationScanType.T1Post
                        dNumT1PostRegistrations = dNumT1PostRegistrations + 1;
                    case PinnacleRegistrationSpecificationScanType.T1Pre
                        dNumT1PreRegistrations = dNumT1PreRegistrations + 1;
                end
            end
            
            if dNumT2Registrations > 1 || dNumT1PostRegistrations > 1 || dNumT1PreRegistrations > 1
                error(...
                    'PinnacleAndRayStationBrainRadiationTreatmentPlan:Constructor:DuplicateRegistrations',...
                    'There should only be one registration per T2, T1 pre and T1 post scans');
            end
            
            if dNumT1PostRegistrations == 0
                error(...
                    'PinnacleAndRayStationBrainRadiationTreatmentPlan:Constructor:NoT1PostRegistration',...
                    'There should be a T1 post registration');
            end
            
            
            % set properities
            obj.voPlans = voPlans;
            obj.voPinnacleRegistrationSpecifications = voPinnacleRegistrationSpecifications;
        end
        
        function bIsMRT1wPostContrastRegistrationOntoMR = IsMRT1wPostContrastRegistrationOntoMR(obj)
            bIsMRT1wPostContrastRegistrationOntoMR = false; % always onto CT
        end
        
        function voRegSpecs = GetRegistrationSpecifications(obj)
            voRegSpecs = obj.voPinnacleRegistrationSpecifications;
        end
        
        function dNumPlans = GetNumberOfPlans(obj)
            dNumPlans = length(obj.voPlans);
        end
        
        function dNumBeamSets = GetNumberOfBeamSets(obj)
            dNumBeamSets = 0;
            
            for dPlanIndex=1:length(obj.voPlans)
                dNumBeamSets = dNumBeamSets + obj.voPlans(dPlanIndex).GetNumberOfBeamSets();
            end
        end
        
        function sPath = GetT1PostContrastMRIDicomFolderPath(obj)
            sPath = obj.sMRT1wPostContrastSeriesDicomFolderPath;
        end
        
        function sPath = GetCTSimDicomFolderPath(obj)            
            sPath = obj.sCTSeriesDicomFolderPath;
        end
        
        function sPath = GetT1PostContrastMRIToCTSimRegistrationDicomFilePath(obj)
            dT1PostRegIndex = 0;
            
            for dRegIndex=1:length(obj.voPinnacleRegistrationSpecifications)
                if obj.voPinnacleRegistrationSpecifications(dRegIndex).GetScanType() == PinnacleRegistrationSpecificationScanType.T1Post
                    dT1PostRegIndex = dRegIndex;
                    break;
                end
            end
            
            sPath = obj.vsRegistrationDicomFilePathPerRegistrationSpecification(dT1PostRegIndex);
        end
        
        function sPath = GetRTStructDicomFilePath(obj)
            sPath = obj.sRTStructDicomFilePath;
        end
        
        function dNumBrainMets = GetNumberOfTargetedBrainMetastases(obj)
            dNumBrainMets = 0;
            
            for dPlanIndex=1:length(obj.voPlans)
                dNumBrainMets = dNumBrainMets + obj.voPlans(dPlanIndex).GetNumberOfTargetedBrainMetastases();
            end
        end
        
        function vsROINamePerBrainMet = GetRegionOfInterestNamePerTargetedBrainMetastasis(obj)
            dNumBrainMets = obj.GetNumberOfTargetedBrainMetastases();
            vsROINamePerBrainMet = strings(1,dNumBrainMets);
            
            for dBrainMetIndex=1:dNumBrainMets
                vsROINamePerBrainMet(dBrainMetIndex) = obj.GetRegionOfInterestNameByTargetedBrainMetastasisNumber(dBrainMetIndex);
            end
        end
        
        function sROIName = GetRegionOfInterestNameByTargetedBrainMetastasisNumber(obj, dTargetedBrainMetNumber)
            oPlan = obj.GetPlanWithTargetedBrainMetastatsisNumber(dTargetedBrainMetNumber);
            
            oBeamSet = oPlan.GetBeamSetWithTargetedBrainMetastatsisNumber(dTargetedBrainMetNumber);
            
            sROIName = oBeamSet.GetRegionOfInterestNameByTargetedBrainMetastasisNumber(dTargetedBrainMetNumber);
        end
        
        function oPlan = GetPlanWithTargetedBrainMetastatsisNumber(obj, dTargetedBrainMetNumber)
            oPlan = [];
            
            for dPlanIndex=1:length(obj.voPlans)
                if obj.voPlans(dPlanIndex).ContainsTargetedBrainMetastatsisNumber(dTargetedBrainMetNumber)
                    oPlan = obj.voPlans(dPlanIndex);
                end
            end
            
            if isempty(oPlan)
                error(...
                    'PinnacleAndRayStationBrainRadiationTreatmentPlan:GetPlanWithTargetedBrainMetastatsisNumber:NoPlanFound',...
                    'No plan with the targeted brain metastasis number provided found.');
            end
        end
        
        function SetPreTreatmentImagingSeriesPathsAndRegistrationFilePaths(obj, NameValueArgs)
            arguments
                obj (1,1) PinnacleAndRayStationBrainRadiationTreatmentPlan
                NameValueArgs.CT (1,1) string
                NameValueArgs.MRT1wPre (1,1) string
                NameValueArgs.MRT1wPost (1,1) string
                NameValueArgs.MRT2w (1,1) string
                NameValueArgs.MRFA (1,1) string
                NameValueArgs.MRADC (1,1) string
                NameValueArgs.FilePathPerRegistration(:,1) string
                NameValueArgs.RTStruct (1,1) string
                NameValueArgs.RTDose (1,:) string
            end
            
            if isfield(NameValueArgs, 'CT')
                if ~isempty(obj.sCTSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:CTFieldAlreadySet',...
                        'CT field has already been set.');
                end
                
                obj.sCTSeriesDicomFolderPath = NameValueArgs.CT;
            end
            
            if isfield(NameValueArgs, 'MRT1wPre')
                if ~isempty(obj.sMRT1wPreContrastSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPreFieldAlreadySet',...
                        'MRT1wPre field has already been set.');
                end
                
                obj.sMRT1wPreContrastSeriesDicomFolderPath = NameValueArgs.MRT1wPre;
            end
            
            if isfield(NameValueArgs, 'MRT1wPost')
                if ~isempty(obj.sMRT1wPostContrastSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPostFieldAlreadySet',...
                        'MRT1wPost field has already been set.');
                end
                
                obj.sMRT1wPostContrastSeriesDicomFolderPath = NameValueArgs.MRT1wPost;
            end
            
            if isfield(NameValueArgs, 'MRT2w')
                if ~isempty(obj.sMRT2wSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT2wFieldAlreadySet',...
                        'MRT2w field has already been set.');
                end
                
                obj.sMRT2wSeriesDicomFolderPath = NameValueArgs.MRT2w;
            end
                        
            if isfield(NameValueArgs, 'MRFA')
                if ~isempty(obj.sMRFractionalAnisotropySeriesDicomFolderPath)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRFAFieldAlreadySet',...
                        'MRFA field has already been set.');
                end
                
                obj.sMRFractionalAnisotropySeriesDicomFolderPath = NameValueArgs.MRFA;
            end
                        
            if isfield(NameValueArgs, 'MRADC')
                if ~isempty(obj.sMRApparentDiffusionCoefficientSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRADCFieldAlreadySet',...
                        'MRADC field has already been set.');
                end
                
                obj.sMRApparentDiffusionCoefficientSeriesDicomFolderPath = NameValueArgs.MRADC;
            end
                        
            if isfield(NameValueArgs, 'FilePathPerRegistration')
                if ~isempty(obj.vsRegistrationDicomFilePathPerRegistrationSpecification)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPostRegistrationFieldAlreadySet',...
                        'vsRegistrationDicomFilePathPerRegistrationSpecification field has already been set.');
                end
                
                if length(NameValueArgs.FilePathPerRegistration) ~= length(obj.voPinnacleRegistrationSpecifications)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:NumberOfFilesMismatch',...
                        'Number of files must equal the number of registrations.');
                end
                
                obj.vsRegistrationDicomFilePathPerRegistrationSpecification = NameValueArgs.FilePathPerRegistration;
            end
                        
            if isfield(NameValueArgs, 'RTStruct')
                if ~isempty(obj.sRTStructDicomFilePath)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:RTStructFieldAlreadySet',...
                        'RTStruct field has already been set.');
                end
                
                obj.sRTStructDicomFilePath = NameValueArgs.RTStruct;
            end
                        
            if isfield(NameValueArgs, 'RTDose')
                if ~isempty(obj.vsRTDoseDicomFilePaths)
                    error(...
                        'PinnacleAndRayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:RTDoseFieldAlreadySet',...
                        'RTDose field has already been set.');
                end
                
                obj.vsRTDoseDicomFilePaths = NameValueArgs.RTDose;
            end
        end
            
        function [vdtRegistrationTimeStamps, vsRegistrationFromImagingSeriesNames, vsRegistrationToImagingSeriesNames] = GetPinnacleRegistrationData(obj)
            vdtRegistrationTimeStamps = obj.vdtPinnacleRegistrationTimeStamps;
            vsRegistrationFromImagingSeriesNames = obj.vsPinnacleRegistrationFromImagingSeriesNames;
            vsRegistrationToImagingSeriesNames = obj.vsPinnacleRegistrationToImagingSeriesNames;
        end
        
        function [vsPlanTrialNames, vdPlanTrialPrescribedDoses_Gy, vdPlanTrialPrescribedFractions, c1vdBMsTargeted] = GetAllBeamSetData(obj) % "Beam Set" = "Plan Trial" in Pinnacle
            dNumBeamSets = 0;
            
            for dPlanIndex=1:length(obj.voPlans)
                dNumBeamSets = dNumBeamSets + obj.voPlans(dPlanIndex).GetNumberOfBeamSets();
            end
            
            vsPlanTrialNames = strings(dNumBeamSets,1);
            vdPlanTrialPrescribedDoses_Gy = zeros(dNumBeamSets,1);
            vdPlanTrialPrescribedFractions = zeros(dNumBeamSets,1);
            c1vdBMsTargeted = cell(dNumBeamSets,1);
            
            dCurrentPlanTrialIndex = 1;
            
            for dPlanIndex=1:length(obj.voPlans)
                voBeamSets = obj.voPlans(dPlanIndex).GetBeamSets();
                
                for dPlanTrialIndex=1:length(voBeamSets)
                    oPlanTrial = voBeamSets(dPlanTrialIndex);
                    
                    vsPlanTrialNames(dCurrentPlanTrialIndex) = oPlanTrial.GetName();
                    vdPlanTrialPrescribedDoses_Gy(dCurrentPlanTrialIndex) = oPlanTrial.GetPrescriptionDose_Gy();
                    vdPlanTrialPrescribedFractions(dCurrentPlanTrialIndex) = oPlanTrial.GetPrescriptionFractions();                                        
                    c1vdBMsTargeted{dCurrentPlanTrialIndex} = oPlanTrial.GetTargetedBrainMetastasisNumbers();
                    
                    dCurrentPlanTrialIndex = dCurrentPlanTrialIndex + 1;
                end
            end
        end
        
        function dNumRegs = GetNumberOfRegistrations(obj)
            dNumRegs = length(obj.vdtPinnacleRegistrationTimeStamps);
        end
    end
    
    
    methods (Access = public, Static)
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

