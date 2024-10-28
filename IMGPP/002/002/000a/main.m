oDB = ExperimentManager.Load('DB-006-003');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdUniquePatientIds = unique(vdPatientIds);

vdBMNumbers = m2dSampleIds(:,2);

sIMGPPLoadCode = "IMGPP-002-001-000a";
sROIPPLoadCode = "ROIPP-002-001-000a";

sIMGPPSaveCode = "IMGPP-002-002-000a";

bForceApplyTransforms = false;

dCropBuffer_mm = 25;

for dPatientIndex=1:length(vdUniquePatientIds)
    try
        dPatientId = vdUniquePatientIds(dPatientIndex);
        disp(dPatientId);
        
        oPatient = oDB.GetPatientByPrimaryId(dPatientId);
        
        oIV = oPatient.LoadImageVolume(sIMGPPLoadCode);
        oROIs = oPatient.LoadRegionsOfInterest(sROIPPLoadCode);
        
        vdBMNumbersForPatient = vdBMNumbers(vdPatientIds == dPatientId);
        
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
            
            oIVCrop = copy(oIV);
            
            oIVCrop.Crop(vdRowCropBounds, vdColCropBounds, vdSliceCropBounds);
            oIVCrop.ForceApplyAllTransforms();
                
            sT1PostContrastDicomFolderPath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetT1PostContrastMRIDicomFolderPath();
            sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');            
            sIMGPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, sT1PostContrastDicomFolderPath);
            
            FileIOUtils.MkdirIfItDoesNotExist(sIMGPPPath);
            
            oIVCrop.Save(fullfile(sIMGPPPath, sIMGPPSaveCode + " (BM " + string(StringUtils.num2str_PadWithZeros(dBMNumber, 2)) + ").mat"), bForceApplyTransforms, '-v7','-nocompression');          
        end        
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end