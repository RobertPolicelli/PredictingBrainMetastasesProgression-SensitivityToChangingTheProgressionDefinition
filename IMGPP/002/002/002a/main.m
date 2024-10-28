oDB = ExperimentManager.Load('DB-006-004');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdUniquePatientIds = unique(vdPatientIds);

vdBMNumbers = m2dSampleIds(:,2);

% get patient brain ROI names
c2xBrainROIRawData = readcell(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-004'), 'Patient Brain Contour Names.xlsx'));

vdPatientIdsPerBrainROIName = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xBrainROIRawData(2:end,1));
vsBrainROINames = string(c2xBrainROIRawData(2:end,2));

% Load/save codes
sWholeImageIMGPPLoadCode = "IMGPP-002-001-000a";
sWholeImageROIPPLoadCode = "ROIPP-002-001-000a";

sIMGPPLoadCode = "IMGPP-002-002-001a";

sIMGPPSaveCode = "IMGPP-002-002-002a";

% constants
bForceApplyTransforms = false;

dNumberOfStDevs = 3;

% process each patient
for dPatientIndex=1:length(vdUniquePatientIds)
    try
        dPatientId = vdUniquePatientIds(dPatientIndex);
        disp(dPatientId);
        
        oPatient = oDB.GetPatientByPrimaryId(dPatientId);
        
        % Get brain mask without BM GTVs (including BMs excluded from
        % study)
        oWholeIV = oPatient.LoadImageVolume(sWholeImageIMGPPLoadCode);
        oWholeROIs = oPatient.LoadRegionsOfInterest(sWholeImageROIPPLoadCode);
        
        sBrainROIName = vsBrainROINames(vdPatientIdsPerBrainROIName == dPatientId);
        
        m3bBrainMask = oWholeROIs.GetMaskByRegionOfInterestNumber(oWholeROIs.GetRegionOfInterestNumberByRegionOfInterestName(sBrainROIName));
        
        dNumBMs = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetNumberOfTargetedBrainMetastases();
                
        for dBMNumber=1:dNumBMs
            m3bBMMask = oWholeROIs.GetMaskByRegionOfInterestNumber(oWholeROIs.GetRegionOfInterestNumberByRegionOfInterestName(oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetRegionOfInterestNameByTargetedBrainMetastasisNumber(dBMNumber)));
            
            m3bBrainMask = m3bBrainMask & ~m3bBMMask;
        end
        
        % Find mean and st dev
        m3iImagingData = oWholeIV.GetImageData();
        vdBrainWithoutBMsVoxelValues = double(m3iImagingData(m3bBrainMask));
        
        dMean = mean(vdBrainWithoutBMsVoxelValues);
        dStDev = std(vdBrainWithoutBMsVoxelValues);        
        
        % For each BM, Z-score normalize (only for BMs included in the
        % study)
        vdBMNumbersForPatient = vdBMNumbers(vdPatientIds == dPatientId);
        
        for dBMIndex=1:length(vdBMNumbersForPatient)
            dBMNumber = vdBMNumbersForPatient(dBMIndex);
                        
            oIV = oPatient.LoadImageVolume(sIMGPPLoadCode, dBMNumber);  
            
            oIV.NormalizeIntensityWithZScoreTransform(dNumberOfStDevs, 'CustomMean', dMean, 'CustomStandardDeviation', dStDev);
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