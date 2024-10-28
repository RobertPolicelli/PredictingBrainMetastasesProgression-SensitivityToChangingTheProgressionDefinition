Experiment.StartNewSection('Experiment Assets');

% load features values
oLBL = ExperimentManager.Load('LBL-002-005-005');
oLabelledFeatureValues = oLBL.GetLabelledFeatureValues();


% Remove 2 BM that did not have RANO measurements
vbKeepSample = true(oLabelledFeatureValues.GetNumberOfSamples(),1);
vbKeepSample(108) = false;
vbKeepSample(24) = false;
oLabelledFeatureValues = oLabelledFeatureValues(vbKeepSample,:);

% Create new feature values object
oRecord = CustomFeatureExtractionRecord("LBL-002-005-005R", "In-field Progression", oLabelledFeatureValues.GetFeatures());

oLabelledFeatureValues = LabelledFeatureValuesByValue(...
    oLabelledFeatureValues.GetFeatures(), oLabelledFeatureValues.GetGroupIds(), oLabelledFeatureValues.GetSubGroupIds(), oLabelledFeatureValues.GetUserDefinedSampleStrings(), oLabelledFeatureValues.GetFeatureNames(),...
    oLabelledFeatureValues.GetLabels(), oLabelledFeatureValues.GetPositiveLabel(), oLabelledFeatureValues.GetNegativeLabel(),...
    'FeatureExtractionRecord', oRecord);

oLBL = Labels("LBL-002-005-005R");

oLBL.SaveLabelledFeatureValuesAsMat(oLabelledFeatureValues);
oLBL.Save();