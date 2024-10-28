oDB = ExperimentManager.Load('DB-006-004');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-001-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdUniquePatientIds = unique(vdPatientIds);

vdBMNumbers = m2dSampleIds(:,2);

sROIPPLoadCode = "ROIPP-002-002-000";
sROIPPSaveCode = "ROIPP-002-002-001";

bForceApplyTransforms = false;
bAppend = false;

for dPatientIndex=1:length(vdUniquePatientIds)
    try
        dPatientId = vdUniquePatientIds(dPatientIndex);
        disp(dPatientId);
        
        oPatient = oDB.GetPatientByPrimaryId(dPatientId);
        
        vdBMNumbersForPatient = vdBMNumbers(vdPatientIds == dPatientId);
        
        for dBMIndex=1:length(vdBMNumbersForPatient)
            dBMNumber = vdBMNumbersForPatient(dBMIndex);
                        
            oROI = oPatient.LoadRegionsOfInterest(sROIPPLoadCode, dBMNumber);  
            
            oROI.InterpolateToIsotropicVoxelResolution(0.5, 'interpolate3D', 'linear');
            oROI.ForceApplyAllTransforms();
                            
            sRTStructDicomFolderPath = FileIOUtils.SeparateFilePathAndFilename(oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetRTStructDicomFilePath());
            sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');            
            sROIPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, sRTStructDicomFolderPath);
            
            FileIOUtils.MkdirIfItDoesNotExist(sROIPPPath);
            
            oROI.Save(fullfile(sROIPPPath, sROIPPSaveCode + " (BM " + string(StringUtils.num2str_PadWithZeros(dBMNumber, 2)) + ").mat"), bForceApplyTransforms, bAppend, '-v7','-nocompression');          
        end        
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end