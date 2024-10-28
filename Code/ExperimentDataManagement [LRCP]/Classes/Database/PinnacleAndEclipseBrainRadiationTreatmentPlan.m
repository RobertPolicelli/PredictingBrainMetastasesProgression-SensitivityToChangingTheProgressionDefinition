classdef PinnacleAndEclipseBrainRadiationTreatmentPlan < BrainRadiationTreatmentPlan
    %PinnacleAndEclipseBrainRadiationTreatmentPlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voPlans (:,1) EclipsePlan = EclipsePlan.empty(0,1)
        voPinnacleRegistrationSpecifications (:,1) PinnacleRegistrationSpecification = PinnacleRegistrationSpecification.empty(0,1)
             
        sCTSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        sMRT1wPreContrastSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRT1wPostContrastSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRT2wSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRFractionalAnisotropySeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRApparentDiffusionCoefficientSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        bMRT1wPostContrastRegistrationOntoMR (1,1) logical = false % false if the MRI is registered onto the CT
        bMRT2wRegistrationOntoMR (1,1) logical = false % false if the MRI is registered onto the CT
        
        vsRegistrationDicomFilePathPerRegistrationSpecification (:,1) string
                
        sRTStructDicomFilePath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        vsRTDoseDicomFilePaths (1,:) string  = string.empty(1,0)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = PinnacleAndEclipseBrainRadiationTreatmentPlan(voPlans, voPinnacleRegistrationSpecifications)
            arguments
                voPlans (:,1) EclipsePlan
                voPinnacleRegistrationSpecifications (:,1) PinnacleRegistrationSpecification
            end
                        
            % validate plans
            vdBrainMetNumbers = [];
            
            for dPlanIndex=1:length(voPlans)
                vdBrainMetNumbers = [vdBrainMetNumbers; voPlans(dPlanIndex).GetTargetedBrainMetastasisNumbers()];
            end
            
            if ~all(sort(vdBrainMetNumbers, 'ascend') == (1:length(vdBrainMetNumbers))')
                error(...
                    'PinnacleAndEclipseBrainRadiationTreatmentPlan:Constructor:InvalidBrainMetNumbersAcrossPlansAndBeamSets',...
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
                    'PinnacleAndEclipseBrainRadiationTreatmentPlan:Constructor:DuplicateRegistrations',...
                    'There should only be one registration per T2, T1 pre and T1 post scans');
            end
            
            if dNumT1PostRegistrations == 0
                error(...
                    'PinnacleAndEclipseBrainRadiationTreatmentPlan:Constructor:NoT1PostRegistration',...
                    'There should be a T1 post registration');
            end
            
            
            % set properities
            obj.voPlans = voPlans;
            obj.voPinnacleRegistrationSpecifications = voPinnacleRegistrationSpecifications;
        end
        
        function bMRT1wPostContrastRegistrationOntoMR  = IsMRT1wPostContrastRegistrationOntoMR(obj)
            bMRT1wPostContrastRegistrationOntoMR = obj.bMRT1wPostContrastRegistrationOntoMR;
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
            
            sROIName = oPlan.GetRegionOfInterestNameByTargetedBrainMetastasisNumber(dTargetedBrainMetNumber);
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
                    'PinnacleAndEclipseBrainRadiationTreatmentPlan:GetPlanWithTargetedBrainMetastatsisNumber:NoPlanFound',...
                    'No plan with the targeted brain metastasis number provided found.');
            end
        end
        
        function SetPreTreatmentImagingSeriesPathsAndRegistrationFilePaths(obj, NameValueArgs)
            arguments
                obj (1,1) PinnacleAndEclipseBrainRadiationTreatmentPlan
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
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:CTFieldAlreadySet',...
                        'CT field has already been set.');
                end
                
                obj.sCTSeriesDicomFolderPath = NameValueArgs.CT;
            end
            
            if isfield(NameValueArgs, 'MRT1wPre')
                if ~isempty(obj.sMRT1wPreContrastSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPreFieldAlreadySet',...
                        'MRT1wPre field has already been set.');
                end
                
                obj.sMRT1wPreContrastSeriesDicomFolderPath = NameValueArgs.MRT1wPre;
            end
            
            if isfield(NameValueArgs, 'MRT1wPost')
                if ~isempty(obj.sMRT1wPostContrastSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPostFieldAlreadySet',...
                        'MRT1wPost field has already been set.');
                end
                
                obj.sMRT1wPostContrastSeriesDicomFolderPath = NameValueArgs.MRT1wPost;
            end
            
            if isfield(NameValueArgs, 'MRT2w')
                if ~isempty(obj.sMRT2wSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT2wFieldAlreadySet',...
                        'MRT2w field has already been set.');
                end
                
                obj.sMRT2wSeriesDicomFolderPath = NameValueArgs.MRT2w;
            end
                        
            if isfield(NameValueArgs, 'MRFA')
                if ~isempty(obj.sMRFractionalAnisotropySeriesDicomFolderPath)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRFAFieldAlreadySet',...
                        'MRFA field has already been set.');
                end
                
                obj.sMRFractionalAnisotropySeriesDicomFolderPath = NameValueArgs.MRFA;
            end
                        
            if isfield(NameValueArgs, 'MRADC')
                if ~isempty(obj.sMRApparentDiffusionCoefficientSeriesDicomFolderPath)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRADCFieldAlreadySet',...
                        'MRADC field has already been set.');
                end
                
                obj.sMRApparentDiffusionCoefficientSeriesDicomFolderPath = NameValueArgs.MRADC;
            end
                        
            if isfield(NameValueArgs, 'FilePathPerRegistration')
                if ~isempty(obj.vsRegistrationDicomFilePathPerRegistrationSpecification)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPostRegistrationFieldAlreadySet',...
                        'vsRegistrationDicomFilePathPerRegistrationSpecification field has already been set.');
                end
                
                if length(NameValueArgs.FilePathPerRegistration) ~= length(obj.voPinnacleRegistrationSpecifications)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:NumberOfFilesMismatch',...
                        'Number of files must equal the number of registrations.');
                end
                
                obj.vsRegistrationDicomFilePathPerRegistrationSpecification = NameValueArgs.FilePathPerRegistration;
            end
                        
            if isfield(NameValueArgs, 'RTStruct')
                if ~isempty(obj.sRTStructDicomFilePath)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:RTStructFieldAlreadySet',...
                        'RTStruct field has already been set.');
                end
                
                obj.sRTStructDicomFilePath = NameValueArgs.RTStruct;
            end
                        
            if isfield(NameValueArgs, 'RTDose')
                if ~isempty(obj.vsRTDoseDicomFilePaths)
                    error(...
                        'PinnacleAndEclipseBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:RTDoseFieldAlreadySet',...
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
            dNumPlans = length(obj.voPlans);
                        
            vsPlanTrialNames = strings(dNumPlans,1);
            vdPlanTrialPrescribedDoses_Gy = zeros(dNumPlans,1);
            vdPlanTrialPrescribedFractions = zeros(dNumPlans,1);
            c1vdBMsTargeted = cell(dNumPlans,1);
            
            dCurrentPlanTrialIndex = 1;
            
            for dPlanIndex=1:length(obj.voPlans)
                oPlan = obj.voPlans(dPlanIndex);
                    
                vsPlanTrialNames(dCurrentPlanTrialIndex) = oPlan.GetName();
                vdPlanTrialPrescribedDoses_Gy(dCurrentPlanTrialIndex) = oPlan.GetPrescriptionDose_Gy();
                vdPlanTrialPrescribedFractions(dCurrentPlanTrialIndex) = oPlan.GetPrescriptionFractions();
                c1vdBMsTargeted{dCurrentPlanTrialIndex} = oPlan.GetTargetedBrainMetastasisNumbers();
                
                dCurrentPlanTrialIndex = dCurrentPlanTrialIndex + 1;
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

