Experiment.StartNewSection('Experiment Assets');

% load features values
oFV = ExperimentManager.Load('FV-004-002-001A');
oFeatureValues = oFV.GetFeatureValues();

% Remove 2 BM that did not have RANO measurements
vbKeepSample = true(oFeatureValues.GetNumberOfSamples(),1);
vbKeepSample(108) = false;
vbKeepSample(24) = false;
oFeatureValues = oFeatureValues(vbKeepSample,:);

% Create new feature values object
oRecord = CustomFeatureExtractionRecord("FV-004-002-001R", oFeatureValues.GetFeatureExtractionRecord(1).GetFeatureExtractionRecordPortions.GetDescription(), oFeatureValues.GetFeatures());

oFeatureValues = FeatureValuesByValue(...
    oFeatureValues.GetFeatures(), oFeatureValues.GetGroupIds(), oFeatureValues.GetSubGroupIds(), oFeatureValues.GetUserDefinedSampleStrings(), oFeatureValues.GetFeatureNames(),...
    'FeatureIsCategorical', oFeatureValues.IsFeatureCategorical(),...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-004-002-001R");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();