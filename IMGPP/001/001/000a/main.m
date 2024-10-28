oDB = ExperimentManager.Load('DB-006-003');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdPatientIds = unique(vdPatientIds);

sIMGPPCode = "IMGPP-001-001-000";
bForceApplyTransforms = false;

for dPatientIndex=1:length(vdPatientIds)
    try
        disp(vdPatientIds(dPatientIndex));
        
        oPatient = oDB.GetPatientByPrimaryId(vdPatientIds(dPatientIndex));
        
        sCTSimDicomFolderPath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetCTSimDicomFolderPath();
        
        oImageVolume = DicomImageVolume(fullfile(oPatient.GetDicomDatabaseRootPath(), sCTSimDicomFolderPath, 'CT000000.dcm'));
        
        sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');
        
        sIMGPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, sCTSimDicomFolderPath);
        
        mkdir(sIMGPPPath);
        
        [~,chSeriesName] = FileIOUtils.SeparateFilePathAndFilename(sCTSimDicomFolderPath);
        
        oImageVolume.Save(fullfile(sIMGPPPath, sIMGPPCode + ".mat"), bForceApplyTransforms, '-v7','-nocompression');
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end