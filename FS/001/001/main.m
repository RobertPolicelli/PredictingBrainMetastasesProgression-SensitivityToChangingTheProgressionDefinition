Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

sFilePath = "Parameters\Feature Selector Parameters.mat";

oFS = ExperimentFeatureSelector("FS-001-001", @CorrelationFilterFeatureSelector, sFilePath);

oFS.Save();