oDB = ExperimentManager.Load('DB-006-003');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdPatientIds = unique(vdPatientIds);

sIMGPPCode = "IMGPP-002-001-000a";
bForceApplyTransforms = false;

for dPatientIndex=1:length(vdPatientIds)
    try
        disp(vdPatientIds(dPatientIndex));
        
        oPatient = oDB.GetPatientByPrimaryId(vdPatientIds(dPatientIndex));
        
        sT1PostContrastDicomFolderPath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetT1PostContrastMRIDicomFolderPath();
        
        oImageVolume = DicomImageVolume(fullfile(oPatient.GetDicomDatabaseRootPath(), sT1PostContrastDicomFolderPath, 'MR000000.dcm'));
        
        sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');
        
        sIMGPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, sT1PostContrastDicomFolderPath);
        
        mkdir(sIMGPPPath);
        
        [~,chSeriesName] = FileIOUtils.SeparateFilePathAndFilename(sT1PostContrastDicomFolderPath);Image
        
        oImageVolume.Save(fullfile(sIMGPPPath, sIMGPPCode + ".mat"), bForceApplyTransforms, '-v7','-nocompression');
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end