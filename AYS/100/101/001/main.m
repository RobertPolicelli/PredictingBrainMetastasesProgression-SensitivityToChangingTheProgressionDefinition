Experiment.StartNewSection('Analysis');

dNumBootstraps = 250;

sExpCode = "EXP-200-001-109R";

sResultsDirectory = string(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode));
[chExpRoot,~] = FileIOUtils.SeparateFilePathAndFilename(sResultsDirectory);
sExpRoot = string(chExpRoot);

copyfile(fullfile(sExpRoot, "Experiment Manifest Codes.mat"), "Experiment Manifest Codes.mat");

% load experiment asset codes
[~, vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode, sModelCode, sHPOCode, sObjFcnCodeForHPO, sFeatureSelectorCode] = ...
    ExperimentManager.LoadExperimentManifestCodesMatFile();

% load experiment assets
oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsClinicalFeatureValueCodes,...
    sLabelsCode);

oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);

if ~isempty(oRadiomicDataSet)
    if ~isempty(oClinicalDataSet)
        oReferenceDataSet = [oRadiomicDataSet oClinicalDataSet];
    else
        oReferenceDataSet = oRadiomicDataSet;
    end
else
    oReferenceDataSet = oClinicalDataSet;
end

dTotalNumFeatures = oReferenceDataSet.GetNumberOfFeatures();
vsFeatureNames = oReferenceDataSet.GetFeatureNames();

m2dFeatureRankingScorePerBootstrapPerFeature = nan(dNumBootstraps, dTotalNumFeatures);
m2dFeatureRankPerBootstrapPerFeature = nan(dNumBootstraps, dTotalNumFeatures);

for dBootstrapIndex=1:dNumBootstraps
    % load artifacts from experiment
    [vbRadiomicFeatureMask, vdFeatureImportanceScores] = FileIOUtils.LoadMatFile(...
        fullfile(sResultsDirectory, "02 Bootstrapped Iterations", "Iteration " + string(StringUtils.num2str_PadWithZeros(dBootstrapIndex,3)) + " Results.mat"),...
        'vbRadiomicFeatureMask', 'vdFeatureImportanceScores');

    % get data set
    if ~isempty(oRadiomicDataSet)
        oBootstrapRadiomicDataSet = oRadiomicDataSet(:, vbRadiomicFeatureMask);

        if isempty(oClinicalDataSet)
            oBootstrapDataSet = oBootstrapRadiomicDataSet;
        else
            oBootstrapDataSet = [oBootstrapRadiomicDataSet, oClinicalDataSet];
        end
    else
        oBootstrapDataSet = oClinicalDataSet;
    end

    vsBootstrapFeatureNames = oBootstrapDataSet.GetFeatureNames();

    % calculate feature ranking scores
    vdFeatureRankings = zeros(size(vdFeatureImportanceScores));
    [~, vdSortIndices] = sort(vdFeatureImportanceScores, 'descend');
    
    for dFeatureIndex=1:length(vdFeatureImportanceScores)
        vdFeatureRankings(vdSortIndices(dFeatureIndex)) = dFeatureIndex;
    end
    
    vdNormalizedFeatureImportance = (vdFeatureImportanceScores - min(vdFeatureImportanceScores)) / (max(vdFeatureImportanceScores) - min(vdFeatureImportanceScores));
    
    for dBoostrapFeatureIndex=1:oBootstrapDataSet.GetNumberOfFeatures()
        m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex, vsFeatureNames==vsBootstrapFeatureNames(dBoostrapFeatureIndex)) = vdNormalizedFeatureImportance(dBoostrapFeatureIndex);
        m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex, vsFeatureNames==vsBootstrapFeatureNames(dBoostrapFeatureIndex)) = vdFeatureRankings(dBoostrapFeatureIndex);
    end
    
    m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,:))) = min(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,~isnan(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,:))));
    m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,:))) = max(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,~isnan(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,:))));
    
end

vdAverageFeatureScore = mean(m2dFeatureRankingScorePerBootstrapPerFeature);
vdAverageFeatureRanking = mean(m2dFeatureRankPerBootstrapPerFeature);

vdNormalizedAverageFeatureScores = (vdAverageFeatureScore - min(vdAverageFeatureScore)) / (max(vdAverageFeatureScore) - min(vdAverageFeatureScore));
vdNormalizedAverageFeatureRanking = (vdAverageFeatureRanking - min(vdAverageFeatureRanking)) / (max(vdAverageFeatureRanking) - min(vdAverageFeatureRanking));

[vdSortedNormalizedAverageFeatureScores, vdSortIndices] = sort(vdNormalizedAverageFeatureScores, 'descend');
vsSortedNormalizedAverageFeatureScoresFeatureNames = vsFeatureNames(vdSortIndices);

FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'Feature Importance.mat'),...
    'vsFeatureNames', vsFeatureNames,...
    'm2dFeatureRankingScorePerBootstrapPerFeature', m2dFeatureRankingScorePerBootstrapPerFeature, 'm2dFeatureRankPerBootstrapPerFeature', m2dFeatureRankPerBootstrapPerFeature,...
    'vdAverageFeatureScore', vdAverageFeatureScore, 'vdAverageFeatureRanking', vdAverageFeatureRanking,...
    'vdNormalizedAverageFeatureScores', vdNormalizedAverageFeatureScores, 'vdNormalizedAverageFeatureRanking', vdNormalizedAverageFeatureRanking,...
    'vdSortedNormalizedAverageFeatureScores', vdSortedNormalizedAverageFeatureScores, 'vsSortedNormalizedAverageFeatureScoresFeatureNames', vsSortedNormalizedAverageFeatureScoresFeatureNames);

vsHeaders = ["Feature Number", "Feature Name", "Normalized Feature Importance"];

c2xDataToWrite = cell(1+dTotalNumFeatures, 3);

c2xDataToWrite(1,:) = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vsHeaders);

c2xDataToWrite(2:end,1) = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects((1:dTotalNumFeatures)');
c2xDataToWrite(2:end,2) = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vsSortedNormalizedAverageFeatureScoresFeatureNames');
c2xDataToWrite(2:end,3) = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vdSortedNormalizedAverageFeatureScores');

writecell(c2xDataToWrite, fullfile(Experiment.GetResultsDirectory(), 'Feature Importance.xlsx'));
