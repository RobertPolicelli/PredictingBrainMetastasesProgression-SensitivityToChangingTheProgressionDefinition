classdef Patient < handle
    %Patient
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dStudyId (1,1) double {mustBeInteger, mustBePositive} = 1
        
        bIsExcluded (1,1) logical
        sExclusionReason string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        dtAgeAtFirstBrainRTTreatment calendarDuration {ValidationUtils.MustBeEmptyOrScalar} = calendarDuration.empty % rounded to nearest month as to not reveal DOB given known brain RT date
        dtSurvivalTimeFromFirstBrainRTTreatment calendarDuration {ValidationUtils.MustBeEmptyOrScalar} = calendarDuration.empty % rounded to nearest month as to not reveal DOD given known brain RT data; can be empty if patient not deceased; if deceased status is Likely, then date of last interaction is used as a surrogate for DOD

        eDeceasedStatus DeceasedStatus {ValidationUtils.MustBeEmptyOrScalar} = DeceasedStatus.empty
        
        eSex Sex {ValidationUtils.MustBeEmptyOrScalar} = Sex.empty
        
        voAriaDiagnoses (:,1) AriaDiagnosis {ValidationUtils.MustBeInOrder(voAriaDiagnoses, @GetDate, 'ascend')} = AriaDiagnosis.empty(0,1)
        voAriaBrainRadiationTherapyCoursePlans (:,1) AriaRadiationTherapyCoursePlan {ValidationUtils.MustBeInOrder(voAriaBrainRadiationTherapyCoursePlans, @GetTreatmentDate, 'ascend')}
        voAriaLungRadiationTherapyCoursePlans (:,1) AriaLungRadiationTherapyCoursePlan {ValidationUtils.MustBeInOrder(voAriaLungRadiationTherapyCoursePlans, @GetTreatmentDate, 'ascend')}
        
        voBrainMetastases (:,1) BrainMetastasis {ValidationUtils.MustBeInOrder(voBrainMetastases, @GetBrainMetastasisNumber, 'ascend')} = BrainMetastasis.empty(0,1)
        
        oFirstBrainRadiationCourse BrainRadiationCourse {ValidationUtils.MustBeEmptyOrScalar}
        
        oPreResectionRadiologyAssessment RadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar} = RadiologyAssessment.empty
        oPreRadiationRadiologyAssessment RadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar} = RadiologyAssessment.empty
        
        voFollowUpRadiologyAssessments (:,1) FollowUpRadiologyAssessment {ValidationUtils.MustBeInOrder(voFollowUpRadiologyAssessments, @GetScanDate, "ascend")} = FollowUpRadiologyAssessment.empty(0,1)
        oPost2YearFollowUpRadiologyAssessment RadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar} = RadiologyAssessment.empty
        
        oPseudoProgressionConclusionAssessment PseudoProgressionConclusionAssessment {ValidationUtils.MustBeEmptyOrScalar} = PseudoProgressionConclusionAssessment.empty
        
        voPrimaryCancerHistopathologyReports (:,1) PrimaryCancerHistopathologyReport {ValidationUtils.MustBeInOrder(voPrimaryCancerHistopathologyReports, @GetDate, "ascend")} = PrimaryCancerHistopathologyReport.empty(0,1)
        voExtracranialMetastasisHistopathologyReports (:,1) ExtracranialMetastasisHistopathologyReport {ValidationUtils.MustBeInOrder(voExtracranialMetastasisHistopathologyReports, @GetDate, "ascend")} = ExtracranialMetastasisHistopathologyReport.empty(0,1)
        voBrainMetastasisHistopathologyReports (:,1) BrainMetastasisHistopathologyReport {ValidationUtils.MustBeInOrder(voBrainMetastasisHistopathologyReports, @GetDate, "ascend")} = BrainMetastasisHistopathologyReport.empty(0,1)
        
        voSystemicTherapies (:,1) SystemicTherapy {ValidationUtils.MustBeInOrder(voSystemicTherapies, @GetStartDate, "ascend")} = SystemicTherapy.empty(0,1)
        voSalvageTreatments (:,1) SalvageTreatment {ValidationUtils.MustBeInOrder(voSalvageTreatments, @GetTreatmentDate, "ascend")} = SalvageTreatment.empty(0,1)
        voRadionecrosisTreatments (:,1) RadionecrosisTreatment {ValidationUtils.MustBeInOrder(voRadionecrosisTreatments, @GetTreatmentDate, "ascend")} = RadionecrosisTreatment.empty(0,1)
        
        sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
        
        sOrthancUUID string {ValidationUtils.MustBeEmptyOrScalar} = string.empty        
        voDicomStudies (:,1) DicomStudy = DicomStudy.empty(0,1)                
        voImagingSeriesRegistrations (:,1) ImagingSeriesRegistration 
    end
    
    properties (Constant = true, GetAccess = private)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Patient(dStudyId, bIsExcluded, sExclusionReason, eSex, dtAgeAtFirstBrainRTTreatment, eDeceasedStatus, dtSurvivalTimeFromFirstBrainRTTreatment, sREDCapDataCollectionNotes, voBrainMetastases, voAriaDiagnoses, voAriaBrainRadiationTherapyCoursePlans, voAriaLungRadiationTherapyCoursePlans, oFirstBrainRadiationCourse, oPreResectionRadiologyAssessment, oPreRadiationRadiologyAssessment, voFollowUpRadiologyAssessments, oPost2YearFollowUpRadiologyAssessment, oPseudoProgressionConclusionAssessment, voPrimaryCancerHistopathologyReports, voExtracranialMetastasisHistopathologyReports, voBrainMetastasisHistopathologyReports, voSystemicTherapies, voSalvageTreatments, voRadionecrosisTreatments, sOrthancUUID, voDicomStudies, voImagingSeriesRegistrations)
            arguments
                dStudyId (1,1) double {mustBeInteger, mustBePositive}
                bIsExcluded
                sExclusionReason
                eSex Sex {ValidationUtils.MustBeEmptyOrScalar}
                dtAgeAtFirstBrainRTTreatment calendarDuration {ValidationUtils.MustBeEmptyOrScalar}
                eDeceasedStatus DeceasedStatus {ValidationUtils.MustBeEmptyOrScalar}
                dtSurvivalTimeFromFirstBrainRTTreatment calendarDuration {ValidationUtils.MustBeEmptyOrScalar}
                sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}
                voBrainMetastases (:,1) BrainMetastasis
                voAriaDiagnoses (:,1) AriaDiagnosis
                voAriaBrainRadiationTherapyCoursePlans (:,1) AriaRadiationTherapyCoursePlan
                voAriaLungRadiationTherapyCoursePlans (:,1) AriaLungRadiationTherapyCoursePlan
                oFirstBrainRadiationCourse BrainRadiationCourse {ValidationUtils.MustBeEmptyOrScalar}
                oPreResectionRadiologyAssessment RadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar}
                oPreRadiationRadiologyAssessment RadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar}
                voFollowUpRadiologyAssessments (:,1) FollowUpRadiologyAssessment
                oPost2YearFollowUpRadiologyAssessment RadiologyAssessment {ValidationUtils.MustBeEmptyOrScalar}
                oPseudoProgressionConclusionAssessment PseudoProgressionConclusionAssessment {ValidationUtils.MustBeEmptyOrScalar}
                voPrimaryCancerHistopathologyReports (:,1) PrimaryCancerHistopathologyReport
                voExtracranialMetastasisHistopathologyReports (:,1) ExtracranialMetastasisHistopathologyReport
                voBrainMetastasisHistopathologyReports (:,1) BrainMetastasisHistopathologyReport
                voSystemicTherapies (:,1) SystemicTherapy
                voSalvageTreatments (:,1) SalvageTreatment
                voRadionecrosisTreatments (:,1) RadionecrosisTreatment
                sOrthancUUID string {ValidationUtils.MustBeEmptyOrScalar}
                voDicomStudies (:,1) DicomStudy
                voImagingSeriesRegistrations (:,1) ImagingSeriesRegistration 
            end
            
            obj.dStudyId = dStudyId;
            
            obj.bIsExcluded = bIsExcluded;
            obj.sExclusionReason = sExclusionReason;
            
            obj.dtAgeAtFirstBrainRTTreatment = dtAgeAtFirstBrainRTTreatment;
            obj.dtSurvivalTimeFromFirstBrainRTTreatment = dtSurvivalTimeFromFirstBrainRTTreatment;
            
            obj.eDeceasedStatus = eDeceasedStatus;
            
            obj.eSex = eSex;
            
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
            
            obj.voBrainMetastases = voBrainMetastases;
            
            obj.voAriaDiagnoses = voAriaDiagnoses;
            obj.voAriaBrainRadiationTherapyCoursePlans = voAriaBrainRadiationTherapyCoursePlans;
            obj.voAriaLungRadiationTherapyCoursePlans = voAriaLungRadiationTherapyCoursePlans;
            
            obj.oFirstBrainRadiationCourse = oFirstBrainRadiationCourse;
            
            obj.oPreResectionRadiologyAssessment = oPreResectionRadiologyAssessment;
            obj.oPreRadiationRadiologyAssessment = oPreRadiationRadiologyAssessment;
            
            obj.voFollowUpRadiologyAssessments = voFollowUpRadiologyAssessments;
            obj.oPost2YearFollowUpRadiologyAssessment = oPost2YearFollowUpRadiologyAssessment;

            obj.oPseudoProgressionConclusionAssessment = oPseudoProgressionConclusionAssessment;
            
            obj.voPrimaryCancerHistopathologyReports = voPrimaryCancerHistopathologyReports;
            obj.voExtracranialMetastasisHistopathologyReports = voExtracranialMetastasisHistopathologyReports;
            obj.voBrainMetastasisHistopathologyReports = voBrainMetastasisHistopathologyReports;
            
            obj.voSystemicTherapies = voSystemicTherapies;
            obj.voSalvageTreatments = voSalvageTreatments;
            obj.voRadionecrosisTreatments = voRadionecrosisTreatments;
            
            obj.sOrthancUUID = sOrthancUUID;
            obj.voDicomStudies = voDicomStudies;
            obj.voImagingSeriesRegistrations = voImagingSeriesRegistrations;            
        end
        
        function dStudyId = GetStudyId(obj)
            dStudyId = obj.dStudyId;
        end
        
        function dStudyId = GetMySQLPrimaryKey(obj)
            dStudyId = obj.GetStudyId();
        end
        
        function sExclusionReason = GetExclusionReason(obj)
            sExclusionReason = obj.sExclusionReason;
        end
        
        function voAriaDiagnoses = GetAriaDiagnoses(obj)
            voAriaDiagnoses = obj.voAriaDiagnoses;
        end
        
        function voAriaBrainRadiationTherapyCoursePlans = GetAriaBrainRadiationTherapyCoursePlans(obj)
            voAriaBrainRadiationTherapyCoursePlans = obj.voAriaBrainRadiationTherapyCoursePlans;
        end
        
        function voAriaLungRadiationTherapyCoursePlans = GetAriaLungRadiationTherapyCoursePlans(obj)
            voAriaLungRadiationTherapyCoursePlans = obj.voAriaLungRadiationTherapyCoursePlans;
        end
        
        function dtDate = GetFirstBrainRadiationTherapyDate(obj)
            if isempty(obj.voAriaBrainRadiationTherapyCoursePlans)
                dtDate = datetime.empty;
            else
                dtDate = obj.voAriaBrainRadiationTherapyCoursePlans(1).GetTreatmentDate();
            end
        end
        
        function eSex = GetSex(obj)
            eSex = obj.eSex;
        end
        
        function eDeceasedStatus = GetDeceasedStatus(obj)
            eDeceasedStatus = obj.eDeceasedStatus;
        end
        
        function dtAgeAtFirstBrainRTTreatment = GetAgeAtFirstBrainRTTreatment(obj)
            dtAgeAtFirstBrainRTTreatment = obj.dtAgeAtFirstBrainRTTreatment;
        end
                        
        function dtSurvivalTimeFromFirstBrainRTTreatment = GetSurvivalTimeFromFirstBrainRTTreatment(obj)
            dtSurvivalTimeFromFirstBrainRTTreatment = obj.dtSurvivalTimeFromFirstBrainRTTreatment;
        end
        
        function sREDCapDataCollectionNotes = GetREDCapDataCollectionNotes(obj)
            sREDCapDataCollectionNotes = obj.sREDCapDataCollectionNotes;
        end
        
        function voFollowUpRadiologyAssessments = GetFollowUpRadiologyAssessments(obj)
            voFollowUpRadiologyAssessments = obj.voFollowUpRadiologyAssessments;
        end
        
        function vdtScanDates = GetFollowUpRadiologyAssessmentScanDates(obj)
            voFollowUpRadiologyAssessments = obj.GetFollowUpRadiologyAssessments();
            
            vdtScanDates = NaT(size(voFollowUpRadiologyAssessments));
            
            for dAssessmentIndex=1:length(voFollowUpRadiologyAssessments)
                vdtScanDates(dAssessmentIndex) = voFollowUpRadiologyAssessments(dAssessmentIndex).GetScanDate();
            end
        end
        
        function oPost2YearFollowUpRadiologyAssessment = GetPost2YearFollowUpRadiologyAssessment(obj)
            oPost2YearFollowUpRadiologyAssessment = obj.oPost2YearFollowUpRadiologyAssessment;
        end
        
        function voPrimaryCancerHistopathologyReports = GetPrimaryCancerHistopathologyReports(obj)
            voPrimaryCancerHistopathologyReports = obj.voPrimaryCancerHistopathologyReports;
        end
        
        function voExtracranialMetastasisHistopathologyReports = GetExtracranialMetastasisHistopathologyReports(obj)
            voExtracranialMetastasisHistopathologyReports = obj.voExtracranialMetastasisHistopathologyReports;
        end
        
        function voBrainMetastasisHistopathologyReports = GetBrainMetastasisHistopathologyReports(obj)
            voBrainMetastasisHistopathologyReports = obj.voBrainMetastasisHistopathologyReports;
        end
        
        function oPreResectionRadiologyAssessment = GetPreResectionRadiologyAssessment(obj)
            oPreResectionRadiologyAssessment = obj.oPreResectionRadiologyAssessment;
        end
        
        function oPreRadiationRadiologyAssessment = GetPreRadiationRadiologyAssessment(obj)
            oPreRadiationRadiologyAssessment = obj.oPreRadiationRadiologyAssessment;
        end
        
        function oFirstBrainRadiationCourse = GetFirstBrainRadiationCourse(obj)
            oFirstBrainRadiationCourse = obj.oFirstBrainRadiationCourse;
        end
        
        function voSalvageTreatments = GetSalvageTreatments(obj)
            voSalvageTreatments = obj.voSalvageTreatments;
        end
        
        function voSystemicTherapies = GetSystemicTherapies(obj)
            voSystemicTherapies = obj.voSystemicTherapies;
        end
        
        function voRadionecrosisTreatments = GetRadionecrosisTreatments(obj)
            voRadionecrosisTreatments = obj.voRadionecrosisTreatments;
        end
        
        function oPseudoProgressionConclusionAssessment = GetPseudoProgressionConclusionAssessment(obj)
            oPseudoProgressionConclusionAssessment = obj.oPseudoProgressionConclusionAssessment;
        end
        
        function [oPreResectionRadiologyAssessment, oPreRadiationRadiologyAssessment, voFollowUpRadiologyAssessments, oPost2YearFollowUpRadiologyAssessment] = GetRadiologyAssessmentsForBrainMetastasis(obj, dBrainMetastasisNumber)
            arguments
                obj (1,1) Patient
                dBrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if isempty(obj.oPreResectionRadiologyAssessment)
                oPreResectionRadiologyAssessment = BrainMetastasisPreTreatmentRadiologyAssessment.empty;
            else
                oPreResectionRadiologyAssessment = obj.oPreResectionRadiologyAssessment.GetBrainMetastasisRadiologyAssessmentForBrainMetastasis(dBrainMetastasisNumber);
            end
            
            oPreRadiationRadiologyAssessment = obj.oPreRadiationRadiologyAssessment.GetBrainMetastasisRadiologyAssessmentForBrainMetastasis(dBrainMetastasisNumber);
            
            dNumFollowUps = length(obj.voFollowUpRadiologyAssessments);
            
            if dNumFollowUps == 0
                voFollowUpRadiologyAssessments = BrainMetastasisFollowUpRadiologyAssessment.empty(0,1);
            else
                c1oFollowUpRadiologyAssessments = cell(dNumFollowUps,1);
                
                for dFollowUpIndex=1:dNumFollowUps
                    c1oFollowUpRadiologyAssessments{dFollowUpIndex} = obj.voFollowUpRadiologyAssessments(dFollowUpIndex).GetBrainMetastasisRadiologyAssessmentForBrainMetastasis(dBrainMetastasisNumber);
                end
                
                voFollowUpRadiologyAssessments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oFollowUpRadiologyAssessments);
            end
            
            if isempty(obj.oPost2YearFollowUpRadiologyAssessment)
                oPost2YearFollowUpRadiologyAssessment = BrainMetastasisFollowUpRadiologyAssessment.empty;
            else
                oPost2YearFollowUpRadiologyAssessment = obj.oPost2YearFollowUpRadiologyAssessment.GetBrainMetastasisRadiologyAssessmentForBrainMetastasis(dBrainMetastasisNumber);
            end
        end
        
        function GetImagingTimeline(obj)
            vdtEventDates = datetime.empty;
            vsEventDescriptions = string.empty;
            
            % Approx DOB
            vdtEventDates = [vdtEventDates; obj.GetApproximateDateOfBirth()];
            vsEventDescriptions = [vsEventDescriptions; "Approx. DOB"];
            
            % Approx DOD
            if ~isempty(obj.GetApproximateDateOfDeath())
                vdtEventDates = [vdtEventDates; obj.GetApproximateDateOfDeath()];
                vsEventDescriptions = [vsEventDescriptions; "Approx. DOD"];
            end
            
            % First brain radiation
            vdtEventDates = [vdtEventDates; dateshift(obj.GetFirstBrainRadiationTherapyDate(),'end','month')];
            vsEventDescriptions = [vsEventDescriptions; "First brain RT"];
            
            % Pre-radiation radiology
            vdtEventDates = [vdtEventDates; obj.GetPreRadiationRadiologyAssessment().GetScanDate()];
            vsEventDescriptions = [vsEventDescriptions; "Pre-radiation radiology"];
            
            % F/U radiology
            vdtFollowUpDates = obj.GetFollowUpRadiologyAssessmentScanDates(); 
            
            vdtEventDates = [vdtEventDates; vdtFollowUpDates];
            vsEventDescriptions = [vsEventDescriptions; repmat("Follow-up radiology",length(vdtFollowUpDates),1)];
            
            % Post 2-year F/U
            if ~isempty(obj.GetPost2YearFollowUpRadiologyAssessment())
                vdtEventDates = [vdtEventDates; obj.GetPost2YearFollowUpRadiologyAssessment().GetScanDate()];
                vsEventDescriptions = [vsEventDescriptions; ">2 year follow-up radiology"];
            end
            
            % Sort and print
            [vdtEventDates, vdSortIndices] = sort(vdtEventDates);
            vsEventDescriptions = vsEventDescriptions(vdSortIndices);
            
            for dEventIndex=1:length(vdtEventDates)
                if any(vsEventDescriptions(dEventIndex) == ["Approx. DOB", "Approx. DOD", "First brain RT"])
                    sFormat = "yyyy-mm   ";
                else
                    sFormat = "yyyy-mm-dd";
                end                
                
                disp(string(datestr(vdtEventDates(dEventIndex), sFormat)) + " - " + vsEventDescriptions(dEventIndex));
            end
        end
        
        function GetHistopathologyTimeline(obj)
            vdtEventDates = datetime.empty;
            vsEventDescriptions = string.empty;
            
            % Approx DOB
            vdtEventDates = [vdtEventDates; obj.GetApproximateDateOfBirth()];
            vsEventDescriptions = [vsEventDescriptions; "Approx. DOB"];
            
            % Approx DOD
            if ~isempty(obj.GetApproximateDateOfDeath())
                vdtEventDates = [vdtEventDates; obj.GetApproximateDateOfDeath()];
                vsEventDescriptions = [vsEventDescriptions; "Approx. DOD"];
            end
            
            % First brain radiation
            vdtEventDates = [vdtEventDates; obj.GetFirstBrainRadiationTherapyDate()];
            vsEventDescriptions = [vsEventDescriptions; "First brain RT"];
            
            % Primary cancer histopathology
            voReports = obj.GetPrimaryCancerHistopathologyReports();
            
            for dReportIndex=1:length(voReports)
                vdtEventDates = [vdtEventDates; voReports(dReportIndex).GetDate()];
                vsEventDescriptions = [vsEventDescriptions; "Primary cancer histopathology"];
            end
            
            % Extra-cranial metastasis histopathology
            voReports = obj.GetExtracranialMetastasisHistopathologyReports();
            
            for dReportIndex=1:length(voReports)
                vdtEventDates = [vdtEventDates; voReports(dReportIndex).GetDate()];
                vsEventDescriptions = [vsEventDescriptions; "Extra-cranial metastasis histopathology"];
            end
            
            % Brain met histopathology
            voReports = obj.GetBrainMetastasisHistopathologyReports();
            
            for dReportIndex=1:length(voReports)
                vdtEventDates = [vdtEventDates; voReports(dReportIndex).GetDate()];
                vsEventDescriptions = [vsEventDescriptions; "Brain metastasis histopathology"];
            end
            
            % Sort and print
            [vdtEventDates, vdSortIndices] = sort(vdtEventDates);
            vsEventDescriptions = vsEventDescriptions(vdSortIndices);
            
            for dEventIndex=1:length(vdtEventDates)
                disp(string(datestr(vdtEventDates(dEventIndex), "yyyy-mm-dd")) + " - " + vsEventDescriptions(dEventIndex));
            end
        end
        
        function bBool = IsExcluded(obj)
            bBool = obj.bIsExcluded;
        end
        
        function voImagingSeriesRegistrations = GetImagingSeriesRegistrations(obj)
            voImagingSeriesRegistrations = obj.voImagingSeriesRegistrations;
        end
        
        function dtApproxDateOfDeath = GetApproximateDateOfDeath(obj)
            if isempty(obj.dtSurvivalTimeFromFirstBrainRTTreatment)
                dtApproxDateOfDeath = datetime.empty;
            else
                dtApproxDateOfDeath = obj.GetFirstBrainRadiationTherapyDate() + obj.dtSurvivalTimeFromFirstBrainRTTreatment;
            end
        end  
        
        function dtApproxDateOfBirth = GetApproximateDateOfBirth(obj)
            if isempty(obj.dtAgeAtFirstBrainRTTreatment) || isempty(obj.GetFirstBrainRadiationTherapyDate())
                dtApproxDateOfBirth = datetime.empty;
            else
                dtApproxDateOfBirth = obj.GetFirstBrainRadiationTherapyDate() - obj.dtAgeAtFirstBrainRTTreatment;
            end
        end 
        
        function voBrainMetastases = GetBrainMetastases(obj)
            voBrainMetastases = obj.voBrainMetastases;
        end  
        
        function dNumBMs = GetNumberOfBrainMetastases(obj)
            dNumBMs = length(obj.voBrainMetastases);
        end
        
        function sDicomFolderName = GetDicomFolderName(obj)
            sDicomFolderName = "BRAIN METS SRS SRT " + string(StringUtils.num2str_PadWithZeros(obj.dStudyId,4)) + " BRAIN METS SRS SRT " + string(StringUtils.num2str_PadWithZeros(obj.dStudyId,4));
        end
        
        function [voDicomSeries, voParentDicomStudies] = GetDicomSeriesByImagingSeriesAssignmentType(obj, eImagingSeriesAssignmentType)
            arguments
                obj (1,1) Patient
                eImagingSeriesAssignmentType (1,1) ImagingSeriesAssignmentType
            end
            
            voDicomSeries = DicomSeries.empty;
            voParentDicomStudies = DicomStudy.empty;
            
            for dStudyIndex=1:length(obj.voDicomStudies)
                oStudy = obj.voDicomStudies(dStudyIndex);
                voSeries = oStudy.GetDicomSeries();
                
                for dSeriesIndex=1:length(voSeries)
                    if voSeries(dSeriesIndex).HasImagingSeriesAssignmentType(eImagingSeriesAssignmentType)
                        voDicomSeries = [voDicomSeries; voSeries(dSeriesIndex)];
                        voParentDicomStudies = [voParentDicomStudies; oStudy];
                    end
                end
            end
        end
        
        function oImageVolume = LoadProcessedImageVolume(obj, sIMGPPCode, dBrainMetastasisNumber)
            arguments
                obj (1,1) Patient
                sIMGPPCode (1,1) string
                dBrainMetastasisNumber double {ValidationUtils.MustBeEmptyOrScalar} = []
            end
            
            oImageVolume = ImageVolume.Load(obj.GetProcessedImageVolumeMatFilePath(sIMGPPCode, dBrainMetastasisNumber));
        end
        
        function sFilePath = GetProcessedImageVolumeMatFilePath(obj, sIMGPPCode, dBrainMetastasisNumber)
            arguments
                obj (1,1) Patient
                sIMGPPCode (1,1) string
                dBrainMetastasisNumber double {ValidationUtils.MustBeEmptyOrScalar} = []
            end
            
            vsIMGPPCodeParts = strsplit(sIMGPPCode, "-");
            
            switch vsIMGPPCodeParts(2)
                case "002"
                    eImagingSeriesAssignment = ImagingSeriesAssignmentType.T1wPostContrast;
                case "003"
                    eImagingSeriesAssignment = ImagingSeriesAssignmentType.PlanningCT;
                case "004"
                    eImagingSeriesAssignment = ImagingSeriesAssignmentType.T1wPostContrast;
                case "005"
                    eImagingSeriesAssignment = ImagingSeriesAssignmentType.T1wPostContrast;
                otherwise
                    error("Unknown code");
            end
            
            sFilePath = obj.GetDicomSeriesByImagingSeriesAssignmentType(eImagingSeriesAssignment).GetMatFilePath(obj, sIMGPPCode, dBrainMetastasisNumber);
        end
        
        function oRegionsOfInterest = LoadProcessedRegionsOfInterest(obj, sROIPPCode, dBrainMetastasisNumber)
            arguments
                obj (1,1) Patient
                sROIPPCode (1,1) string
                dBrainMetastasisNumber double {ValidationUtils.MustBeEmptyOrScalar} = []
            end
            
            oRegionsOfInterest = RegionsOfInterest.Load(obj.GetProcessedRegionsOfInterestMatFilePath(sROIPPCode, dBrainMetastasisNumber));
        end
        
        function sFilePath = GetProcessedRegionsOfInterestMatFilePath(obj, sROIPPCode, dBrainMetastasisNumber)
            arguments
                obj (1,1) Patient
                sROIPPCode (1,1) string
                dBrainMetastasisNumber double {ValidationUtils.MustBeEmptyOrScalar} = []
            end
            
            sFilePath = obj.GetDicomSeriesByImagingSeriesAssignmentType(ImagingSeriesAssignmentType.Contours).GetMatFilePath(obj, sROIPPCode, dBrainMetastasisNumber);
        end
        
        function [voImagingSeriesRegistrations] = GetRegistrationsBetweenImagingSeriesAssignmentTypes(obj, eImagingSeriesAssignmentType1, eImagingSeriesAssignmentType2)
            arguments
                obj (1,1) Patient
                eImagingSeriesAssignmentType1 (1,1) ImagingSeriesAssignmentType
                eImagingSeriesAssignmentType2 (1,1) ImagingSeriesAssignmentType
            end
            
            voImagingSeriesRegistrations = obj.voImagingSeriesRegistrations;
            dNumRegistrations = length(voImagingSeriesRegistrations);
            
            vbKeepRegistration = false(dNumRegistrations,1);
            
            for dRegistrationIndex=1:dNumRegistrations
                vePrimaryImagingSeriesAssignments = voImagingSeriesRegistrations(dRegistrationIndex).GetPrimaryImagingDicomSeries().GetImagingSeriesAssignments().GetType();
                veSecondaryImagingSeriesAssignments = voImagingSeriesRegistrations(dRegistrationIndex).GetSecondaryImagingDicomSeries().GetImagingSeriesAssignments().GetType();
                
                if (any(vePrimaryImagingSeriesAssignments == eImagingSeriesAssignmentType1) && any(veSecondaryImagingSeriesAssignments == eImagingSeriesAssignmentType2)) || (any(vePrimaryImagingSeriesAssignments == eImagingSeriesAssignmentType2) && any(veSecondaryImagingSeriesAssignments == eImagingSeriesAssignmentType1))
                    vbKeepRegistration(dRegistrationIndex) = true;
                end
            end
            
            voImagingSeriesRegistrations = voImagingSeriesRegistrations(vbKeepRegistration);            
        end
        
        function oDicomStudy = GetDicomStudyForDicomSeries(obj, oDicomSeries)
            dNumStudies = length(obj.voDicomStudies);
            vbMatch = false(dNumStudies);
            
            for dStudyIndex=1:dNumStudies
                vbMatch(dStudyIndex) = obj.voDicomStudies(dStudyIndex).DoesContainDicomSeries(oDicomSeries);
            end
            
            if sum(vbMatch) > 1
                error(...
                    'Patient:GetDicomStudyForDicomSeries:MultipleStudies',...
                    'Multiple studies found to contain the same Dicom series. This is invalid.');
            end
            
            oDicomStudy = obj.voDicomStudies(vbMatch);
        end
        
        function voDicomSeries = GetDicomSeriesByModality(obj, eDicomModality)
            arguments
                obj (1,1) Patient
                eDicomModality (1,1) DicomModality
            end
            
            voDicomSeries = DicomSeries.empty;
            
            for dStudyIndex=1:length(obj.voDicomStudies)
                oStudy = obj.voDicomStudies(dStudyIndex);
                voSeries = oStudy.GetDicomSeries();
                
                for dSeriesIndex=1:length(voSeries)
                    if voSeries(dSeriesIndex).GetDicomModality() == eDicomModality
                        voDicomSeries = [voDicomSeries; voSeries(dSeriesIndex)];
                    end
                end
            end
        end
    end
    
    methods (Access = public, Static)
                
        function voPatients = LoadFromDatabase(vdStudyIds)
            arguments
                vdStudyIds (:,1) double {mustBeInteger, mustBePositive} = []
            end
            
            if isempty(vdStudyIds) % load all
                tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "patients", []);
            else
                tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "patients", [], "WHERE patient_study_id IN (" + strjoin(string(vdStudyIds), ", ") + ")");
            end
            
            dNumPatients = size(tOutput,1);
            
            if dNumPatients == 0
                voPatients = Patient.empty;
            else
                c1oPatients = cell(dNumPatients,1);
                
                for dPatientIndex=1:dNumPatients     
                    dPatientStudyId = tOutput.patient_study_id{dPatientIndex};
                    
                    voAriaDiagnoses = AriaDiagnosis.LoadFromDatabase(dPatientStudyId);
                    voAriaBrainRadiationTherapyCoursePlans = AriaRadiationTherapyCoursePlan.LoadFromDatabase(dPatientStudyId, "aria_brain_radiation_therapy_course_plans");
                    voAriaLungRadiationTherapyCoursePlans = AriaLungRadiationTherapyCoursePlan.LoadFromDatabase(dPatientStudyId);
                    
                    voBrainMetastases = BrainMetastasis.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    
                    oFirstBrainRadiationCourse = BrainRadiationCourse.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                         
                    oPreResectionRadiologyAssessment = RadiologyAssessment.LoadFromDatabaseByPatientStudyId(dPatientStudyId, RadiologyAssessmentType.PreResection);
                    oPreRadiationRadiologyAssessment = RadiologyAssessment.LoadFromDatabaseByPatientStudyId(dPatientStudyId, RadiologyAssessmentType.PreRadiation);
                    
                    voFollowUpRadiologyAssessments = FollowUpRadiologyAssessment.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    oPost2YearFollowUpRadiologyAssessment = RadiologyAssessment.LoadFromDatabaseByPatientStudyId(dPatientStudyId, RadiologyAssessmentType.Post2YearFollowUp);
                                 
                    oPseudoProgressionConclusionAssessment = PseudoProgressionConclusionAssessment.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    
                    voPrimaryCancerHistopathologyReports = PrimaryCancerHistopathologyReport.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    voExtracranialMetastasisHistopathologyReports = ExtracranialMetastasisHistopathologyReport.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    voBrainMetastasisHistopathologyReports = BrainMetastasisHistopathologyReport.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    
                    voSystemicTherapies = SystemicTherapy.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    voSalvageTreatments = SalvageTreatment.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    voRadionecrosisTreatments = RadionecrosisTreatment.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                              
                    voDicomStudies = DicomStudy.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    voImagingSeriesRegistrations = ImagingSeriesRegistration.LoadFromDatabaseByPatientStudyId(dPatientStudyId);
                    
                    c1oPatients{dPatientIndex} = Patient(...
                        dPatientStudyId,...
                        tOutput.is_excluded{dPatientIndex},...
                        tOutput.exclusion_reason{dPatientIndex},...
                        Sex.GetEnumFromMySQLEnumValue(tOutput.sex{dPatientIndex}),...
                        calmonths(tOutput.age_at_first_srs_srt_months{dPatientIndex}),...
                        DeceasedStatus.GetEnumFromMySQLEnumValue(tOutput.deceased_status{dPatientIndex}),...
                        calmonths(tOutput.survival_time_months{dPatientIndex}),...
                        tOutput.data_collection_notes{dPatientIndex},...
                        voBrainMetastases,...
                        voAriaDiagnoses,...
                        voAriaBrainRadiationTherapyCoursePlans,...
                        voAriaLungRadiationTherapyCoursePlans,...
                        oFirstBrainRadiationCourse,...
                        oPreResectionRadiologyAssessment,...
                        oPreRadiationRadiologyAssessment,...
                        voFollowUpRadiologyAssessments,...
                        oPost2YearFollowUpRadiologyAssessment,...
                        oPseudoProgressionConclusionAssessment,...
                        voPrimaryCancerHistopathologyReports,...
                        voExtracranialMetastasisHistopathologyReports,...
                        voBrainMetastasisHistopathologyReports,...
                        voSystemicTherapies,...
                        voSalvageTreatments,...
                        voRadionecrosisTreatments,...
                        tOutput.orthanc_pacs_uuid{dPatientIndex},...
                        voDicomStudies,...
                        voImagingSeriesRegistrations);
                end
                
                voPatients = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPatients);
            end
        end
        
        function voValidationRecords = Validate(voPatients, voValidationRecords)
            arguments
                voPatients (:,1) Patient
                voValidationRecords (:,1) DataValidationRecord = DataValidationRecord.empty
            end
                        
            for dPatientIndex=1:length(voPatients)
                oPatient = voPatients(dPatientIndex);
                
                % Validation:
                % - bIsExcluded:
                % -- Is true
                if oPatient.bIsExcluded
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "bIsExcluded", "Is true"));
                end
                
                % - sExclusionReason
                % none
                
                % - dtAgeAtFirstBrainRTTreatment:
                % -- Empty
                if isempty(oPatient.dtAgeAtFirstBrainRTTreatment)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "dtAgeAtFirstBrainRTTreatment", "Is empty"));
                else                
                    % -- < 30 years
                    if calmonths(oPatient.dtAgeAtFirstBrainRTTreatment) < 30*12
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "dtAgeAtFirstBrainRTTreatment", "Less than 30 years"));
                    end
                    
                    % -- > 100 years
                    if calmonths(oPatient.dtAgeAtFirstBrainRTTreatment) > 100*12
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "dtAgeAtFirstBrainRTTreatment", "Greater than 100 years"));
                    end
                end
                
                
                % - dtSurvivalTimeFromFirstBrainRTTreatment:
                % -- Patient not deceased and post 2 year not filled out
                if isempty(oPatient.dtSurvivalTimeFromFirstBrainRTTreatment) && isempty(oPatient.oPost2YearFollowUpRadiologyAssessment)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "dtSurvivalTimeFromFirstBrainRTTreatment", "Patient not deceased, but post 2-year radiology follow-up not completed"));
                end
                
                % - eDeceasedStatus
                % -- empty
                if isempty(oPatient.eDeceasedStatus)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "eDeceasedStatus", "Is empty"));
                else
                    % -- status does not match dtSurvivalTimeFromFirstBrainRTTreatment
                    if isempty(oPatient.dtSurvivalTimeFromFirstBrainRTTreatment) && (oPatient.eDeceasedStatus ~= DeceasedStatus.NotDeceased)
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "eDeceasedStatus", "Does not match dtSurvivalTimeFromFirstBrainRTTreatment"));
                    end
                end
                    
                % - eSex
                % -- empty
                if isempty(oPatient.eSex)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "eSex", "Is empty"));
                end
                
                % - voAriaDiagnoses
                % -- empty
                if isempty(oPatient.voAriaDiagnoses)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voAriaDiagnoses", "No Aria diagnoses"));
                else
                    voValidationRecords = AriaDiagnosis.Validate(oPatient.voAriaDiagnoses, oPatient, voValidationRecords);
                end
                
                % - voAriaBrainRadiationTherapyCoursePlans
                if isempty(oPatient.voAriaBrainRadiationTherapyCoursePlans)                
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voAriaBrainRadiationTherapyCoursePlans", "No Aria brain radiation therapy course plans"));
                else
                    voValidationRecords = AriaRadiationTherapyCoursePlan.Validate(oPatient.voAriaBrainRadiationTherapyCoursePlans, "Brain", oPatient, voValidationRecords);
                end
                
                % - voAriaLungRadiationTherapyCoursePlans
                voValidationRecords = AriaLungRadiationTherapyCoursePlan.Validate(oPatient.voAriaLungRadiationTherapyCoursePlans, oPatient, voValidationRecords);
                
                % - voBrainMetastases
                % -- empty
                if isempty(oPatient.voBrainMetastases)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voBrainMetastases", "No brain metastases"));
                else
                    voValidationRecords = BrainMetastasis.Validate(oPatient.voBrainMetastases, oPatient, voValidationRecords);
                end
                
                % - oFirstBrainRadiationCourse
                if isempty(oPatient.oFirstBrainRadiationCourse)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "oFirstBrainRadiationCourse", "No first brain radiation course"));
                else                
                    voValidationRecords = BrainRadiationCourse.Validate(oPatient.oFirstBrainRadiationCourse, oPatient, "FirstBrainRadiationCourse", voValidationRecords);
                end
                
                % - oPreResectionRadiologyAssessment
                if ~isempty(oPatient.oPreRadiationRadiologyAssessment)
                    bHasSurgicalCavity = false;
                    
                    voBrainMetastasisRadiologyAssessmentPerBrainMetastasis = oPatient.oPreRadiationRadiologyAssessment.GetBrainMetastasisRadiologyAssessmentPerBrainMetastasis();
                    
                    for dAssessmentIndex=1:length(voBrainMetastasisRadiologyAssessmentPerBrainMetastasis)
                        if voBrainMetastasisRadiologyAssessmentPerBrainMetastasis(dAssessmentIndex).IsSurgicalCavityPresent()
                            bHasSurgicalCavity = true;
                            break;
                        end
                    end
                    
                    % -- empty even though BMs were classified as surgical cavities in pre-radiation imaging
                    if bHasSurgicalCavity && isempty(oPatient.oPreResectionRadiologyAssessment)
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "oPreResectionRadiologyAssessment", "Pre-resection radiology assessment not present though surgical cavities were identified in pre-radiation radiology assessment"));
                    end
                    
                    % -- non-empty even though no BMs were classified as
                    % surgical cavities in pre-radiation imaging
                    if ~bHasSurgicalCavity && ~isempty(oPatient.oPreResectionRadiologyAssessment)
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "oPreResectionRadiologyAssessment", "Pre-resection radiology assessment present even though no surgical cavities were identified in pre-radiation radiology assessment"));
                    end
                end
                
                if ~isempty(oPatient.oPreResectionRadiologyAssessment)                
                    voValidationRecords = RadiologyAssessment.Validate(oPatient.oPreResectionRadiologyAssessment, oPatient, "PreResection", voValidationRecords);
                end
                
                % - oPreRadiationRadiologyAssessment
                % -- empty
                if isempty(oPatient.oPreRadiationRadiologyAssessment)                
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "oPreRadiationRadiologyAssessment", "Is empty"));
                else
                    voValidationRecords = RadiologyAssessment.Validate(oPatient.oPreRadiationRadiologyAssessment, oPatient, "PreRadiation", voValidationRecords);
                end
                
                % - voFollowUpRadiologyAssessments
                if ~isempty(oPatient.voFollowUpRadiologyAssessments)
                    voValidationRecords = FollowUpRadiologyAssessment.Validate(oPatient.voFollowUpRadiologyAssessments, oPatient, voValidationRecords);
                end
                
                % - oPost2YearFollowUpRadiologyAssessment
                if isempty(oPatient.oPost2YearFollowUpRadiologyAssessment)
                    % -- is empty even though patient survived > 2 years or
                    % is still living
                    if isempty(oPatient.dtSurvivalTimeFromFirstBrainRTTreatment) || calmonths(oPatient.dtSurvivalTimeFromFirstBrainRTTreatment) > 24
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "oPost2YearFollowUpRadiologyAssessment", "Is empty despite the patient having >2 year survival"));
                    end
                else
                    voValidationRecords = RadiologyAssessment.Validate(oPatient.oPost2YearFollowUpRadiologyAssessment, oPatient, 'Post2YearFollowUp', voValidationRecords);
                end
                
                % - oPseudoProgressionConclusionAssessment
                if isempty(oPatient.oPseudoProgressionConclusionAssessment)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "oPseudoProgressionConclusionAssessment", "Is empty"));
                else
                    voValidationRecords = PseudoProgressionConclusionAssessment.Validate(oPatient.oPseudoProgressionConclusionAssessment, oPatient, voValidationRecords);
                end
                
                % - voPrimaryCancerHistopathologyReports
                if isempty(oPatient.voPrimaryCancerHistopathologyReports)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voPrimaryCancerHistopathologyReports", "Is empty"));
                else
                    voValidationRecords = HistopathologyReport.Validate(oPatient.voPrimaryCancerHistopathologyReports, oPatient, voValidationRecords);
                end
                
                % - voExtracranialMetastasisHistopathologyReports
                if ~isempty(oPatient.voExtracranialMetastasisHistopathologyReports)
                    voValidationRecords = HistopathologyReport.Validate(oPatient.voExtracranialMetastasisHistopathologyReports, oPatient, voValidationRecords);
                end
                
                % - voBrainMetastasisHistopathologyReports
                if ~isempty(oPatient.voBrainMetastasisHistopathologyReports)
                    voValidationRecords = BrainMetastasisHistopathologyReport.Validate(oPatient.voBrainMetastasisHistopathologyReports, oPatient, voValidationRecords);
                end
                
                % - voSystemicTherapies
                if ~isempty(oPatient.voSystemicTherapies)
                    voValidationRecords = SystemicTherapy.Validate(oPatient.voSystemicTherapies, oPatient, voValidationRecords);
                end
                
                % - voSalvageTreatments
                if ~isempty(oPatient.voSalvageTreatments)
                    voValidationRecords = SalvageTreatment.Validate(oPatient.voSalvageTreatments, oPatient, voValidationRecords);
                end
                
                % - voRadionecrosisTreatments
                if ~isempty(oPatient.voRadionecrosisTreatments)
                    % -- no brain metastasis histopathology indicating
                    % radionecrosis
                    bHasRadionecrosisHistopathology = false;
                    
                    for dReportIndex=1:length(oPatient.voBrainMetastasisHistopathologyReports)
                        if oPatient.voBrainMetastasisHistopathologyReports(dReportIndex).IsNecrosisPresent()
                            bHasRadionecrosisHistopathology = true;
                            break;
                        end
                    end
                    
                    if ~bHasRadionecrosisHistopathology
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voRadionecrosisTreatments", "Received radionecrosis treatment without histopathology confirmation"));
                    end
                    
                    voValidationRecords = RadionecrosisTreatment.Validate(oPatient.voRadionecrosisTreatments, oPatient, voValidationRecords);
                end
                
                % - sREDCapDataCollectionNotes
                % none
                
                % - sOrthancUUID
                % none
                
                % - voDicomStudies
                % -- single T1w-CE MRI not present
                oSeries = oPatient.GetDicomSeriesByImagingSeriesAssignmentType(ImagingSeriesAssignmentType.T1wPostContrast);
                
                if ~isscalar(oSeries)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "GetDicomSeriesByImagingSeriesAssignmentType(ImagingSeriesAssignmentType.T1wPostContrast)", "No single T1w post-contrast imaging series"));
                end
                
                % -- single Planning CT not present
                oSeries = oPatient.GetDicomSeriesByImagingSeriesAssignmentType(ImagingSeriesAssignmentType.PlanningCT);
                
                if ~isscalar(oSeries)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "GetDicomSeriesByImagingSeriesAssignmentType(ImagingSeriesAssignmentType.PlanningCT)", "No single planning CT imaging series"));
                end
                
                % -- single contours not present
                oSeries = oPatient.GetDicomSeriesByImagingSeriesAssignmentType(ImagingSeriesAssignmentType.Contours);
                
                if ~isscalar(oSeries)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "GetDicomSeriesByImagingSeriesAssignmentType(ImagingSeriesAssignmentType.Contours)", "No single contours imaging series"));
                end
                
                % - voImagingSeriesRegistrations
                % -- no single registration
                oRegistration = oPatient.voImagingSeriesRegistrations;
                
                if ~isscalar(oRegistration)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voImagingSeriesRegistrations", "No single image registration file"));
                else
                    % -- registration must be to T1w-CE
                    if ~oRegistration.GetPrimaryImagingDicomSeries().HasImagingSeriesAssignmentType(ImagingSeriesAssignmentType.T1wPostContrast) && ~oRegistration.GetSecondaryImagingDicomSeries().HasImagingSeriesAssignmentType(ImagingSeriesAssignmentType.T1wPostContrast)
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voImagingSeriesRegistrations", "Registration does not include T1w post-contrast imaging series"));
                    end
                    
                    % -- registration must be to planning CT
                    if ~oRegistration.GetPrimaryImagingDicomSeries().HasImagingSeriesAssignmentType(ImagingSeriesAssignmentType.PlanningCT) && ~oRegistration.GetSecondaryImagingDicomSeries().HasImagingSeriesAssignmentType(ImagingSeriesAssignmentType.PlanningCT)
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voImagingSeriesRegistrations", "Registration does not include planning CT imaging series"));
                    end
                    
                    % -- registration source not Pinnacle (cannot be trusted,
                    % MIM registration should have been made)
                    if oRegistration.GetSource() ~= ImagingSeriesRegistrationSource.RayStation && oRegistration.GetSource() ~= ImagingSeriesRegistrationSource.MIM
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oPatient, "voImagingSeriesRegistrations", "Registration is not from RayStation nor MIM"));
                    end
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

