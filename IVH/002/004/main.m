Experiment.StartNewSection('Experiment Assets');

% get Patient IDs
[vdPatientIds, vdBMNumbers] = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'), 'vdPatientIdPerSample', 'vdBMNumberPerSample');

% define IMGPP and ROIPP to use
sIMGPP = 'IMGPP-005-001-002a';
sROIPP = 'ROIPP-005-001-001';

% Set IVH name and source
sIVH = 'IVH-002-004';

sImageSource = "Pre-Treatment T1wCE MRI - 0.5x0.5x0.5mm Interpolation - Whole Brain Z-Score Normalization (3 st. dev.)";

% process each sample
dNumSamples = length(vdPatientIds);

vsHandlerFilePaths = strings(dNumSamples,1);

chHandlerRoot = fullfile(Experiment.GetResultsDirectory(), 'Image Volume Handlers');
mkdir(chHandlerRoot);

for dSampleIndex=1:dNumSamples
    dPatientId = vdPatientIds(dSampleIndex);
    dBMNumber = vdBMNumbers(dSampleIndex);
    
    disp(dSampleIndex);
        
    oPatient = Patient.LoadFromDatabase(dPatientId);
    
    oIV = oPatient.LoadProcessedImageVolume(sIMGPP, dBMNumber);
    oROI = oPatient.LoadProcessedRegionsOfInterest(sROIPP, dBMNumber);
    oIV.SetRegionsOfInterest(oROI);
    
    oHandler = FeatureExtractionImageVolumeHandler(...
         oIV, sImageSource,...
         'SampleOrder', 1,...
         'GroupId', uint16(dPatientId),...
         'SubGroupId', uint16(dBMNumber),...
         'UserDefinedSampleStrings', string(dPatientId) + "-" + string(dBMNumber),...
         'ImageInterpretation', '3D');
     
     sFilePath = fullfile(chHandlerRoot, "PT " + string(StringUtils.num2str_PadWithZeros(dPatientId, 4)) + " BM " + string(StringUtils.num2str_PadWithZeros(dBMNumber,2)) + ".mat");
     
     FileIOUtils.SaveMatFile(sFilePath, 'oHandler', oHandler, '-v7', '-nocompression');
     
     vsHandlerFilePaths(dSampleIndex) = sFilePath;
end

oIVH = ImageVolumeHandlers(sIVH, vsHandlerFilePaths);
oIVH.Save();