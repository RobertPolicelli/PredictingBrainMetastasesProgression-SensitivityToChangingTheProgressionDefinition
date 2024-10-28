classdef DatabasePatient < handle
    %Patient
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dPrimaryId (1,1) double {mustBeInteger}
        
        dAge (1,1) double
        eGender (1,1) Gender
        
        voDiagnoses Diagnosis = Diagnosis.empty(1,0)
        
        voBrainRadiationCourses RadiationCourse = RadiationCourse.empty(1,0)
        voLungRadiationCourses RadiationCourse = RadiationCourse.empty(1,0)
        
        oFirstBrainRadiationCourseTreatmentPlan BrainRadiationTreatmentPlan {ValidationUtils.MustBeEmptyOrScalar} = RayStationBrainRadiationTreatmentPlan.empty(1,0)
    end
    
    
    properties (Constant = true, GetAccess = private)
        dPrimaryIdStringNumberOfDigits = 4
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DatabasePatient(dPrimaryId, dAge, eGender, voDiagnoses, voBrainRadiationCourses, voLungRadiationCourses)
            %obj = DatabasePatient(dPrimaryId, dAge, eGender, voDiagnoses, voBrainRadiationCourses, voLungRadiationCourses)
            obj.dPrimaryId = dPrimaryId;
            obj.dAge = dAge;
            obj.eGender = eGender;
            obj.voDiagnoses = voDiagnoses;
            obj.voBrainRadiationCourses = RadiationCourse.SortCoursesByDate(voBrainRadiationCourses);
            obj.voLungRadiationCourses = RadiationCourse.SortCoursesByDate(voLungRadiationCourses);
        end
        
        function Update(obj)
            % update contained objects
        end
        
        function oImageVolume = LoadImageVolume(obj, sIMGPPLoadCode, dBMNumber)
            arguments
                obj
                sIMGPPLoadCode (1,1) string
                dBMNumber double {ValidationUtils.MustBeEmptyOrScalar(dBMNumber)} = [] 
            end
            
            % get filename
            if isempty(dBMNumber)
                sBMSpecifier = "";
            else
                sBMSpecifier = " (BM " + string(StringUtils.num2str_PadWithZeros(dBMNumber,2)) + ")";
            end
            
            sFilename = sIMGPPLoadCode + sBMSpecifier+ ".mat";
            
            % get folder
            sPatientRoot = obj.GetDicomDatabaseRootPath();
            sPatientRoot = strrep(sPatientRoot, Experiment.GetDataPath('DicomImagingDatabase'), Experiment.GetDataPath('ProcessedImagingDatabase'));
            
            vsCodeParts = strsplit(sIMGPPLoadCode, "-");
            
            switch vsCodeParts(2)
                case "001"                    
                    sImageFolder = obj.GetFirstBrainRadiationCourseTreatmentPlan().GetCTSimDicomFolderPath();
                case "002"
                    sImageFolder = obj.GetFirstBrainRadiationCourseTreatmentPlan().GetT1PostContrastMRIDicomFolderPath();
                otherwise
                    error(...
                        'DatabasePatient:LoadImageVolume:InvalidCode',...
                        'Invalid IMGPP code');
            end
            
            % load
            oImageVolume = ImageVolume.Load(fullfile(sPatientRoot, sImageFolder, sFilename));
        end
        
        function oROIs = LoadRegionsOfInterest(obj, sROIPPLoadCode, dBMNumber)
            arguments
                obj
                sROIPPLoadCode (1,1) string
                dBMNumber double {ValidationUtils.MustBeEmptyOrScalar(dBMNumber)} = [] 
            end
            
            % get filename
            if isempty(dBMNumber)
                sBMSpecifier = "";
            else
                sBMSpecifier = " (BM " + string(StringUtils.num2str_PadWithZeros(dBMNumber,2)) + ")";
            end
            
            sFilename = sROIPPLoadCode + sBMSpecifier+ ".mat";
            
            % get folder
            sPatientRoot = obj.GetDicomDatabaseRootPath();
            sPatientRoot = strrep(sPatientRoot, Experiment.GetDataPath('DicomImagingDatabase'), Experiment.GetDataPath('ProcessedImagingDatabase'));
            
            sRTStructFolder = FileIOUtils.SeparateFilePathAndFilename(obj.GetFirstBrainRadiationCourseTreatmentPlan().GetRTStructDicomFilePath());
            
            % load
            oROIs = RegionsOfInterest.Load(fullfile(sPatientRoot, sRTStructFolder, sFilename));            
        end
        
        function SetFirstBrainRadiationCourseTreatmentPlan(obj, oTreatmentPlan)
            arguments
                obj (1,1) DatabasePatient
                oTreatmentPlan (1,1) BrainRadiationTreatmentPlan
            end
            
            if ~isempty(obj.oFirstBrainRadiationCourseTreatmentPlan)
                warning(...
                    'DatabasePatient:SetFirstBrainRadiationCourseTreatmentPlan:AlreadySet',...
                    'The first brain radiation course is set');
            end
            
            obj.oFirstBrainRadiationCourseTreatmentPlan = oTreatmentPlan;
        end
        
        function SetImagingStudies(obj, voDatabaseImagingStudies)
            %setImagingStudies(obj, voDatabaseImagingStudies)
            obj.voDatabaseImagingStudies = voDatabaseImagingStudies;
        end
        
        function sPath = GetPreTreatmentDicomDatabasePath(obj)
            sDicomPath = Experiment.GetDataPath("DicomImagingDatabase");
            
            sPatientDirectory = DicomImporter.GetDicomDatabasePatientFolderNameForPatientId(obj.dPrimaryId);
            
            sPath = fullfile(sDicomPath, sPatientDirectory, DicomImporter.chDicomDatabasePreTreatmentFolderName);
        end
        
        function sPrimaryIdString = GetPrimaryIdString(obj)
            sPrimaryIdString = string(StringUtils.num2str_PadWithZeros(obj.dPrimaryId, DatabasePatient.dPrimaryIdStringNumberOfDigits));
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dPrimaryId = GetPrimaryId(obj)
            dPrimaryId = obj.dPrimaryId;
        end
        
        function dAge = GetAge(obj)
            dAge = obj.dAge;
        end
        
        function eGender = GetGender(obj)
            eGender = obj.eGender;
        end
        
        function voDiagnoses = GetDiagnoses(obj)
            voDiagnoses = obj.voDiagnoses;
        end
        
        function voCourses = GetBrainRadiationCourses(obj)
            voCourses = obj.voBrainRadiationCourses;
        end
        
        function oCourse = GetFirstBrainRadiationCourse(obj)
            voCourses = obj.GetBrainRadiationCoursesSortedByDate();
            
            oCourse = voCourses(1);
        end
        
        function voCourses = GetBrainRadiationCoursesSortedByDate(obj)
            voCourses = obj.voBrainRadiationCourses;
            dNumCourses = length(voCourses);
            
            vdtCourseDates = NaT(1, dNumCourses);
            
            for dCourseIndex=1:dNumCourses
                vdtCourseDates(dCourseIndex) = voCourses(dCourseIndex).GetRadiationCourseDate();
            end
            
            [~, vdSortIndices] = sort(vdtCourseDates, 'ascend');
            
            voCourses = voCourses(vdSortIndices);
        end
        
        function voCourses = GetLungRadiationCourses(obj)
            voCourses = obj.voLungRadiationCourses;
        end
        
        function voCourses = GetLungRadiationCoursesSortedByDate(obj)
            voCourses = obj.voLungRadiationCourses;
            dNumCourses = length(voCourses);
            
            vdtCourseDates = NaT(1, dNumCourses);
            
            for dCourseIndex=1:dNumCourses
                vdtCourseDates(dCourseIndex) = voCourses(dCourseIndex).GetRadiationCourseDate();
            end
            
            [~, vdSortIndices] = sort(vdtCourseDates, 'ascend');
            
            voCourses = voCourses(vdSortIndices);
        end
        
        function oTreatmentPlan = GetFirstBrainRadiationCourseTreatmentPlan(obj)
            oTreatmentPlan = obj.oFirstBrainRadiationCourseTreatmentPlan;
        end
        
        function CreateBrainMetastasisMap(obj, sMapTemplateFolder, sDicomDatabasePath)
            obj.CreateBrainMetastasisMap_private(sMapTemplateFolder, sDicomDatabasePath);
        end
                         
        function sPath = GetDicomDatabaseRootPath(obj)
            sPath = string(fullfile(Experiment.GetDataPath('DicomImagingDatabase'), DicomImporter.GetDicomDatabasePatientFolderNameForPatientId(obj.dPrimaryId)));
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function CreateREDCapImportFile(voPatients, sImportTemplatePath, sSavePath)
            arguments
                voPatients (:,1) DatabasePatient
                sImportTemplatePath (1,1) string
                sSavePath (1,1) string
            end
            
            c2xData = readcell(sImportTemplatePath);
            
            vsRowLabels = string(c2xData(:,1));
            
            dColInsertIndex = 2;
            
            for dPatientIndex=1:length(voPatients)
                oPatient = voPatients(dPatientIndex);
                
                
                % Aria Disease Diagnosis
                for dDiagnosisIndex=1:length(oPatient.voDiagnoses)
                    oDiagnosis = oPatient.voDiagnoses(dDiagnosisIndex);
                    
                    c2xData{vsRowLabels == "study_id", dColInsertIndex} = oPatient.GetPrimaryId();
                    c2xData{vsRowLabels == "redcap_repeat_instrument", dColInsertIndex} = "aria_disease_diagnosis";
                    c2xData{vsRowLabels == "redcap_repeat_instance", dColInsertIndex} = dDiagnosisIndex;
                    
                    c2xData{vsRowLabels == "diagnosis_date", dColInsertIndex} = datestr(oDiagnosis.GetDiagnosisDate(), 'yyyy-mm-dd');
                    c2xData{vsRowLabels == "diagnosis_icd_code", dColInsertIndex} = oDiagnosis.GetDiseaseSiteCode();
                    c2xData{vsRowLabels == "diagnosis_icd_description", dColInsertIndex} = oDiagnosis.GetDiseaseSiteDescription();
                    
                    c2xData{vsRowLabels == "aria_disease_diagnosis_complete", dColInsertIndex} = 2;
                    
                    dColInsertIndex = dColInsertIndex + 1;
                end
                
                
                % Brain RT course
                voBrainRTCourses = oPatient.GetBrainRadiationCoursesSortedByDate();
                
                for dBrainRTIndex=1:length(voBrainRTCourses)
                    oCourse = voBrainRTCourses(dBrainRTIndex);
                    
                    c2xData{vsRowLabels == "study_id", dColInsertIndex} = oPatient.GetPrimaryId();
                    c2xData{vsRowLabels == "redcap_repeat_instrument", dColInsertIndex} = "brain_radiation_course";
                    c2xData{vsRowLabels == "redcap_repeat_instance", dColInsertIndex} = dBrainRTIndex;
                    
                    c2xData{vsRowLabels == "brain_rt_course_date", dColInsertIndex} = datestr(oCourse.GetRadiationCourseDate(), 'yyyy-mm-dd');
                    c2xData{vsRowLabels == "brain_rt_course_intent", dColInsertIndex} = oCourse.GetIntent().GetREDCapCoding();
                    
                    % - first brain RT has more information (e.g. is the
                    % treatment which we are studying), all other brain RT is
                    % "salvage"
                    if dBrainRTIndex == 1
                        c2xData{vsRowLabels == "brain_rt_course_number_of_bms_treated", dColInsertIndex} = oPatient.oFirstBrainRadiationCourseTreatmentPlan.GetNumberOfTargetedBrainMetastases();
                        [~, vdBeamSetPrescribedDoses_Gy, vdBeamSetPrescribedFractions, c1vdBMsTargeted] = oPatient.oFirstBrainRadiationCourseTreatmentPlan.GetAllBeamSetData();
                        
                        c2xData{vsRowLabels == "brain_rt_course_number_of_beam_sets", dColInsertIndex} = length(vdBeamSetPrescribedDoses_Gy);
                        
                        for dBeamSetIndex=1:length(vdBeamSetPrescribedDoses_Gy)
                            c2xData{vsRowLabels == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_prescribed_dose_gy", dColInsertIndex} = sprintf('%3.1f', vdBeamSetPrescribedDoses_Gy(dBeamSetIndex));
                            c2xData{vsRowLabels == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_fractions_prescribed", dColInsertIndex} = vdBeamSetPrescribedFractions(dBeamSetIndex);
                            c2xData{vsRowLabels == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_targeted_bms", dColInsertIndex} = strjoin("BM " + string(c1vdBMsTargeted{dBeamSetIndex}), ", ");
                        end
                    else
                        c2xData{vsRowLabels == "brain_rt_course_number_of_beam_sets", dColInsertIndex} = oCourse.GetNumberOfRadiationCoursePortions();
                        voPortions = oCourse.GetRadiationCoursePortions(); % "portions" = "beam sets"
                        
                        for dPortionIndex=1:length(voPortions)
                            oPortion = voPortions(dPortionIndex);
                            
                            c2xData{vsRowLabels == "brain_rt_course_beamset" + string(dPortionIndex) + "_calculated_dose_gy", dColInsertIndex} = sprintf('%0.1f', round(oPortion.GetDose_Gy(),1)); % round to 1 decimal place
                            c2xData{vsRowLabels == "brain_rt_course_beamset" + string(dPortionIndex) + "_fractions_prescribed", dColInsertIndex} = oPortion.GetNumberOfFractionsPrescribed();
                        end
                    end
                    
                    c2xData{vsRowLabels == "brain_radiation_course_complete", dColInsertIndex} = 2;
                    
                    dColInsertIndex = dColInsertIndex + 1;
                end
                
                
                % Lung RT course
                voLungRTCourses = oPatient.GetLungRadiationCoursesSortedByDate();
                
                for dLungRTIndex=1:length(voLungRTCourses)
                    oCourse = voLungRTCourses(dLungRTIndex);
                    
                    c2xData{vsRowLabels == "study_id", dColInsertIndex} = oPatient.GetPrimaryId();
                    c2xData{vsRowLabels == "redcap_repeat_instrument", dColInsertIndex} = "lung_radiation_course";
                    c2xData{vsRowLabels == "redcap_repeat_instance", dColInsertIndex} = dLungRTIndex;
                    
                    c2xData{vsRowLabels == "lung_rt_course_date", dColInsertIndex} = datestr(oCourse.GetRadiationCourseDate(), 'yyyy-mm-dd');
                    c2xData{vsRowLabels == "lung_rt_course_intent", dColInsertIndex} = oCourse.GetIntent().GetREDCapCoding();
                    c2xData{vsRowLabels == "lung_rt_course_number_of_beam_sets", dColInsertIndex} = oCourse.GetNumberOfRadiationCoursePortions();
                    
                    voPortions = oCourse.GetRadiationCoursePortions(); % "portions" = "beam sets"
                    
                    for dPortionIndex=1:length(voPortions)
                        oPortion = voPortions(dPortionIndex);
                        
                        c2xData{vsRowLabels == "lung_rt_course_beamset" + string(dPortionIndex) + "_site", dColInsertIndex} = oPortion.GetLungRadiationSite().GetREDCapCoding();
                        c2xData{vsRowLabels == "lung_rt_course_beamset" + string(dPortionIndex) + "_calculated_dose_gy", dColInsertIndex} = sprintf('%0.1f', round(oPortion.GetDose_Gy(),1)); % round to 1 decimal place
                        c2xData{vsRowLabels == "lung_rt_course_beamset" + string(dPortionIndex) + "_fractions_prescribed", dColInsertIndex} = oPortion.GetNumberOfFractionsPrescribed();
                    end
                    
                    c2xData{vsRowLabels == "lung_radiation_course_complete", dColInsertIndex} = 2;
                    
                    dColInsertIndex = dColInsertIndex + 1;
                end
                
                
                % Pre-Treatment Radiology Scan Date
                sPatientDicomRootPath = oPatient.GetDicomDatabaseRootPath();
                sT1PostMRSeriesPath = oPatient.oFirstBrainRadiationCourseTreatmentPlan.GetT1PostContrastMRIDicomFolderPath();
                stMetadata = dicominfo(fullfile(sPatientDicomRootPath, sT1PostMRSeriesPath, "MR000000.dcm"));
                oStudyDate = datetime(str2double(stMetadata.StudyDate(1:4)), str2double(stMetadata.StudyDate(5:6)), str2double(stMetadata.StudyDate(7:8)));
                
                c2xData{vsRowLabels == "study_id", dColInsertIndex} = oPatient.GetPrimaryId();
                c2xData{vsRowLabels == "brain_radiology_pretreatment_date", dColInsertIndex} = string(datestr(oStudyDate, 'yyyy-mm-dd'));
                c2xData{vsRowLabels == "brain_radiology_pretreatment_complete", dColInsertIndex} = 0;
                
                dColInsertIndex = dColInsertIndex + 1;
            end
            
            % add "Record" headings
            c2xData(1,2:end) = {"Record"};
            
            % save to disk
            for dIndex=1:numel(c2xData)
                if ismissing(c2xData{dIndex})
                    c2xData{dIndex} = [];
                end
            end
            
            writecell(c2xData, sSavePath, 'Delimiter', 'comma');
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function CreateBrainMetastasisMap_private(obj, sMapTemplateFolder, sDicomDatabasePath)
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            sPatientDicomRootPath = fullfile(sDicomDatabasePath, DicomImporter.GetDicomDatabasePatientFolderNameForPatientId(obj.dPrimaryId));
            
            sT1PostMRSeriesPath = fullfile(sPatientDicomRootPath, obj.oFirstBrainRadiationCourseTreatmentPlan.GetT1PostContrastMRIDicomFolderPath());
            sCTSimSeriesPath = fullfile(sPatientDicomRootPath, obj.oFirstBrainRadiationCourseTreatmentPlan.GetCTSimDicomFolderPath());
            sRegistrationFilePath = fullfile(sPatientDicomRootPath, obj.oFirstBrainRadiationCourseTreatmentPlan.GetT1PostContrastMRIToCTSimRegistrationDicomFilePath());
            sRTStructFilePath = fullfile(sPatientDicomRootPath, obj.oFirstBrainRadiationCourseTreatmentPlan.GetRTStructDicomFilePath());
            
            oCTSimWithROIs = DicomImageVolume(fullfile(sCTSimSeriesPath, "CT000000.dcm"), sRTStructFilePath);
            oROIs = oCTSimWithROIs.GetRegionsOfInterest();
            oT1PostMR = DicomImageVolume(fullfile(sT1PostMRSeriesPath, "MR000000.dcm"));
            
            vsROINamesFromRTStruct = oROIs.GetRegionsOfInterestNames();
            vsBrainMetROINames = obj.oFirstBrainRadiationCourseTreatmentPlan.GetRegionOfInterestNamePerTargetedBrainMetastasis();
            dNumBrainMets = length(vsBrainMetROINames);
            
            vdROIsToSelect = zeros(dNumBrainMets,1);
            
            for dBrainMetIndex=1:dNumBrainMets
                vdROIsToSelect(dBrainMetIndex) = find(vsROINamesFromRTStruct == vsBrainMetROINames(dBrainMetIndex));
            end
            
            if any(vdROIsToSelect == 0)
                error(...
                    'DatabasePatient:CreateBrainMetastasisMap_private:ROINotFound',...
                    'At least one brain met ROI name not found in the RT struct.');
            end
            
            oROIs.SelectRegionsOfInterest(vdROIsToSelect);
            
            m2dTransformMatrix = RigidTransform.GetAffineTransformMatrixFromDicomRegFile(sRegistrationFilePath);
            
            if obj.oFirstBrainRadiationCourseTreatmentPlan.IsMRT1wPostContrastRegistrationOntoMR()
                m2dTransformMatrix = inv(m2dTransformMatrix);
            end            
            
            oT1PostMR.PerformRigidTransform(m2dTransformMatrix);
            oT1PostMR.InterpolateOntoTargetGeometry(oCTSimWithROIs.GetImageVolumeGeometry(), "linear", 0);
            oT1PostMR.SetRegionsOfInterest(oROIs);
            
            oT1PostMR.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            
            oApp = oT1PostMR.View();
            
            sTemplateFilename = "Brain Met Map Template (" + string(dNumBrainMets) + " BMs).dotx";
            
            chMapFilename = ['PT', char(obj.GetPrimaryIdString()), ' Brain Mets Map'];
            chMapFilePath = fullfile(Experiment.GetResultsDirectory(), chMapFilename);
            
            oDoc = Document(chMapFilePath, 'docx', fullfile(sMapTemplateFolder, sTemplateFilename));
            
            oIVH = FeatureExtractionImageVolumeHandler(oT1PostMR, "Test", "GroupIds", int8(1));
            
            sSeriesDescription = oT1PostMR.GetFileMetadata().SeriesDescription;
            oStudyDate = datetime(str2double(oT1PostMR.GetFileMetadata().StudyDate(1:4)), str2double(oT1PostMR.GetFileMetadata().StudyDate(5:6)), str2double(oT1PostMR.GetFileMetadata().StudyDate(7:8)));
            
            for dBrainMetIndex=1:dNumBrainMets
                oDoc.moveToNextHole();
                oDoc.append(Text(num2str(obj.GetPrimaryIdString())));
                
                oDoc.moveToNextHole();
                append(oDoc, Text(sSeriesDescription));
                
                oDoc.moveToNextHole();
                append(oDoc, Text(datestr(oStudyDate, "mmm dd, yyyy")));
                
                oDoc.moveToNextHole();
                append(oDoc, Text(vsBrainMetROINames(dBrainMetIndex)));
                
                oApp.CentreOnRegionOfInterest(dBrainMetIndex);
                oView = oApp.GetCurrentImageVolumeView();
                
                [~,oFOV2D1] = oT1PostMR.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(dBrainMetIndex, ImagingPlaneTypes.Sagittal);
                [~,oFOV2D2] = oT1PostMR.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(dBrainMetIndex, ImagingPlaneTypes.Coronal);
                [~,oFOV2D3] = oT1PostMR.GetRegionsOfInterest().GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(dBrainMetIndex, ImagingPlaneTypes.Axial);
                
                oFOV2D1 = ImageVolumeFieldOfView2D(oFOV2D1.vdFieldOfViewCentreCoordinates_mm, 200, 200);
                oFOV2D2 = ImageVolumeFieldOfView2D(oFOV2D2.vdFieldOfViewCentreCoordinates_mm, 200, 200);
                oFOV2D3 = ImageVolumeFieldOfView2D(oFOV2D3.vdFieldOfViewCentreCoordinates_mm, 200, 200);
                
                voPlaneFieldsOfView2D = [oFOV2D1, oFOV2D2, oFOV2D3];
                
                oView = ImageVolumeViewRecord(...
                    oView.vdAnatomicalPlaneIndices,...
                    voPlaneFieldsOfView2D,...
                    oView.vdImageDataDisplayThreshold);
                
                oIVH.SetRepresentativeFieldsOfViewForExtractionIndex(dBrainMetIndex, oView);
                
                
                hAxFig = figure();
                hAxes = axes;
                
                vdPosition = hAxFig.Position;
                vdPosition(3:4) = 500;
                hAxFig.Position = vdPosition;
                
                hAxes.Position = [0 0 1 1];
                
                oIVH.RenderRepresentativeImageOnAxesByExtractionIndex(hAxes, dBrainMetIndex, 'ForceImagingPlaneType', ImagingPlaneTypes.Axial, 'LineWidth', 2, 'ShowAllRegionsOfInterest', false);
                
                hAxes.Color = 'k';
                axis('on');
                xticks([]);
                yticks([]);
                
                text(hAxes, 0,0.5,' R',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','left');
                text(hAxes, 1,0.5,'L ',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','right');
                text(hAxes, 0.5,0,'P',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','center', 'VerticalAlignment', 'bottom');
                text(hAxes, 0.5,1,'A',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','center', 'VerticalAlignment', 'top');
                
                
                hSagFig = figure();
                hAxes = axes;
                
                vdPosition = hSagFig.Position;
                vdPosition(3:4) = 500;
                hSagFig.Position = vdPosition;
                
                hAxes.Position = [0 0 1 1];
                
                oIVH.RenderRepresentativeImageOnAxesByExtractionIndex(hAxes, dBrainMetIndex, 'ForceImagingPlaneType', ImagingPlaneTypes.Sagittal, 'LineWidth', 2, 'ShowAllRegionsOfInterest', false);
                
                hAxes.Color = 'k';
                axis('on');
                xticks([]);
                yticks([]);
                
                text(hAxes, 0,0.5,' A',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','left');
                text(hAxes, 1,0.5,'P ',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','right');
                text(hAxes, 0.5,0,'I',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','center', 'VerticalAlignment', 'bottom');
                text(hAxes, 0.5,1,'S',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','center', 'VerticalAlignment', 'top');
                
                
                hCorFig = figure();
                hAxes = axes;
                
                vdPosition = hCorFig.Position;
                vdPosition(3:4) = 500;
                hCorFig.Position = vdPosition;
                
                hAxes.Position = [0 0 1 1];
                
                oIVH.RenderRepresentativeImageOnAxesByExtractionIndex(hAxes, dBrainMetIndex, 'ForceImagingPlaneType', ImagingPlaneTypes.Coronal, 'LineWidth', 2, 'ShowAllRegionsOfInterest', false);
                
                hAxes.Color = 'k';
                axis('on');
                xticks([]);
                yticks([]);
                
                text(hAxes, 0,0.5,' R',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','left');
                text(hAxes, 1,0.5,'L ',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','right');
                text(hAxes, 0.5,0,'I',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','center', 'VerticalAlignment', 'bottom');
                text(hAxes, 0.5,1,'S',"Color",'w',"Units",'normalized','FontSize',20,'HorizontalAlignment','center', 'VerticalAlignment', 'top');
                
                hAxFig.InvertHardcopy = 'off';
                hSagFig.InvertHardcopy = 'off';
                hCorFig.InvertHardcopy = 'off';
                
                chGTVFilenamePrefix = ['GTV ', num2str(dBrainMetIndex), ' - '];
                
                chAxialPngFilePath = fullfile(Experiment.GetResultsDirectory(), [chGTVFilenamePrefix, 'Axial Slice.png']);
                chSagPngFilePath = fullfile(Experiment.GetResultsDirectory(), [chGTVFilenamePrefix, 'Sagittal Slice.png']);
                chCorPngFilePath = fullfile(Experiment.GetResultsDirectory(), [chGTVFilenamePrefix, 'Coronal Slice.png']);
                
                saveas(hAxFig, chAxialPngFilePath);
                saveas(hSagFig, chSagPngFilePath);
                saveas(hCorFig, chCorPngFilePath);
                
                chAxialFigFilePath = fullfile(Experiment.GetResultsDirectory(), [chGTVFilenamePrefix, 'Axial Slice.fig']);
                chSagFigFilePath = fullfile(Experiment.GetResultsDirectory(), [chGTVFilenamePrefix, 'Sagittal Slice.fig']);
                chCorFigFilePath = fullfile(Experiment.GetResultsDirectory(), [chGTVFilenamePrefix, 'Coronal Slice.fig']);
                
                savefig(hAxFig, chAxialFigFilePath);
                savefig(hSagFig, chSagFigFilePath);
                savefig(hCorFig, chCorFigFilePath);
                
                delete(hAxFig);
                delete(hSagFig);
                delete(hCorFig);
                
                oDoc.moveToNextHole();
                oImage = Image(chAxialPngFilePath);
                oImage.Height = "9cm";
                oImage.Width = "9cm";
                oDoc.append(oImage);
                
                oDoc.moveToNextHole();
                oImage = Image(chSagPngFilePath);
                oImage.Height = "9cm";
                oImage.Width = "9cm";
                oDoc.append(oImage);
                
                oDoc.moveToNextHole();
                oImage = Image(chCorPngFilePath);
                oImage.Height = "9cm";
                oImage.Width = "9cm";
                oDoc.append(oImage);
            end
            
            close(oDoc);
            
            docview(chMapFilePath,'convertdocxtopdf','closeapp');
            
            copyfile(...
                [chMapFilePath, '.pdf'],...
                fullfile(Experiment.GetDataPath('BrainMetMapDirectory'), [chMapFilename, '.pdf']));
            
            delete(oApp);
        end
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
