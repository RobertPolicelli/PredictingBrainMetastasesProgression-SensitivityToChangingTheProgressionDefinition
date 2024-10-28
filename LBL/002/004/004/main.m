Experiment.StartNewSection('Experiment Assets');

% get sample IDs
[vdPatientIds, vdBMNumbers] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-004-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'),...
    'vdPatientIdPerSample', 'vdBMNumberPerSample');
vdOldPatientIds = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'),...
    'vdPatientIdPerSample');
vdPatientIds(108) = [];
vdPatientIds(24) = [];    %the 2 BM that did not have initial RANO measurments
vdBMNumbers(108) = []; 
vdBMNumbers(24) = [];
vdOldPatientIds(111) = []; 
vdOldPatientIds(24) = [];
dPatientIdDifference = setdiff(vdOldPatientIds, vdPatientIds);
vbKeepSample = find(vdOldPatientIds~=dPatientIdDifference);
[vbIsProgressionPerSample, vbIsRadionecrosisPerSample, vbIsAdverseRadiationEffectPerSample] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-004-002-004'), '01 Analysis', 'Outcomes Per Sample.mat'),...
    'vbIsProgressionPerSample',...
    'vbIsRadionecrosisPerSample',...
    'vbIsAdverseRadiationEffectPerSample');
vbIsProgressionPerSample = vbIsProgressionPerSample(vbKeepSample,:);
vbIsRadionecrosisPerSample = vbIsRadionecrosisPerSample(vbKeepSample,:);
vbIsAdverseRadiationEffectPerSample = vbIsAdverseRadiationEffectPerSample(vbKeepSample,:);

%Create feature value object
vsFeatureNames = "Dummy Variable";
m2dFeatures = zeros(length(vdPatientIds),1);

viGroupIds = uint16(vdPatientIds);
viSubGroupIds = uint16(vdBMNumbers);

vsUserDefinedSampleStrings = string(viGroupIds) + "-" + string(viSubGroupIds);

oRecord = CustomFeatureExtractionRecord("LBL-002-004-004", "In-field Progression", m2dFeatures);

oLabelledFeatureValues = LabelledFeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames,...
    uint8(vbIsProgressionPerSample), uint8(1), uint8(0),...
    'FeatureExtractionRecord', oRecord);

disp("Num +: " + string(sum(vbIsProgressionPerSample)));
disp("Num -: " + string(sum(~vbIsProgressionPerSample)));
disp("Num Pseudo-Progression: " + string(sum(vbIsRadionecrosisPerSample | vbIsAdverseRadiationEffectPerSample)))

oLBL = Labels("LBL-002-004-004");

oLBL.SaveLabelledFeatureValuesAsMat(oLabelledFeatureValues);
oLBL.Save();