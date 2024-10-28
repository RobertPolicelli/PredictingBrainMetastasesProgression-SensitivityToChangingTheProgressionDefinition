classdef REDCapPatient < handle
    %Patient
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dPrimaryId (1,1) double {mustBeInteger}
        
        dtAgeAtFirstBrainRTTreatment (1,1) calendarDuration % rounded to nearest month as to not reveal DOB given known brain RT date
        dtSurvivalTimeFromFirstBrainRTTreatment calendarDuration {ValidationUtils.MustBeEmptyOrScalar} % rounded to nearest month as to not reveal DOD given known brain RT data; can be empty if patient not deceased; if deceased status is Likely, then date of last interaction is used as a surrogate for DOD

        eDeathStatus (1,1) REDCapPatientDeathStatus
        
        eGender (1,1) REDCapGender
        
        voPrimaryCancersInformation (:,1) REDCapPrimaryCancerInformation {ValidationUtils.MustBeInOrder(voPrimaryCancersInformation, @GetHistopathologyDate, 'ascend')}
        voSystemicTherapies (:,1) REDCapSystemicTherapy {ValidationUtils.MustBeInOrder(voSystemicTherapies, @GetStartDate, 'ascend')}
        voSalvageTreatments (:,1) REDCapSalvageTreatment {ValidationUtils.MustBeInOrder(voSalvageTreatments, @GetDate, 'ascend')}
        
        voBrainRadiationCourses (:,1) REDCapBrainRadiationCourse {ValidationUtils.MustBeInOrder(voBrainRadiationCourses, @GetDate, 'ascend')} = REDCapBrainRadiationCourse.empty(0,1)
        
        voBrainMetastases (:,1) REDCapBrainMetastasis {ValidationUtils.MustBeInOrder(voBrainMetastases, @GetBrainMetastasisNumber, 'ascend')} = REDCapBrainMetastasis.empty(0,1)
        
        voFollowUpNewBrainMetastasesAssessments (:,1) REDCapFollowUpNewBrainMetastasesAssessment {ValidationUtils.MustBeInOrder(voFollowUpNewBrainMetastasesAssessments, @GetDate, 'ascend')} = REDCapFollowUpNewBrainMetastasesAssessment.empty(0,1)
    end
    
    
    properties (Constant = true, GetAccess = private)
        dPrimaryIdStringNumberOfDigits = 4
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapPatient(dPrimaryId, eGender, eDeathStatus, dtAgeAtFirstBrainRTTreatment, dtSurvivalTimeFromFirstBrainRTTreatment, voPrimaryCancersInformation, voSystemicTherapies, voSalvageTreatments, voBrainRadiationCourses, voBrainMetastases, voFollowUpNewBrainMetastasesAssessments)
            %obj = REDCapPatient(dPrimaryId, eGender, eDeathStatus, dtAgeAtFirstBrainRTTreatment, dtSurvivalTimeFromFirstBrainRTTreatment, voPrimaryCancersInformation, voSystemicTherapies, voSalvageTreatments, voBrainRadiationCourses, voBrainMetastases, voFollowUpNewBrainMetastasesAssessments)
            
            dNumBMs = length(voBrainMetastases);
            vdBMNumbers = zeros(dNumBMs,1);
            
            for dBMIndex=1:dNumBMs
                vdBMNumbers(dBMIndex) = voBrainMetastases(dBMIndex).GetBrainMetastasisNumber();
            end
            
            if ~all(vdBMNumbers == (1:dNumBMs)')
                error(...
                    'REDCapPatient:Constructor:InvalidBMNumbers',...
                    'BMs must have their numbers in order from 1 to the number of BMs.');
            end
            
            
            obj.dPrimaryId = dPrimaryId;
            obj.eGender = eGender;
            obj.eDeathStatus = eDeathStatus;
            obj.dtAgeAtFirstBrainRTTreatment = dtAgeAtFirstBrainRTTreatment;
            obj.dtSurvivalTimeFromFirstBrainRTTreatment = dtSurvivalTimeFromFirstBrainRTTreatment;
            obj.voPrimaryCancersInformation = voPrimaryCancersInformation;
            obj.voSystemicTherapies = voSystemicTherapies;
            obj.voSalvageTreatments = voSalvageTreatments;
            obj.voBrainRadiationCourses = voBrainRadiationCourses;
            obj.voBrainMetastases = voBrainMetastases;
            obj.voFollowUpNewBrainMetastasesAssessments = voFollowUpNewBrainMetastasesAssessments;
        end
        
        function Update(obj)
            % update contained objects
        end
        
        function sPrimaryIdString = GetPrimaryIdString(obj)
            sPrimaryIdString = string(StringUtils.num2str_PadWithZeros(obj.dPrimaryId, REDCapPatient.dPrimaryIdStringNumberOfDigits));
        end
        
        function dPrimaryId = GetPrimaryId(obj)
            dPrimaryId = obj.dPrimaryId;
        end
        
        function dNumberOfFollowUps = GetNumberOfRadiologyAssessments(obj)
            dNumberOfFollowUps = obj.voBrainMetastases(1).GetNumberOfRadiologyAssessments();
        end
        
        function dtSurvivalTimeFromFirstBrainRTTreatment = GetSurvivalTimeFromFirstBrainRTTreatment(obj)
            dtSurvivalTimeFromFirstBrainRTTreatment = obj.dtSurvivalTimeFromFirstBrainRTTreatment;
        end
        
        function dNumBMs = GetNumberOfBrainMetastases(obj)
            dNumBMs = length(obj.voBrainMetastases);
        end
        
        function oBM = GetBrainMetastasis(obj, dBMNumber)
            oBM = obj.voBrainMetastases(dBMNumber);
        end
        
        function eDeathStatus = GetDeathStatus(obj)
            eDeathStatus = obj.eDeathStatus;
        end
        
        function oBrainRadiationCourse = GetFirstBrainRadiationCourse(obj)
            oBrainRadiationCourse = obj.voBrainRadiationCourses(1);
        end
        
        function voPrimaryCancersInformation = GetPrimaryCancersInformation(obj)
            voPrimaryCancersInformation = obj.voPrimaryCancersInformation;
        end
        
        function voSystemicTherapies = GetSystemicTherapies(obj)
            voSystemicTherapies = obj.voSystemicTherapies;
        end
        
        function voSalvageTreatments = GetSalvageTreatments(obj)
            voSalvageTreatments = obj.voSalvageTreatments;
        end
        
        function eGender = GetGender(obj)
            eGender = obj.eGender;
        end
        
        function dtAgeAtFirstBrainRTTreatment = GetAgeAtFirstBrainRTTreatment(obj)
            dtAgeAtFirstBrainRTTreatment = obj.dtAgeAtFirstBrainRTTreatment;
        end
        
        function vdtRadiologyAssessmentDates = GetRadiologyAssessmentDates(obj)
            voRadiologyAssessments = obj.voBrainMetastases(1).GetRadiologyAssessments();
            
            dNumAssessments = length(voRadiologyAssessments);
            
            vdtRadiologyAssessmentDates = NaT(dNumAssessments,1);
            
            for dAssessmentIndex=1:dNumAssessments
                vdtRadiologyAssessmentDates(dAssessmentIndex) = voRadiologyAssessments(dAssessmentIndex).GetDate();
            end
        end
        
        function dtApproximateDateOfDeath = GetApproximateDateOfDeath(obj)
            if isempty(obj.dtSurvivalTimeFromFirstBrainRTTreatment)
                dtApproximateDateOfDeath = datetime.empty;
            else            
                dtApproximateDateOfDeath = obj.GetFirstBrainRadiationCourse().GetDate() + obj.dtSurvivalTimeFromFirstBrainRTTreatment;
            end
        end
        
        function dtLastRadiologyAssessmentDate = GetLastRadiologyAssessmentDate(obj)
            oBM = obj.voBrainMetastases(1);
            
            if isempty(oBM.GetFinalPost2YearRadiologyAssessment()) && isempty(oBM.GetRadiologyAssessments())
                dtLastRadiologyAssessmentDate = datetime.empty;
            else
                if isempty(oBM.GetFinalPost2YearRadiologyAssessment())
                    voAssessments = oBM.GetRadiologyAssessments();
                    dtLastRadiologyAssessmentDate = voAssessments(end).GetDate();
                else
                    dtLastRadiologyAssessmentDate = oBM.GetFinalPost2YearRadiologyAssessment().GetDate();
                end
            end
        end
        
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = CreateFromREDCapExport(c2xREDCapExportDataForPatient, vsREDCapExportHeaders, dPatientAge_months, dPatientSurvival_months)
            vsREDCapRepeatInstrumentPerRow = string(c2xREDCapExportDataForPatient(:, vsREDCapExportHeaders == "redcap_repeat_instrument"));
            
            % patient level data
            dPrimaryId = c2xREDCapExportDataForPatient{1, vsREDCapExportHeaders == "study_id"};
            eGender = REDCapGender.GetEnumFromREDCapCode(c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstrumentPerRow), vsREDCapExportHeaders == "patient_sex"});
            eDeathStatus = REDCapPatientDeathStatus.GetEnumFromREDCapCode(c2xREDCapExportDataForPatient{ismissing(vsREDCapRepeatInstrumentPerRow), vsREDCapExportHeaders == "patient_deceased"});
            % TODO age at treatment
            % TODO survival time
            
            % sub-objects
            % - primary cancers
            vdPrimaryCancerRows = find(vsREDCapRepeatInstrumentPerRow == "primary_cancer_information");
            dNumberPrimaryCancers = length(vdPrimaryCancerRows);
            c1oPrimaryCancersInformation = cell(dNumberPrimaryCancers,1);
            vdtDate = NaT(dNumberPrimaryCancers,1);
            
            for dPrimaryCancerIndex=1:dNumberPrimaryCancers
                c1oPrimaryCancersInformation{dPrimaryCancerIndex} = REDCapPrimaryCancerInformation.CreateFromREDCapExport(c2xREDCapExportDataForPatient(vdPrimaryCancerRows(dPrimaryCancerIndex),:), vsREDCapExportHeaders);
                vdtDate(dPrimaryCancerIndex) = c1oPrimaryCancersInformation{dPrimaryCancerIndex}.GetHistopathologyDate();
            end
            
            voPrimaryCancersInformation = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPrimaryCancersInformation);
            
            [~,vdSortIndices] = sort(vdtDate, 'ascend');
            voPrimaryCancersInformation = voPrimaryCancersInformation(vdSortIndices);
            
            
            % - systemic therapies
            vdSystemicTherapiesRows = find(vsREDCapRepeatInstrumentPerRow == "systemic_therapy");
            dNumberSystemicTherapies = length(vdSystemicTherapiesRows);
            
            if dNumberSystemicTherapies == 0
                voSystemicTherapies = REDCapSystemicTherapy.empty(0,1);
            else
                c1oSystemicTherapies = cell(dNumberSystemicTherapies,1);
                vdtDate = NaT(dNumberSystemicTherapies,1);
                
                for dSystemicTherapyIndex=1:dNumberSystemicTherapies
                    c1oSystemicTherapies{dSystemicTherapyIndex} = REDCapSystemicTherapy.CreateFromREDCapExport(c2xREDCapExportDataForPatient(vdSystemicTherapiesRows(dSystemicTherapyIndex),:), vsREDCapExportHeaders);
                    vdtDate = c1oSystemicTherapies{dSystemicTherapyIndex}.GetStartDate();
                end
                
                voSystemicTherapies = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oSystemicTherapies);
                
                [~,vdSortIndices] = sort(vdtDate, 'ascend');
                voSystemicTherapies = voSystemicTherapies(vdSortIndices);
            end
            
            % - salvage treatments
            vdSalvageTreatmentRows = find(vsREDCapRepeatInstrumentPerRow == "salvage_treatment");
            dNumberSalvageTreatments = length(vdSalvageTreatmentRows);
            
            if dNumberSalvageTreatments == 0
                voSalvageTreatments = REDCapSalvageTreatment.empty(0,1);
            else
                c1oSalvageTreatments = cell(dNumberSalvageTreatments,1);
                vdtDate = NaT(dNumberSalvageTreatments,1);
                
                for dSalvageTreatmentIndex=1:dNumberSalvageTreatments
                    c1oSalvageTreatments{dSalvageTreatmentIndex} = REDCapSalvageTreatment.CreateFromREDCapExport(c2xREDCapExportDataForPatient(vdSalvageTreatmentRows(dSalvageTreatmentIndex),:), vsREDCapExportHeaders);
                    vdtDate = c1oSalvageTreatments{dSalvageTreatmentIndex}.GetDate();
                end
                
                voSalvageTreatments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oSalvageTreatments);
                
                [~,vdSortIndices] = sort(vdtDate, 'ascend');
                voSalvageTreatments = voSalvageTreatments(vdSortIndices);
            end
            
            
            % - brain radiation courses
            vdBrainRadiationCourseRows = find(vsREDCapRepeatInstrumentPerRow == "brain_radiation_course");
            dBrainRadiationCourses = length(vdBrainRadiationCourseRows);
            c1oBrainRadiationCourses = cell(dBrainRadiationCourses,1);
            
            for dCourseIndex=1:dBrainRadiationCourses
                c1oBrainRadiationCourses{dCourseIndex} = REDCapBrainRadiationCourse.CreateFromREDCapExport(c2xREDCapExportDataForPatient(vdBrainRadiationCourseRows(dCourseIndex),:), vsREDCapExportHeaders);
            end
            
            voBrainRadiationCourses = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBrainRadiationCourses);
            
            
            % - brain metastases
            voBrainMetastases = REDCapBrainMetastasis.CreateFromREDCapExport(c2xREDCapExportDataForPatient, vsREDCapExportHeaders, voSalvageTreatments);
            
            
            % - new brain metastases assessments
            vdRadiologyFollowUpRows = find(vsREDCapRepeatInstrumentPerRow == "brain_radiology_followup");
            dNumberRadiologyFollowUps = length(vdRadiologyFollowUpRows);
            
            if dNumberRadiologyFollowUps == 0
                voFollowUpNewBrainMetastasesAssessments = REDCapFollowUpNewBrainMetastasesAssessment.empty(0,1);
            else
                c1oFollowUpNewBrainMetastasesAssessments = cell(dNumberRadiologyFollowUps,1);
                
                for dFollowUpIndex=1:dNumberRadiologyFollowUps
                    c1oFollowUpNewBrainMetastasesAssessments{dFollowUpIndex} = REDCapFollowUpNewBrainMetastasesAssessment.CreateFromREDCapExport(c2xREDCapExportDataForPatient(vdRadiologyFollowUpRows(dFollowUpIndex),:), vsREDCapExportHeaders);
                end
                
                voFollowUpNewBrainMetastasesAssessments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oFollowUpNewBrainMetastasesAssessments);
            end
            
            % create patient
            if isnan(dPatientSurvival_months)
                dPatientSurvival_months = [];
            end
            
            obj = REDCapPatient(dPrimaryId, eGender, eDeathStatus, calmonths(dPatientAge_months), calmonths(dPatientSurvival_months), voPrimaryCancersInformation, voSystemicTherapies, voSalvageTreatments, voBrainRadiationCourses, voBrainMetastases, voFollowUpNewBrainMetastasesAssessments);
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
