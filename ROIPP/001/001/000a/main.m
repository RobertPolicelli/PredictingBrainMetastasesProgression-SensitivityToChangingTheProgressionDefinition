oDB = ExperimentManager.Load('DB-006-003');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdPatientIds = unique(vdPatientIds);

sROIPPCode = "ROIPP-001-001-000a";

bForceApplyTransforms = false;
bAppend = false;

for dPatientIndex=35%1:length(vdPatientIds)
    try
        disp(vdPatientIds(dPatientIndex));
        
        oPatient = oDB.GetPatientByPrimaryId(vdPatientIds(dPatientIndex));
        
        sCTSimDicomFolderPath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetCTSimDicomFolderPath();
        sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');
        sIMGPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, sCTSimDicomFolderPath);
        oCTSim = ImageVolume.Load(fullfile(sIMGPPPath, '\IMGPP-001-001-000.mat'));
        
        sRTStructDicomFilePath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetRTStructDicomFilePath();
%         oRTStruct = DicomRTStructLabelMapRegionsOfInterest(...
%             fullfile(oPatient.GetDicomDatabaseRootPath(), sRTStructDicomFilePath),...
%             oCTSim);
        oRTStruct = DicomRTStructLabelMapRegionsOfInterest(...
            "E:\Users\rpolicelli_nobackup\Brain Project\Data\Imaging\Dicom Database\BRAIN METS SRS SRT 0188 BRAIN METS SRS SRT 0188\BRAI3\RTSTRUCT RS Unapproved Structure Set\RT000000.dcm",...
            oCTSim);        
        sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');
        
        sROIPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, FileIOUtils.SeparateFilePathAndFilename(sRTStructDicomFilePath));
        
        mkdir(sROIPPPath);
        
        oRTStruct.Save(fullfile(sROIPPPath, sROIPPCode + ".mat"), bForceApplyTransforms, bAppend, '-v7','-nocompression');
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end