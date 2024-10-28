
Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oMDL = ExperimentModel("MDL-001-001", @MATLABTreeBagger, "Parameters\Model Hyper Parameters.mat");

oMDL.Save();

