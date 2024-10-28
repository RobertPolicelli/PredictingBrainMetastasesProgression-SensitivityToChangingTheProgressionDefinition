
dNumBootstraps = 250;

Experiment.StartNewSection('Progression');
sExpCodes = ["004-002c"];
m2bOverallFeatureImportanceMatrix = [];
m2bOverallFeatureRankingMatrix = [];
ZeroCount = 0;
for CurrentExp = 1: length(sExpCodes)
    sExpCurrentCode = fullfile("EXP-200-"+sExpCodes(CurrentExp));
    sResultsDirectory = string(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCurrentCode));
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
        clear vbRadiomicFeatureMask vdFeatureImportanceScores
        [vbRadiomicFeatureMask, vdFeatureImportanceScores] = FileIOUtils.LoadMatFile(...
            fullfile(sResultsDirectory, "02 Bootstrapped Iterations", "Iteration " + string(StringUtils.num2str_PadWithZeros(dBootstrapIndex,3)) + " Results.mat"),...
            'vbRadiomicFeatureMask', 'vdFeatureImportanceScores');
        if sum(vdFeatureImportanceScores) == 0
            m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,:))) = zeros(1,107);
            m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,:))) = zeros(1,107);
            ZeroCount = ZeroCount+1;
            disp(fullfile(sExpCurrentCode + " " + string(dBootstrapIndex) + " " +ZeroCount))
            continue
        end
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
    m2bOverallFeatureImportanceMatrix = [m2bOverallFeatureImportanceMatrix; vdNormalizedAverageFeatureScores];
    m2bOverallFeatureRankingMatrix = [m2bOverallFeatureRankingMatrix; vdNormalizedAverageFeatureRanking];
end


FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'Feature Importance.mat'),...
    'vsFeatureNames', vsFeatureNames,...
    'vdNormalizedAverageFeatureScores', m2bOverallFeatureImportanceMatrix, 'vdNormalizedAverageFeatureRanking', m2bOverallFeatureRankingMatrix,...
    'ExperimentNames', sExpCodes);

