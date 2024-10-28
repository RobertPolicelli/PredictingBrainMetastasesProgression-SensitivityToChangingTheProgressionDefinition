classdef REDCapBrainMetastasis
    %REDCapBrainMetastasis
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dNumber (1,1) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(dNumber,10)} = 1
        
        oPreTreatmentRadiologyAssessment REDCapPreTreatmentRadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar} = REDCapPreTreatmentRadiologyAssessment.empty()
        voRadiologyAssessments (:,1) REDCapFollowUpRadiologyAssessment {ValidationUtils.MustBeInOrder(voRadiologyAssessments, @GetDate, 'ascend')} % roughly every 3 month follow-up for first 2 years post treatment
        oFinalPost2YearRadiologyAssessment REDCapFollowUpRadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar} % follow-ups post 2 years are not tracked, except for the very last follow-up
        
        oPseudoProgressionConclusion REDCapPseudoProgressionConclusion {ValidationUtils.MustBeEmptyOrScalar} = REDCapPseudoProgressionConclusion.empty()
        
        voSalvageTreatments (:,1) REDCapBrainMetastasisSalvageTreatment {ValidationUtils.MustBeInOrder(voSalvageTreatments, @GetDate, 'ascend')}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapBrainMetastasis(dNumber, oPreTreatmentRadiologyAssessment, voRadiologyAssessments, oFinalPost2YearRadiologyAssessment, oPseudoProgressionConclusion, voSalvageTreatments)
            %obj = REDCapBrainMetastasis(dNumber, oPreTreatmentRadiologyAssessment, voRadiologyAssessments, oFinalPost2YearRadiologyAssessment, oPseudoProgressionConclusion, voSalvageTreatments)
            arguments
                dNumber (1,1) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(dNumber,10)}
                oPreTreatmentRadiologyAssessment (1,1) REDCapPreTreatmentRadiologyAssessment
                voRadiologyAssessments (:,1) REDCapFollowUpRadiologyAssessment
                oFinalPost2YearRadiologyAssessment REDCapFollowUpRadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar}
                oPseudoProgressionConclusion REDCapPseudoProgressionConclusion {ValidationUtils.MustBeEmptyOrScalar}
                voSalvageTreatments (:,1) REDCapBrainMetastasisSalvageTreatment
            end
            
            if ~isempty(voRadiologyAssessments) && oPreTreatmentRadiologyAssessment.GetDate() >= voRadiologyAssessments(1).GetDate()
                error(...
                    'REDCapBrainMetastasis:Constructor:InvalidPreTreatmentRadiologyDate',...
                    'The oPreTreatmentRadiologyAssessment date must be before the voRadiologyAssessments dates.');
            end
            
            if ~isempty(oFinalPost2YearRadiologyAssessment) && oFinalPost2YearRadiologyAssessment.GetDate() <= voRadiologyAssessments(end).GetDate()                
                error(...
                    'REDCapBrainMetastasis:Constructor:InvalidFinalPost2YearRadiologyDate',...
                    'The oFinalPost2YearRadiologyAssessment date must be after the voRadiologyAssessments dates.');
            end
            
            if (~isempty(voRadiologyAssessments) || ~isempty(oFinalPost2YearRadiologyAssessment)) && isempty(oPseudoProgressionConclusion)            
                error(...
                    'REDCapBrainMetastasis:Constructor:EmptyPseudoProgressionConclusion',...
                    'oPseudoProgressionConclusion can only be empty if now follow-up radiology occured.');                
            end
            
            obj.dNumber = dNumber;
            obj.oPreTreatmentRadiologyAssessment = oPreTreatmentRadiologyAssessment;
            obj.voRadiologyAssessments = voRadiologyAssessments;
            obj.oFinalPost2YearRadiologyAssessment = oFinalPost2YearRadiologyAssessment;
            obj.oPseudoProgressionConclusion = oPseudoProgressionConclusion;   
            obj.voSalvageTreatments = voSalvageTreatments;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dNumber = GetBrainMetastasisNumber(obj)
            dNumber = obj.dNumber;
        end
        
        function dNumberOfFollowUps = GetNumberOfRadiologyAssessments(obj)
            dNumberOfFollowUps = length(obj.voRadiologyAssessments);
        end
        
        function oPreTreatmentRadiologyAssessment = GetPreTreatmentRadiologyAssessment(obj)
            oPreTreatmentRadiologyAssessment = obj.oPreTreatmentRadiologyAssessment;
        end
        
        function voRadiologyAssessments = GetRadiologyAssessments(obj)
            voRadiologyAssessments = obj.voRadiologyAssessments;
        end
        
        function vdtAssessmentDates = GetRadiologyAssessmentDates(obj)
            if isempty(obj.voRadiologyAssessments)
                vdtAssessmentDates = datetime.empty();
            else                
                vdtAssessmentDates = Utilities.ApplyScalarFunctionToEachIndex(obj.voRadiologyAssessments, @GetDate);
            end
        end
        
        function oFinalPost2YearRadiologyAssessment = GetFinalPost2YearRadiologyAssessment(obj)
            oFinalPost2YearRadiologyAssessment = obj.oFinalPost2YearRadiologyAssessment;
        end
        
        function oSalvageTreatment = GetFirstSalvageTreatment(obj)
            if isempty(obj.voSalvageTreatments)
                oSalvageTreatment = REDCapBrainMetastasisSalvageTreatment.empty();
            else
                oSalvageTreatment = obj.voSalvageTreatments(1);
            end
        end
        
        function oPseudoProgressionConclusion = GetPseudoProgressionConclusion(obj)
            oPseudoProgressionConclusion = obj.oPseudoProgressionConclusion;
        end
        
        function vdChangeInPerpMaxDiametersProductPerAssessmentFromBaseline = GetChangeInPerpMaxDiametersProductPerAssessmentFromBaseline(obj, NameValueArgs)
            arguments
                obj REDCapBrainMetastasis
                NameValueArgs.IgnoreAssessmentsPastDate (1,1) datetime 
            end
            
            voRadiologyAssessments = obj.voRadiologyAssessments;
            vdtRadiologyAssessmentDates = obj.GetRadiologyAssessmentDates();
            
            if isfield(NameValueArgs, 'IgnoreAssessmentsPastDate')
                voRadiologyAssessments = voRadiologyAssessments(vdtRadiologyAssessmentDates < NameValueArgs.IgnoreAssessmentsPastDate);
            end
                        
            dNumAssessments = length(voRadiologyAssessments);
            vdChangeInPerpMaxDiametersProductPerAssessmentFromBaseline = zeros(dNumAssessments,1);
            
            [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] =...
                obj.oPreTreatmentRadiologyAssessment.GetPerpendicularMaxDiameterMeasurements_mm();
            dPreTreatmentProduct = dMaxAnteriorPosteriorDiameterMeasurement_mm*dMaxMediolateralDiameterMeasurement_mm*dMaxCraniocaudalDiameterMeasurement_mm;
            
            for dAssessmentIndex=1:dNumAssessments
                [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] =...
                    voRadiologyAssessments(dAssessmentIndex).GetPerpendicularMaxDiameterMeasurements_mm();
                 
                dFollowUpProduct = dMaxAnteriorPosteriorDiameterMeasurement_mm*dMaxMediolateralDiameterMeasurement_mm*dMaxCraniocaudalDiameterMeasurement_mm;
                                
                vdChangeInPerpMaxDiametersProductPerAssessmentFromBaseline(dAssessmentIndex) = (dFollowUpProduct - dPreTreatmentProduct) / dPreTreatmentProduct;
            end
            
            if ~isempty(obj.oFinalPost2YearRadiologyAssessment) && (~isfield(NameValueArgs, 'IgnoreAssessmentsPastDate') || obj.oFinalPost2YearRadiologyAssessment.GetDate() < NameValueArgs.IgnoreAssessmentsPastDate)
                [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] =...
                    obj.oFinalPost2YearRadiologyAssessment.GetPerpendicularMaxDiameterMeasurements_mm();
                
                dFollowUpProduct = dMaxAnteriorPosteriorDiameterMeasurement_mm*dMaxMediolateralDiameterMeasurement_mm*dMaxCraniocaudalDiameterMeasurement_mm;
                
                vdChangeInPerpMaxDiametersProductPerAssessmentFromBaseline(end+1) = (dFollowUpProduct - dPreTreatmentProduct) / dPreTreatmentProduct;
            end
        end
        
        function vdChangeInPerpMaxDiametersProductPerAssessmentFromPrevious = GetChangeInPerpMaxDiametersProductPerAssessmentFromPrevious(obj, NameValueArgs)
            arguments
                obj REDCapBrainMetastasis
                NameValueArgs.IgnoreAssessmentsPastDate (1,1) datetime 
            end
            
            voRadiologyAssessments = obj.voRadiologyAssessments;
            vdtRadiologyAssessmentDates = obj.GetRadiologyAssessmentDates();
            
            if isfield(NameValueArgs, 'IgnoreAssessmentsPastDate')
                voRadiologyAssessments = voRadiologyAssessments(vdtRadiologyAssessmentDates < NameValueArgs.IgnoreAssessmentsPastDate);
            end
                        
            dNumAssessments = length(voRadiologyAssessments);
            
            vdChangeInPerpMaxDiametersProductPerAssessmentFromPrevious = zeros(dNumAssessments,1);
            
            [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] =...
                obj.oPreTreatmentRadiologyAssessment.GetPerpendicularMaxDiameterMeasurements_mm();
            dPreviousProduct = dMaxAnteriorPosteriorDiameterMeasurement_mm*dMaxMediolateralDiameterMeasurement_mm*dMaxCraniocaudalDiameterMeasurement_mm;
            
            for dAssessmentIndex=1:dNumAssessments
                [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] =...
                    voRadiologyAssessments(dAssessmentIndex).GetPerpendicularMaxDiameterMeasurements_mm();
                 
                dFollowUpProduct = dMaxAnteriorPosteriorDiameterMeasurement_mm*dMaxMediolateralDiameterMeasurement_mm*dMaxCraniocaudalDiameterMeasurement_mm;
                                
                vdChangeInPerpMaxDiametersProductPerAssessmentFromPrevious(dAssessmentIndex) = (dFollowUpProduct - dPreviousProduct) / dPreviousProduct;
                dPreviousProduct = dFollowUpProduct;
            end
            
            if ~isempty(obj.oFinalPost2YearRadiologyAssessment) && (~isfield(NameValueArgs, 'IgnoreAssessmentsPastDate') || obj.oFinalPost2YearRadiologyAssessment.GetDate() < NameValueArgs.IgnoreAssessmentsPastDate)
                [dMaxAnteriorPosteriorDiameterMeasurement_mm, dMaxMediolateralDiameterMeasurement_mm, dMaxCraniocaudalDiameterMeasurement_mm] =...
                    obj.oFinalPost2YearRadiologyAssessment.GetPerpendicularMaxDiameterMeasurements_mm();
                
                dFollowUpProduct = dMaxAnteriorPosteriorDiameterMeasurement_mm*dMaxMediolateralDiameterMeasurement_mm*dMaxCraniocaudalDiameterMeasurement_mm;
                
                vdChangeInPerpMaxDiametersProductPerAssessmentFromPrevious(end+1) = (dFollowUpProduct - dPreviousProduct) / dPreviousProduct;
            end
        end
        
        function bPseudoProgressionSuspected = WasPseudoProgressionSuspected(obj)
            dNumAssessments = length(obj.voRadiologyAssessments);
            
            if dNumAssessments == 0
                bPseudoProgressionSuspected = false;
            else
                bPseudoProgressionSuspected = false;
                
                for dAssessmentIndex=1:dNumAssessments
                    if obj.voRadiologyAssessments(dAssessmentIndex).GetPseudoProgressionStatus == REDCapPseudoProgressionStatus.Suspected
                        bPseudoProgressionSuspected = true;
                    end
                end
                
                if ~isempty(obj.oFinalPost2YearRadiologyAssessment)
                    if obj.oFinalPost2YearRadiologyAssessment.GetPseudoProgressionStatus == REDCapPseudoProgressionStatus.Suspected
                        bPseudoProgressionSuspected = true;
                    end
                end
            end
        end
        
        function bPseudoProgressionLikely = WasPseudoProgressionLikely(obj)
            dNumAssessments = length(obj.voRadiologyAssessments);
            
            if dNumAssessments == 0
                bPseudoProgressionLikely = false;
            else
                bPseudoProgressionLikely = false;
                
                for dAssessmentIndex=1:dNumAssessments
                    if obj.voRadiologyAssessments(dAssessmentIndex).GetPseudoProgressionStatus == REDCapPseudoProgressionStatus.Likely
                        bPseudoProgressionLikely = true;
                    end
                end
                
                if ~isempty(obj.oFinalPost2YearRadiologyAssessment)
                    if obj.oFinalPost2YearRadiologyAssessment.GetPseudoProgressionStatus == REDCapPseudoProgressionStatus.Likely
                        bPseudoProgressionLikely = true;
                    end
                end
            end
        end
        
    end
    
    
    methods (Access = public, Static)
        
        function voBMs = CreateFromREDCapExport(c2xREDCapExportDataForPatient, vsREDCapExportHeaders, voSalvageTreatments)
            vsREDCapRepeatInstruments = string(c2xREDCapExportDataForPatient(:, vsREDCapExportHeaders == "redcap_repeat_instrument"));
            
            c1xREDCapRepeatInstance = c2xREDCapExportDataForPatient(:, vsREDCapExportHeaders == "redcap_repeat_instance");
            
            for dRowIndex=1:length(c1xREDCapRepeatInstance)
                if ismissing(c1xREDCapRepeatInstance{dRowIndex})
                    c1xREDCapRepeatInstance{dRowIndex} = NaN;
                end
            end
            
            vdREDCapRepeatInsance = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1xREDCapRepeatInstance);
            
            dNumberOfBMs = c2xREDCapExportDataForPatient{vsREDCapRepeatInstruments == "brain_radiation_course" & vdREDCapRepeatInsance == 1, vsREDCapExportHeaders == "brain_rt_course_number_of_bms_treated"};
            
            c1oBMs = cell(dNumberOfBMs,1);
            
            for dBMIndex=1:dNumberOfBMs
                % pre-treatment
                dtDate = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_date"};
                
                dRANOMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_rano_bm_measurement_mm"};
                dAntPostMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_anterior_posterior_measurement_mm"};	
                dMediolateralMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_mediolateral_measurement_mm"};	
                dCraniocaudalMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_craniocaudal_measurement_mm"};
                	
                bIsParenchymal = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_parenchymal"};
                bIsSurgicalCavity = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_surgical_cavity"};
                bIsEdema = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_edema"};
                bIsMassEffect = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_mass_effect"};
                	
                eAppearance = REDCapBrainMetastasisAppearanceScore.GetEnumFromREDCapCode(...
                    c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_appearance"},...
                    c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_pretreatment_bm" + string(dBMIndex) + "_rim_enhancement_type"});
                	
                oPreTreatmentRadiology = REDCapPreTreatmentRadiologyAssessment(dtDate, dRANOMeasurment_mm, dAntPostMeasurment_mm, dMediolateralMeasurment_mm, dCraniocaudalMeasurment_mm, bIsParenchymal, bIsSurgicalCavity, bIsEdema, bIsMassEffect, eAppearance);
                
                % follow-ups
                vdFollowUpRows = find(vsREDCapRepeatInstruments == "brain_radiology_followup");
                dNumFollowUps = length(vdFollowUpRows);
                
                if dNumFollowUps == 0
                    voFollowUpRadiology = REDCapFollowUpRadiologyAssessment.empty(0,1);
                else
                    c1oFollowUpRadiology = cell(dNumFollowUps,1);
                    
                    for dFollowUpIndex=1:dNumFollowUps
                        dRowIndex = vdFollowUpRows(dFollowUpIndex);
                        
                        dtDate = c2xREDCapExportDataForPatient{dRowIndex, vsREDCapExportHeaders=="brain_radiology_followup_date"};
                        
                        dRANOMeasurment_mm = c2xREDCapExportDataForPatient{dRowIndex, vsREDCapExportHeaders == "brain_radiology_followup_bm" + string(dBMIndex) + "_rano_bm_measurement_mm"};
                        dAntPostMeasurment_mm = c2xREDCapExportDataForPatient{dRowIndex, vsREDCapExportHeaders == "brain_radiology_followup_bm" + string(dBMIndex) + "_anterior_posterior_measurement_mm"};
                        dMediolateralMeasurment_mm = c2xREDCapExportDataForPatient{dRowIndex, vsREDCapExportHeaders == "brain_radiology_followup_bm" + string(dBMIndex) + "_mediolateral_measurement_mm"};
                        dCraniocaudalMeasurment_mm = c2xREDCapExportDataForPatient{dRowIndex, vsREDCapExportHeaders == "brain_radiology_followup_bm" + string(dBMIndex) + "_craniocaudal_measurement_mm"};
                        
                        ePseudoProgressionScore = REDCapPseudoProgressionStatus.GetEnumFromREDCapCode(c2xREDCapExportDataForPatient{dRowIndex, vsREDCapExportHeaders == "brain_radiology_followup_bm" + string(dBMIndex) + "_pseudo_progression"});
                        
                        c1oFollowUpRadiology{dFollowUpIndex} = REDCapFollowUpRadiologyAssessment(dtDate, dRANOMeasurment_mm, dAntPostMeasurment_mm, dMediolateralMeasurment_mm, dCraniocaudalMeasurment_mm, ePseudoProgressionScore);
                    end
                    
                    voFollowUpRadiology = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oFollowUpRadiology);
                end
                
                % +2 year final follow-up
                dtDate = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_last_followup_date"};
                
                if ismissing(dtDate)
                    oFinalFollowUpRadiology = REDCapFollowUpRadiologyAssessment.empty();
                else
                    dRANOMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_last_followup_bm" + string(dBMIndex) + "_rano_bm_measurement_mm"};
                    dAntPostMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_last_followup_bm" + string(dBMIndex) + "_anterior_posterior_measurement_mm"};
                    dMediolateralMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_last_followup_bm" + string(dBMIndex) + "_mediolateral_measurement_mm"};
                    dCraniocaudalMeasurment_mm = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_last_followup_bm" + string(dBMIndex) + "_craniocaudal_measurement_mm"};
                	
                    ePseudoProgressionScore = REDCapPseudoProgressionStatus.GetEnumFromREDCapCode(c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_last_followup_bm" + string(dBMIndex) + "_pseudo_progression"});
                    
                    oFinalFollowUpRadiology = REDCapFollowUpRadiologyAssessment(dtDate, dRANOMeasurment_mm, dAntPostMeasurment_mm, dMediolateralMeasurment_mm, dCraniocaudalMeasurment_mm, ePseudoProgressionScore);
                end
                
                % Pseudo-progression conclusion
                
                if ismissing(c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_conclusion_bm" + string(dBMIndex) + "_pseudo_progression_confirmed"})
                    % no pseudo progression conclusion
                    oPseudoProgressionConclusion = REDCapPseudoProgressionConclusion.empty;
                else                
                    ePseudoProgressionConfirmation = REDCapPseudoProgressionConfirmationStatus.GetEnumFromREDCapCode(c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_conclusion_bm" + string(dBMIndex) + "_pseudo_progression_confirmed"});
                    
                    dRadiationNecrosisCode = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_conclusion_bm" + string(dBMIndex) + "_pseudo_progression_is_radiation_necrosis"};
                    
                    if ismissing(dRadiationNecrosisCode)
                        eRadiationNecrosisStatus = REDCapPsuedoProgressionSubTypeStatus.empty;
                    else
                        eRadiationNecrosisStatus = REDCapPsuedoProgressionSubTypeStatus.GetEnumFromREDCapCode(dRadiationNecrosisCode);
                    end
                    
                    dAdverseRadiationEffectCode = c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstruments), vsREDCapExportHeaders == "brain_radiology_conclusion_bm" + string(dBMIndex) + "_pseudo_progression_is_are"};
                    
                    if ismissing(dAdverseRadiationEffectCode)
                        eAdverseRadiationEffectStatus = REDCapPsuedoProgressionSubTypeStatus.empty;
                    else
                        eAdverseRadiationEffectStatus = REDCapPsuedoProgressionSubTypeStatus.GetEnumFromREDCapCode(dAdverseRadiationEffectCode);
                    end
                    
                    oPseudoProgressionConclusion = REDCapPseudoProgressionConclusion(ePseudoProgressionConfirmation, eRadiationNecrosisStatus, eAdverseRadiationEffectStatus);
                end       
                
                % salvage therapies
                dNumSalvage = length(voSalvageTreatments);
                vbApplicableToBrainMetastasis = false(dNumSalvage,1);
                
                for dSalvageIndex=1:dNumSalvage
                    if any(voSalvageTreatments(dSalvageIndex).GetBrainMetastasisNumbersTargeted() == dBMIndex)
                        vbApplicableToBrainMetastasis(dSalvageIndex) = true;
                    elseif voSalvageTreatments(dSalvageIndex).GetType() == REDCapSalvageTreatmentType.WBRT
                        error(...
                            "REDCapBrainMetastasis:CreateFromREDCapExport:BrainMetNotTargetedByWBRT",...
                            "A WBRT salvage treatment should be listed to target all BMs.");
                    end
                end
                
                dNumSalvageForBM = sum(vbApplicableToBrainMetastasis);
                
                if dNumSalvageForBM == 0
                    voSalvageTreatmentsForBM = REDCapBrainMetastasisSalvageTreatment.empty(0,1);
                else
                    vdSalvageTreatmentIndices = find(vbApplicableToBrainMetastasis);
                    c1oSalvageTreatmentsForBM = cell(dNumSalvageForBM,1);
                    
                    for dSalvageIndex=1:dNumSalvageForBM
                        c1oSalvageTreatmentsForBM{dSalvageIndex} = REDCapBrainMetastasisSalvageTreatment(voSalvageTreatments(vdSalvageTreatmentIndices(dSalvageIndex)).GetDate(), voSalvageTreatments(vdSalvageTreatmentIndices(dSalvageIndex)).GetType());                        
                    end
                    
                    voSalvageTreatmentsForBM = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oSalvageTreatmentsForBM);
                end
                
                % create brain metastasis
                c1oBMs{dBMIndex} = REDCapBrainMetastasis(dBMIndex, oPreTreatmentRadiology, voFollowUpRadiology, oFinalFollowUpRadiology, oPseudoProgressionConclusion, voSalvageTreatmentsForBM);
            end
            
            voBMs = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBMs);
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

