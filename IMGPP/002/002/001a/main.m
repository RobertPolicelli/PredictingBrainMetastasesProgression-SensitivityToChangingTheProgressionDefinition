oDB = ExperimentManager.Load('DB-006-004');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdUniquePatientIds = unique(vdPatientIds);

vdBMNumbers = m2dSampleIds(:,2);

sIMGPPLoadCode = "IMGPP-002-002-000a";
sIMGPPSaveCode = "IMGPP-002-002-001a";

bForceApplyTransforms = false;

for dPatientIndex=1:length(vdUniquePatientIds)
    try
        dPatientId = vdUniquePatientIds(dPatientIndex);
        disp(dPatientId);
        
        oPatient = oDB.GetPatientByPrimaryId(dPatientId);
        
        vdBMNumbersForPatient = vdBMNumbers(vdPatientIds == dPatientId);
        
        for dBMIndex=1:length(vdBMNumbersForPatient)
            dBMNumber = vdBMNumbersForPatient(dBMIndex);
                        
            oIV = oPatient.LoadImageVolume(sIMGPPLoadCode, dBMNumber);            
            chOriginalDataType = class(oIV.GetImageData());
            
            oIV.InterpolateToIsotropicVoxelResolution(0.5, 'linear', 0);
            oIV.CastImageDataToType(chOriginalDataType);
            oIV.ForceApplyAllTransforms();
                            
            sT1PostContrastDicomFolderPath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetT1PostContrastMRIDicomFolderPath();
            sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');            
            sIMGPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, sT1PostContrastDicomFolderPath);
            
            FileIOUtils.MkdirIfItDoesNotExist(sIMGPPPath);
            
            oIV.Save(fullfile(sIMGPPPath, sIMGPPSaveCode + " (BM " + string(StringUtils.num2str_PadWithZeros(dBMNumber, 2)) + ").mat"), bForceApplyTransforms, '-v7','-nocompression');          
        end        
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end