oDB = ExperimentManager.Load('DB-006-004');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-001-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdUniquePatientIds = unique(vdPatientIds);

vdBMNumbers = m2dSampleIds(:,2);

sIMGPPLoadCode = "IMGPP-002-001-000";
sROIPPLoadCode = "ROIPP-002-001-000";

sROIPPSaveCode = "ROIPP-002-002-000";

bForceApplyTransforms = false;
bAppend = false;

dCropBuffer_mm = 25;

for dPatientIndex=1:length(vdUniquePatientIds)
    try
        dPatientId = vdUniquePatientIds(dPatientIndex);
        
        oPatient = oDB.GetPatientByPrimaryId(dPatientId);
        
        oIV = oPatient.LoadImageVolume(sIMGPPLoadCode);
        oROIs = oPatient.LoadRegionsOfInterest(sROIPPLoadCode);
        
        vdBMNumbersForPatient = vdBMNumbers(vdPatientIds == dPatientId);
        
        if oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetNumberOfTargetedBrainMetastases() ~= length(vdBMNumbersForPatient)
            vdBMsToProcess = 1:oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetNumberOfTargetedBrainMetastases();
            
            vbRemove = false(size(vdBMsToProcess));
            
            for dBMIndex=1:length(vdBMsToProcess)
                if any(vdBMsToProcess(dBMIndex) == vdBMNumbersForPatient)
                    vbRemove(dBMIndex) = true;
                end
            end
            
            vdBMNumbersForPatient = vdBMsToProcess(~vbRemove);
            
            disp("Patient " + string(dPatientId) + ": " + strjoin(string(vdBMNumbersForPatient),', '));
            
            for dBMIndex=1:length(vdBMNumbersForPatient)
                dBMNumber = vdBMNumbersForPatient(dBMIndex);
                sROIName = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetRegionOfInterestNameByTargetedBrainMetastasisNumber(dBMNumber);
                
                dROINumber = oROIs.GetRegionOfInterestNumberByRegionOfInterestName(sROIName);
                
                [vdRowBounds, vdColBounds, vdSliceBounds] = oROIs.GetMinimalBoundsByRegionOfInterestNumber(dROINumber);
                
                vdVoxelDimensions_mm = oIV.GetImageVolumeGeometry().GetVoxelDimensions_mm();
                vdVolumeDimensions = oIV.GetImageVolumeGeometry().GetVolumeDimensions();
                
                vdNumBufferVoxelsPerDim = ceil(dCropBuffer_mm ./ vdVoxelDimensions_mm);
                
                vdRowCropBounds = vdRowBounds + [-1 1] * vdNumBufferVoxelsPerDim(1);
                vdColCropBounds = vdColBounds + [-1 1] * vdNumBufferVoxelsPerDim(2);
                vdSliceCropBounds = vdSliceBounds + [-1 1] * vdNumBufferVoxelsPerDim(3);
                
                vdRowCropBounds(vdRowCropBounds < 1) = 1;
                vdRowCropBounds(vdRowCropBounds > vdVolumeDimensions(1)) = vdVolumeDimensions(1);
                
                vdColCropBounds(vdColCropBounds < 1) = 1;
                vdColCropBounds(vdColCropBounds > vdVolumeDimensions(2)) = vdVolumeDimensions(2);
                
                vdSliceCropBounds(vdSliceCropBounds < 1) = 1;
                vdSliceCropBounds(vdSliceCropBounds > vdVolumeDimensions(3)) = vdVolumeDimensions(3);
                
                oROIsCrop = copy(oROIs);
                
                oROIsCrop.Crop(vdRowCropBounds, vdColCropBounds, vdSliceCropBounds);
                oROIsCrop.ForceApplyAllTransforms();
                
                oROIsCrop.SelectRegionsOfInterest(dROINumber);
                
                sRTStructDicomFolderPath = FileIOUtils.SeparateFilePathAndFilename(oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetRTStructDicomFilePath());
                sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');
                sROIPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, sRTStructDicomFolderPath);
                
                FileIOUtils.MkdirIfItDoesNotExist(sROIPPPath);
                
                oROIsCrop.Save(fullfile(sROIPPPath, sROIPPSaveCode + " (BM " + string(StringUtils.num2str_PadWithZeros(dBMNumber, 2)) + ").mat"), bForceApplyTransforms, bAppend, '-v7','-nocompression');
            end
        end
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end