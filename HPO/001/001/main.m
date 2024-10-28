
Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oHPO = ExperimentHyperParameterOptimizer("HPO-001-001", @MATLABBayesianHyperParameterOptimizer, "Parameters\HPO Parameters.mat");

oHPO.Save();