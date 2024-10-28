classdef RayStationBrainRadiationTreatmentPlan < BrainRadiationTreatmentPlan
    %RayStationBrainRadiationTreatmentPlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voPlans (:,1) RayStationPlan = RayStationPlan.empty(0,1)
             
        sCTSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        sMRT1wPreContrastSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRT1wPostContrastSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRT2wSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRFractionalAnisotropySeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRApparentDiffusionCoefficientSeriesDicomFolderPath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        sMRT1wPostContrastRegistrationDicomFilePath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        sMRT2wRegistrationDicomFilePath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        bMRT1wPostContrastRegistrationOntoMR (1,1) logical = false % false if the MRI is registered onto the CT
        bMRT2wRegistrationOntoMR (1,1) logical = false % false if the MRI is registered onto the CT
        
        bMRT2RegisteredToCT (1,1) logical = true
        bMRT2RegisteredToMRT1wPostContrast (1,1) logical = false
        
        sRTStructDicomFilePath string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        vsRTDoseDicomFilePaths (1,:) string  = string.empty(1,0)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RayStationBrainRadiationTreatmentPlan(voPlans)
            arguments
                voPlans (:,1) RayStationPlan
            end
            
            % validate plans
            vdBrainMetNumbers = [];
            
            for dPlanIndex=1:length(voPlans)
                voBeamSets = voPlans(dPlanIndex).GetBeamSets();
                
                for dBeamSetIndex=1:length(voBeamSets)
                    vdBrainMetNumbers = [vdBrainMetNumbers; voBeamSets(dBeamSetIndex).GetTargetedBrainMetastasisNumbers()];
                end
            end
            
            if ~all(sort(vdBrainMetNumbers, 'ascend') == (1:length(vdBrainMetNumbers))')
                error(...
                    'RayStationBrainRadiationTreatmentPlan:Constructor:InvalidBrainMetNumbersAcrossPlansAndBeamSets',...
                    'The brain met numbers across all plans and beam sets must be non-duplicated and range from 1 to n, where is the total number of brain mets.');
            end
            
            % set properities
            obj.voPlans = voPlans;
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
        
        function bMRT1wPostContrastRegistrationOntoMR  = IsMRT1wPostContrastRegistrationOntoMR(obj)
            bMRT1wPostContrastRegistrationOntoMR = obj.bMRT1wPostContrastRegistrationOntoMR;
        end
        
        function sPath = GetT1PostContrastMRIDicomFolderPath(obj)
            sPath = obj.sMRT1wPostContrastSeriesDicomFolderPath;
        end
        
        function sPath = GetCTSimDicomFolderPath(obj)            
            sPath = obj.sCTSeriesDicomFolderPath;
        end
        
        function sPath = GetT1PostContrastMRIToCTSimRegistrationDicomFilePath(obj)
            sPath = obj.sMRT1wPostContrastRegistrationDicomFilePath;
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
                    'RayStationBrainRadiationTreatmentPlan:GetPlanWithTargetedBrainMetastatsisNumber:NoPlanFound',...
                    'No plan with the targeted brain metastasis number provided found.');
            end
        end
        
        function SetPreTreatmentImagingSeriesPathsAndRegistrationMatches(obj, NameValueArgs)
            arguments
                obj (1,1) RayStationBrainRadiationTreatmentPlan
                NameValueArgs.CT (1,1) string
                NameValueArgs.MRT1wPre (1,1) string
                NameValueArgs.MRT1wPost (1,1) string
                NameValueArgs.MRT2w (1,1) string
                NameValueArgs.MRFA (1,1) string
                NameValueArgs.MRADC (1,1) string
                NameValueArgs.MRT1wPostRegistration (1,1) string
                NameValueArgs.MRT2wRegistration (1,1) string
                NameValueArgs.RTStruct (1,1) string
                NameValueArgs.RTDose (1,:) string
            end
            
            if isfield(NameValueArgs, 'CT')
                if ~isempty(obj.sCTSeriesDicomFolderPath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:CTFieldAlreadySet',...
                        'CT field has already been set.');
                end
                
                obj.sCTSeriesDicomFolderPath = NameValueArgs.CT;
            end
            
            if isfield(NameValueArgs, 'MRT1wPre')
                if ~isempty(obj.sMRT1wPreContrastSeriesDicomFolderPath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPreFieldAlreadySet',...
                        'MRT1wPre field has already been set.');
                end
                
                obj.sMRT1wPreContrastSeriesDicomFolderPath = NameValueArgs.MRT1wPre;
            end
            
            if isfield(NameValueArgs, 'MRT1wPost')
                if ~isempty(obj.sMRT1wPostContrastSeriesDicomFolderPath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPostFieldAlreadySet',...
                        'MRT1wPost field has already been set.');
                end
                
                obj.sMRT1wPostContrastSeriesDicomFolderPath = NameValueArgs.MRT1wPost;
            end
            
            if isfield(NameValueArgs, 'MRT2w')
                if ~isempty(obj.sMRT2wSeriesDicomFolderPath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT2wFieldAlreadySet',...
                        'MRT2w field has already been set.');
                end
                
                obj.sMRT2wSeriesDicomFolderPath = NameValueArgs.MRT2w;
            end
                        
            if isfield(NameValueArgs, 'MRFA')
                if ~isempty(obj.sMRFractionalAnisotropySeriesDicomFolderPath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRFAFieldAlreadySet',...
                        'MRFA field has already been set.');
                end
                
                obj.sMRFractionalAnisotropySeriesDicomFolderPath = NameValueArgs.MRFA;
            end
                        
            if isfield(NameValueArgs, 'MRADC')
                if ~isempty(obj.sMRApparentDiffusionCoefficientSeriesDicomFolderPath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRADCFieldAlreadySet',...
                        'MRADC field has already been set.');
                end
                
                obj.sMRApparentDiffusionCoefficientSeriesDicomFolderPath = NameValueArgs.MRADC;
            end
                        
            if isfield(NameValueArgs, 'MRT1wPostRegistration')
                if ~isempty(obj.sMRT1wPostContrastRegistrationDicomFilePath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT1wPostRegistrationFieldAlreadySet',...
                        'MRT1wPostRegistration field has already been set.');
                end
                
                obj.sMRT1wPostContrastRegistrationDicomFilePath = NameValueArgs.MRT1wPostRegistration;
            end
                        
            if isfield(NameValueArgs, 'MRT2wRegistration')
                if ~isempty(obj.sMRT2wRegistrationDicomFilePath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:MRT2wRegistrationFieldAlreadySet',...
                        'MRT2wRegistration field has already been set.');
                end
                
                obj.sMRT2wRegistrationDicomFilePath = NameValueArgs.MRT2wRegistration;
            end
                        
            if isfield(NameValueArgs, 'RTStruct')
                if ~isempty(obj.sRTStructDicomFilePath)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:RTStructFieldAlreadySet',...
                        'RTStruct field has already been set.');
                end
                
                obj.sRTStructDicomFilePath = NameValueArgs.RTStruct;
            end
                        
            if isfield(NameValueArgs, 'RTDose')
                if ~isempty(obj.vsRTDoseDicomFilePaths)
                    error(...
                        'RayStationBrainRadiationTreatmentPlan:SetPreTreatmentImagingSeriesPathsAndRegistrationMatches:RTDoseFieldAlreadySet',...
                        'RTDose field has already been set.');
                end
                
                obj.vsRTDoseDicomFilePaths = NameValueArgs.RTDose;
            end
        end
            
        function [vdtRegistrationTimeStamps, vsRegistrationFromImagingSeriesNames, vsRegistrationToImagingSeriesNames] = GetRayStationRegistrationData(obj)
            vdtRegistrationTimeStamps = obj.vdtRayStationRegistrationTimeStamps;
            vsRegistrationFromImagingSeriesNames = obj.vsRayStationRegistrationFromImagingSeriesNames;
            vsRegistrationToImagingSeriesNames = obj.vsRayStationRegistrationToImagingSeriesNames;
        end
        
        function [vsBeamSetNames, vdBeamSetPrescribedDoses_Gy, vdBeamSetPrescribedFractions, c1vdBMsTargeted] = GetAllBeamSetData(obj)
            dNumBeamSets = 0;
            
            for dPlanIndex=1:length(obj.voPlans)
                dNumBeamSets = dNumBeamSets + obj.voPlans(dPlanIndex).GetNumberOfBeamSets();
            end
            
            vsBeamSetNames = strings(dNumBeamSets,1);
            vdBeamSetPrescribedDoses_Gy = zeros(dNumBeamSets,1);
            vdBeamSetPrescribedFractions = zeros(dNumBeamSets,1);
            c1vdBMsTargeted = cell(dNumBeamSets,1);
            
            dCurrentBeamSetIndex = 1;
            
            for dPlanIndex=1:length(obj.voPlans)
                voBeamSets = obj.voPlans(dPlanIndex).GetBeamSets();
                
                for dBeamSetIndex=1:length(voBeamSets)
                    oBeamSet = voBeamSets(dBeamSetIndex);
                    
                    vsBeamSetNames(dCurrentBeamSetIndex) = oBeamSet.GetName();
                    vdBeamSetPrescribedDoses_Gy(dCurrentBeamSetIndex) = oBeamSet.GetPrescriptionDose_Gy();
                    vdBeamSetPrescribedFractions(dCurrentBeamSetIndex) = oBeamSet.GetPrescriptionFractions();                                        
                    c1vdBMsTargeted{dCurrentBeamSetIndex} = oBeamSet.GetTargetedBrainMetastasisNumbers();
                    
                    dCurrentBeamSetIndex = dCurrentBeamSetIndex + 1;
                end
            end
        end
        
        function dNumRegs = GetNumberOfRegistrations(obj)
            dNumRegs = length(obj.vdtRayStationRegistrationTimeStamps);
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

