classdef ExperimentManager
    %ExperimentManager
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Constant = true, GetAccess = public)
        chExperimentAssetsSectionName = 'Experiment Assets'
    end
    
    properties (Constant = true, GetAccess = private)
        vsTags = [...
            "DB",...
            "RDB",...
            ...
            "DBG",...
            "LBL",...
            "IVH",...
            "FV",...
            "TS",...
            "HP",...
            "FS",...
            "OFN",...
            "HPO",...
            "MDL"]
        c1fnTagLoaders = {...
            @(x) StudyDatabase.Load(x),...
            @(x) REDCapStudyDatabase.Load(x),...
            ...
            @(x) DatabaseGroup.Load(x),...
            @(x) Labels.Load(x),...
            @(x) ImageVolumeHandlers.Load(x),...
            @(x) ExperimentFeatureValues.Load(x),...
            @(x) TuningSet.Load(x),...
            @(x) ExperimentHyperParameters.Load(x),...
            @(x) ExperimentFeatureSelector.Load(x),...
            @(x) ExperimentObjectiveFunction.Load(x),...
            @(x) ExperimentHyperParameterOptimizer.Load(x),...
            @(x) ExperimentModel.Load(x)}
        
        chImageVolumeHandlersRootExperimentDataPathTag = 'ImageVolumeHandlersRoot'        
        chImagingDatabaseRootExperimentDataPathTag = 'ProcessedImagingDatabase'
        
        sExperimentManifestCodesFilename = "Experiment Manifest Codes.mat"
        
        sExperimentManifestCodesFileDBGVarName = "sDBGCode"
        sExperimentManifestCodesFileLBLVarName = "sLBLCode"
        sExperimentManifestCodesFileMDLVarName = "sMDLCode"
        sExperimentManifestCodesFileFSVarName = "vsFSCodes"
        sExperimentManifestCodesFileObjFcnFSVarName = "vsObjFcnFSCodes"
        sExperimentManifestCodesFileHPOVarName = "sHPOCode"
        sExperimentManifestCodesFileObjFcnHPOVarName = "sObjFcnHPOCode"
        sExperimentManifestCodesFileTSVarName = "sTSCode"
        sExperimentManifestCodesFileFVVarName = "vsFVCodes"
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function obj = Load(chAssetIdTag, sCustomExperimentRoot)
            arguments
                chAssetIdTag (1,:) char
                sCustomExperimentRoot string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
            end
            
            vdDashIndices = strfind(chAssetIdTag, '-');
            
            if isempty(vdDashIndices)
                error(...
                    'ExperimentManager:Load:InvalidIdTag',...
                    'There must be a least one "-" in an ID tag.');
            end
            
            sClassTag = string(chAssetIdTag(1:vdDashIndices(1)-1));
            
            vdClassMatch = find(ExperimentManager.vsTags == sClassTag);
            
            if isempty(vdClassMatch)
                error(...
                    'ExperimentManager:Load:InvalidTag',...
                    'The tag is not recognized.');
            end
            
            fnLoader = ExperimentManager.c1fnTagLoaders{vdClassMatch(1)};
                        
            obj = fnLoader(fullfile(...
                ExperimentManager.GetPathToExperimentAssetResultsDirectory(chAssetIdTag, sCustomExperimentRoot),...
                ['01 ', ExperimentManager.chExperimentAssetsSectionName],...
                [chAssetIdTag, '.mat']));
        end
        
        function CreateExperimentFoldersFromManifest(sExperimentManifestPath, sExperimentDirectoryPath, vdManifestRows)
            arguments
                sExperimentManifestPath (1,1) string
                sExperimentDirectoryPath (1,1) string
                vdManifestRows (:,1) double
            end
            
            tExpManifest = readtable(sExperimentManifestPath, 'Sheet', 'EXP', 'ReadVariableNames', false, 'ReadRowNames', false);
            
            dNumExperiments = length(vdManifestRows);
           
            vsExperimentNames = strings(dNumExperiments, 1);
            
            vsDBGCode = strings(dNumExperiments, 1);
            vsLBLCode = strings(dNumExperiments, 1);
            vsMDLCode = strings(dNumExperiments, 1);
            c1vsFSCodes = cell(dNumExperiments, 1);
            c1vsObjFcnFSCodes = cell(dNumExperiments, 1);
            vsHPOCode = strings(dNumExperiments, 1);
            vsObjFcnHPOCode = strings(dNumExperiments, 1);
            vsTSCode = strings(dNumExperiments, 1);
            c1vsFVCodes = cell(dNumExperiments, 1);
            
            vdExpCodeCols = [4,6,8];
            dDBGCodeCol = 10;
            dLBLCodeCol = 11;
            dMDLCodeCol = 16;
            dFSCodesCol = 18;
            dHPOCodesCol = 19;
            dTSCodeCol = 20;
            vdFVCodeCols = 21:28;
            
            for dExpIndex=1:dNumExperiments
                dRowIndex = vdManifestRows(dExpIndex);
                
                sExperimentName = "EXP";
                
                for dExpColIndex=1:length(vdExpCodeCols)
                    sExperimentName = sExperimentName + "-" + tExpManifest{dRowIndex, vdExpCodeCols(dExpColIndex)};
                end
                
                vsExperimentNames(dExpIndex) = sExperimentName;
                
                vsDBGCode(dExpIndex) = tExpManifest{dRowIndex, dDBGCodeCol};
                vsLBLCode(dExpIndex) = tExpManifest{dRowIndex, dLBLCodeCol};
                vsMDLCode(dExpIndex) = tExpManifest{dRowIndex, dMDLCodeCol};
                
                sFSLine = string(tExpManifest{dRowIndex, dFSCodesCol});
                vsFSLineChunks = strtrim(strsplit(sFSLine, ">"));
                
                dNumFSs = length(vsFSLineChunks);
                
                vsFSCodes = strings(1,dNumFSs);
                vsObjFcnFSCodes = strings(1,dNumFSs);
                
                for dCodeIndex=1:dNumFSs
                    vsSubChunks = strtrim(strsplit(vsFSLineChunks(dCodeIndex), '+'));
                    
                    if length(vsSubChunks) == 1
                        vsFSCodes(dCodeIndex) = vsSubChunks;
                    else
                        vsFSCodes(dCodeIndex) = vsSubChunks(1);
                        vsObjFcnFSCodes(dCodeIndex) = vsSubChunks(2);
                    end
                end
                
                c1vsFSCodes{dExpIndex} = vsFSCodes;
                c1vsObjFcnFSCodes{dExpIndex} = vsObjFcnFSCodes;
                
                vsHPOLineChunks = strtrim(strsplit(string(tExpManifest{dRowIndex, dHPOCodesCol}), "+"));
                
                if length(vsHPOLineChunks) == 1
                    vsHPOCode(dExpIndex) = vsHPOLineChunks;
                else
                    vsHPOCode(dExpIndex) = vsHPOLineChunks(1);
                    vsObjFcnHPOCode(dExpIndex) = vsHPOLineChunks(2);
                end
                
                vsTSCode(dExpIndex) = tExpManifest{dRowIndex, dTSCodeCol};
                
                vsFVCodes = string.empty;
                
                for dFeatureColIndex=1:length(vdFVCodeCols)
                    dFVCol = vdFVCodeCols(dFeatureColIndex);
                    
                    xEntry = tExpManifest{dRowIndex, dFVCol};
                    
                    if ismissing(xEntry)
                        break;
                    else
                        vsFVCodes = [vsFVCodes, xEntry];
                    end
                end
                
                c1vsFVCodes{dExpIndex} = vsFVCodes;
            end
            
            % create exp directories
            for dExpIndex=1:dNumExperiments
                copyfile(pwd, fullfile(sExperimentDirectoryPath, vsExperimentNames(dExpIndex)));
                
                FileIOUtils.SaveMatFile(...
                    fullfile(sExperimentDirectoryPath, vsExperimentNames(dExpIndex), ExperimentManager.sExperimentManifestCodesFilename),...
                    ExperimentManager.sExperimentManifestCodesFileDBGVarName, vsDBGCode(dExpIndex),...
                    ExperimentManager.sExperimentManifestCodesFileLBLVarName, vsLBLCode(dExpIndex),...
                    ExperimentManager.sExperimentManifestCodesFileMDLVarName, vsMDLCode(dExpIndex),...
                    ExperimentManager.sExperimentManifestCodesFileFSVarName, c1vsFSCodes{dExpIndex},...
                    ExperimentManager.sExperimentManifestCodesFileObjFcnFSVarName, c1vsObjFcnFSCodes{dExpIndex},...
                    ExperimentManager.sExperimentManifestCodesFileHPOVarName, vsHPOCode(dExpIndex),...
                    ExperimentManager.sExperimentManifestCodesFileObjFcnHPOVarName, vsObjFcnHPOCode(dExpIndex),...
                    ExperimentManager.sExperimentManifestCodesFileTSVarName, vsTSCode(dExpIndex),...
                    ExperimentManager.sExperimentManifestCodesFileFVVarName, c1vsFVCodes{dExpIndex});
            end
        end
        
        function varargout = LoadExperimentManifestCodesMatFile(sManifestCodesFilePath)
            arguments
                sManifestCodesFilePath (1,1) string = ""
            end
            
            if sManifestCodesFilePath == ""
                sManifestCodesFilePath = fullfile(pwd, ExperimentManager.sExperimentManifestCodesFilename);
            end
            
            if ~Experiment.IsRunning
                error(...
                    'ExperimentManager:LoadExperimentManifestCodesMatFile:ExperimentMustBeRunning',...
                    'Experiment must be running.');
            else
                try
                    [m2sFeatureValueCodes_Training, sLabelsCode_Training, m2sFeatureValueCodes_Testing, sLabelsCode_Testing, sModelCode, sHPOCode, sObjFcnCodeForHPO, vsFSCodes] = ...
                        FileIOUtils.LoadMatFile(...
                        sManifestCodesFilePath,...
                        "m2sFVCodes_Training", "sLBLCode_Training",...
                        "m2sFVCodes_Testing", "sLBLCode_Testing",...
                        "sMDLCode", "sHPOCode", "sObjFcnHPOCode", "vsFSCodes");
                    
                    bSingleSplit = true;
                catch e
                    [m2sFeatureValueCodes, sLabelsCode, sModelCode, sHPOCode, sObjFcnCodeForHPO, vsFSCodes, sSSCode] = ...
                        FileIOUtils.LoadMatFile(...
                        sManifestCodesFilePath,...
                        "m2sFVCodes", "sLBLCode",...
                        "sMDLCode", "sHPOCode", "sObjFcnHPOCode", "vsFSCodes", "sSSCode");
                    
                    bSingleSplit = false;
                end
                
                if bSingleSplit
                    % sort training FV values into clinical and radiomics
                    vbFeatureCodeIsClinical = m2sFeatureValueCodes_Training(1,:) == "Clinical";
                    vbFeatureCodeIsRadiomics = m2sFeatureValueCodes_Training(1,:) == "Radiomics";
                    
                    if sum(vbFeatureCodeIsClinical) + sum(vbFeatureCodeIsRadiomics) ~= size(m2sFeatureValueCodes_Training,2)
                        error(...
                            'ExperimentManager:LoadExperimentManifestCodesMatFile:InvalidTrainingFeatureValuesLabel',...
                            'A training feature values code must be clinical or radiomics.');
                    end
                    
                    vsClinicalFeatureValueCodes_Training = m2sFeatureValueCodes_Training(2,vbFeatureCodeIsClinical);
                    vsRadiomicFeatureValueCodes_Training = m2sFeatureValueCodes_Training(2,vbFeatureCodeIsRadiomics);
                    
                    % sort testing FV values into clinical and radiomics
                    vbFeatureCodeIsClinical = m2sFeatureValueCodes_Testing(1,:) == "Clinical";
                    vbFeatureCodeIsRadiomics = m2sFeatureValueCodes_Testing(1,:) == "Radiomics";
                    
                    if sum(vbFeatureCodeIsClinical) + sum(vbFeatureCodeIsRadiomics) ~= size(m2sFeatureValueCodes_Testing,2)
                        error(...
                            'ExperimentManager:LoadExperimentManifestCodesMatFile:InvalidTestingFeatureValuesLabel',...
                            'A testing feature values code must be clinical or radiomics.');
                    end
                    
                    vsClinicalFeatureValueCodes_Testing = m2sFeatureValueCodes_Testing(2,vbFeatureCodeIsClinical);
                    vsRadiomicFeatureValueCodes_Testing = m2sFeatureValueCodes_Testing(2,vbFeatureCodeIsRadiomics);
                    
                    
                    [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                    
                    if bAddEntriesIntoExperimentReport
                        Experiment.StartNewSubSection('Loaded Experiment Asset Codes');
                        
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Training Feature Values: ', join(m2sFeatureValueCodes_Training(2,:), ", ")));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Training Labels: ', sLabelsCode_Training));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Testing Feature Values: ', join(m2sFeatureValueCodes_Testing(2,:), ", ")));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Testing Labels: ', sLabelsCode_Testing));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Model: ', sModelCode));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Hyper-Parameter Optimizer: ', sHPOCode));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Hyper-Parameter Optimizer Obj. Fcn.: ', sObjFcnCodeForHPO));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Feature Selectors: ', join(vsFSCodes, ", ")));
                        
                        Experiment.EndCurrentSubSection();
                    end
                    
                    varargout = {vsClinicalFeatureValueCodes_Training, vsRadiomicFeatureValueCodes_Training, sLabelsCode_Training, vsClinicalFeatureValueCodes_Testing, vsRadiomicFeatureValueCodes_Testing, sLabelsCode_Testing, sModelCode, sHPOCode, sObjFcnCodeForHPO, vsFSCodes};
                    
                else
                    % sort FV values into clinical and radiomics
                    vbFeatureCodeIsClinical = m2sFeatureValueCodes(1,:) == "Clinical";
                    vbFeatureCodeIsRadiomics = m2sFeatureValueCodes(1,:) == "Radiomics";
                    
                    if sum(vbFeatureCodeIsClinical) + sum(vbFeatureCodeIsRadiomics) ~= size(m2sFeatureValueCodes,2)
                        error(...
                            'ExperimentManager:LoadExperimentManifestCodesMatFile:InvalidFeatureValuesLabel',...
                            'A training feature values code must be clinical or radiomics.');
                    end
                    
                    vsClinicalFeatureValueCodes = m2sFeatureValueCodes(2,vbFeatureCodeIsClinical);
                    vsRadiomicFeatureValueCodes = m2sFeatureValueCodes(2,vbFeatureCodeIsRadiomics);
                    
                    [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                    
                    if bAddEntriesIntoExperimentReport
                        Experiment.StartNewSubSection('Loaded Experiment Asset Codes');
                        
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Feature Values: ', join(m2sFeatureValueCodes(2,:), ", ")));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Labels: ', sLabelsCode));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Model: ', sModelCode));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Hyper-Parameter Optimizer: ', sHPOCode));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Hyper-Parameter Optimizer Obj. Fcn.: ', sObjFcnCodeForHPO));
                        Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Feature Selectors: ', join(vsFSCodes, ", ")));
                        
                        Experiment.EndCurrentSubSection();
                    end                    
                    
                    varargout = {sSSCode, vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode, sModelCode, sHPOCode, sObjFcnCodeForHPO, vsFSCodes};
                    
                end
            end
        end
        
        function chPath = GetPathToExperimentAssetResultsDirectory(chAssetIdTag, sCustomExperimentRoot)
            arguments
                chAssetIdTag (1,:) char
                sCustomExperimentRoot string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
            end
            
            if ~isempty(sCustomExperimentRoot)
                chExperimentRootPath = char(sCustomExperimentRoot);
            elseif ~isempty(which('Experiment')) && Experiment.IsRunning()
                chExperimentRootPath = Experiment.GetDataPath('ExperimentRoot');
            else
                chExperimentRootPath = pwd;
            end
            
            voEntries = dir(chExperimentRootPath);
            dNumEntries = length(voEntries);
            
            c1chMatches = {};
            
            vdDashIndices = strfind(chAssetIdTag,'-');
            
            if isempty(vdDashIndices)
                error(...
                    'ExperimentManager:GetPathToExperimentAssetResultsDirectory:InvalidAssetIdTag',...
                    'The asset ID tag must have at least one dash.');
            end
            
            chExpAssetTypeCode = chAssetIdTag(1 : vdDashIndices(1)-1);
            chExpAssetNumber = chAssetIdTag(vdDashIndices(1)+1 : end);
            
            for dEntryIndex=1:dNumEntries
                if voEntries(dEntryIndex).isdir && strcmp(voEntries(dEntryIndex).name, chExpAssetTypeCode)
                    voAssetTypeFolderEntries = dir(fullfile(chExperimentRootPath, chExpAssetTypeCode));
                    
                    for dAssetTypeFolderEntryIndex=1:length(voAssetTypeFolderEntries)
                        oEntry = voAssetTypeFolderEntries(dAssetTypeFolderEntryIndex);
                        
                        if oEntry.isdir && contains(oEntry.name, chExpAssetNumber)
                            chName = oEntry.name;
                            
                            vdSpaceIndices = strfind(chName, ' ');
                            
                            if length(chName) > 22 && strcmp(chName(end-21:end-20), ' [') && strcmp(chName(end), ']') && strcmp(chName(1:(vdSpaceIndices(1)-1)), chExpAssetNumber)
                                c1chMatches = [c1chMatches, {fullfile(chExpAssetTypeCode, chName)}];
                            end
                        end
                    end
                end
            end
            
            if isempty(c1chMatches)
                % now search for "-" replaced with multiple folder levels
                vsIdComponents = strsplit(string(chAssetIdTag), "-");
                c1sToFolderPathComponents = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vsIdComponents(1:end-1));
                
                sToFolderPath = fullfile(c1sToFolderPathComponents{:});
                
                sSearchFolderName = vsIdComponents(end);
                
                if ~isempty(sCustomExperimentRoot)
                    voEntries = dir(fullfile(sCustomExperimentRoot, sToFolderPath));
                elseif ~isempty(which('Experiment')) && Experiment.IsRunning()
                    voEntries = dir(fullfile(Experiment.GetDataPath('ExperimentRoot'), sToFolderPath));
                else
                    voEntries = dir(fullfile(pwd, sToFolderPath));
                end
                
                dNumEntries = length(voEntries);
                
                vbMatches = false(dNumEntries,1);
                
                for dEntryIndex=1:dNumEntries
                    if voEntries(dEntryIndex).isdir && contains(voEntries(dEntryIndex).name, sSearchFolderName)
                        chName = voEntries(dEntryIndex).name;
                        
                        vdSpaceIndices = strfind(chName, ' ');
                        
                        if length(chName) > 22 && all(chName(end-21:end-20) == ' [') && chName(end) == ']' && strcmp(chName(1:(vdSpaceIndices(1)-1)), sSearchFolderName)
                            vbMatches(dEntryIndex) = true;
                        end
                    end
                end
                
                if sum(vbMatches) == 0
                    error(...
                        'ExperimentManagaer:GetPathToExperimentAssetResultsDirectory:NoValidMatches',...
                        ['No experiments found for "', chAssetIdTag, '".'])
                elseif sum(vbMatches) > 1
                    error(...
                    'ExperimentManagaer:GetPathToExperimentAssetResultsDirectory:MultipleValidMatches',...
                    'Multiple completed experiments found.');
                end
                
                c1chMatches = {fullfile(c1sToFolderPathComponents{:}, voEntries(vbMatches).name)};
            elseif length(c1chMatches) > 1
                error(...
                    'ExperimentManagaer:GetPathToExperimentAssetResultsDirectory:MultipleValidMatches',...
                    'Multiple completed experiments found.');
            end
            
            if ~isempty(which('Experiment')) && Experiment.IsRunning()
                chPath = fullfile(...
                    chExperimentRootPath,...
                    c1chMatches{1},...
                    'Results');
            else
                chPath = fullfile(...
                    c1chMatches{1},...
                    'Results');
            end
        end
        
        function varargout = GetLabelledFeatureValues(vsFeatureValueIdTags, sLabelIdTag, sTuningSetIdTag, sCustomExperimentRoot)
            arguments
                vsFeatureValueIdTags (1,:) string
                sLabelIdTag (1,1) string
                sTuningSetIdTag string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
                sCustomExperimentRoot string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
            end
            
            if isempty(vsFeatureValueIdTags)
                varargout = {LabelledFeatureValuesByValue.empty};
            else
                dNumFVs = length(vsFeatureValueIdTags);
                
                c1oFVs = cell(dNumFVs,1);
                c1oFeatureValues = cell(dNumFVs,1);
                
                for dFVIndex=1:dNumFVs
                    oFV = ExperimentManager.Load(vsFeatureValueIdTags(dFVIndex), sCustomExperimentRoot);
                    
                    c1oFVs{dFVIndex} = oFV;
                    c1oFeatureValues{dFVIndex} = oFV.GetFeatureValues();
                end
                
                oLBL = ExperimentManager.Load(sLabelIdTag, sCustomExperimentRoot);
                
                if ~isempty(sTuningSetIdTag)
                    oTS = ExperimentManager.Load(sTuningSetIdTag, sCustomExperimentRoot);
                else
                    oTS = TuningSet.empty;
                end
                
                if dNumFVs == 1
                    oFeatureValues = c1oFeatureValues{1};
                else
                    oFeatureValues = horzcat(c1oFeatureValues{:});
                end
                
                oLabelledFeatureValues = oLBL.GetLabelledFeatureValues();
                
                % check IDs check out
                if any(oLabelledFeatureValues.GetGroupIds() ~= oFeatureValues.GetGroupIds()) || any(oLabelledFeatureValues.GetSubGroupIds() ~= oFeatureValues.GetSubGroupIds())
                    error(...
                        'ExperimentManager:GetLabelledFeatureValues:IDMismatch',...
                        'Labels and features values group/sub-group IDs are not identical per sample.');
                end
                
                viLabels = oLabelledFeatureValues.GetLabels();
                iPositiveLabel = oLabelledFeatureValues.GetPositiveLabel();
                iNegativeLabel = oLabelledFeatureValues.GetNegativeLabel();
                
                oLabelledFeatureValues = LabelledFeatureValuesByValue(oFeatureValues, viLabels, iPositiveLabel, iNegativeLabel);
                
                if isempty(oTS)
                    varargout = {oLabelledFeatureValues};
                else
                    vbSampleIsInTuningSet = oTS.GetSampleIsInTuningSet();
                    
                    oTuningSet = oLabelledFeatureValues(vbSampleIsInTuningSet,:);
                    oTrainingTestingSet = oLabelledFeatureValues(~vbSampleIsInTuningSet,:);
                    
                    varargout = {oTuningSet, oTrainingTestingSet};
                end
            end
        end
        
        function sImageDatabaseRootPath = GetImageDatabaseRootPath()
            sImageDatabaseRootPath = string(Experiment.GetDataPath(ExperimentManager.chImagingDatabaseRootExperimentDataPathTag));
        end
        
        function sImageVolumeHandlersRootPath = GetImageVolumeHandlersRootPath()
            sImageVolumeHandlersRootPath = string(Experiment.GetDataPath(ExperimentManager.chImageVolumeHandlersRootExperimentDataPathTag));
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

