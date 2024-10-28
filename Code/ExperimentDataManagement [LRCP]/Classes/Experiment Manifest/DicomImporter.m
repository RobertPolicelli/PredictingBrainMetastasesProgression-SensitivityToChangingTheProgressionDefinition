classdef (Abstract) DicomImporter
    %DicomImporter
    %
    % TODO
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
    end
    
    properties (Constant = true, GetAccess = public)
        
        
        chDicomDatabasePatientFolderPrefix = 'Patient ';
        
        chDicomDatabasePreTreatmentFolderName = 'Pre-Treatment';
        
        chImageDatabaseCTSimFolderNamePrefix = 'CT Sim'
        dImageDatabaseCTSimFolderLabellingNumDigits = 2
        
        chImageDatabaseMRSimFolderName = 'MR Sim';
        chImageDatabaseDiagnosticMRFolderName = 'MR Diag';
        
        chImageDatabaseRTStructFolderName = 'RT Struct';
        chImageDatabaseRTDoseFolderName = 'RT Dose';
        chImageDatabaseRTPlanFolderName = 'RT Plan';
        
        chImageDatabaseRTStructFilenamePrefix = 'RT Struct';
        chImageDatabaseRTDoseFilenamePrefix = 'RT Dose';
        chImageDatabaseRTPlanFilenamePrefix = 'RT Plan';
        dImageDatabaseRTDicomFilenameLabellingNumDigits = 2
        
        chImageDatabaseRTStructFilenameApprovedSuffix = '(Approved)';
        chImageDatabaseRTStructFilenameUnapprovedSuffix = '(Unapproved)';
        
        chImageDatabaseRegistrationFolderName = 'CT-MR Reg';
        
        chImageDatabaseRegistrationFilenamePrefix = 'Reg';
        dImageDatabaseRegistrationFilenameLabellingNumDigits = 2
        
        chMRSimExportFolderName = 'MR Head Contrast';
        chDiagnosticMRExportFolderName = 'MR Head';
        chCTSimExportFolderName = 'CT';
        
        vsMRSeriesReformatedScansKeywords = ["rfmt", "reformat", "reformatted", "_mpr", "mpr_", "-mpr", "mpr-", " mpr", "mpr "]
        
        chRTDoseExportFolderPrefix = 'RTDOSE';
        chRTPlanExportFolderPrefix = 'RTPLAN';
        chRTStructExportFolderPrefix = 'RTSTRUCT';
        
        chRTStructExportApprovedFilenameKeyword = 'Approved'
        chRTStructExportUnapprovedFilenameKeyword = 'Unapproved'
        
        chRTDicomExportFilename = 'RT000000.dcm'
        
        chRegistrationExportFolderPrefix = 'REG';
        chRegistrationExportFilename = 'RE000000.dcm'
        
        
        
        DicomServerHttpConfigFileIPAndPortVarName = "sDicomServerIPAndPort"
        DicomServerHttpConfigFileUsernameVarName = "sDicomServerUsername"
        DicomServerHttpConfigFilePasswordVarName = "sDicomServerPassword"
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
    end
    
    
    methods (Access = public, Static = true)
        
        function [vsStrings, vsStructChainPerString] = GetAllStringsWithinStruct(stStruct, vsStrings, vsStructChainPerString, sCurrentStructChain)
            arguments
                stStruct (1,1) struct
                vsStrings = string.empty
                vsStructChainPerString = string.empty
                sCurrentStructChain = ""
            end
            
            c1chFieldNames = fieldnames(stStruct);
            
            for dFieldIndex=1:length(c1chFieldNames)
                xFieldValue = stStruct.(c1chFieldNames{dFieldIndex});
                
                if isstruct(xFieldValue)
                    [vsStrings, vsStructChainPerString] = DicomImporter.GetAllStringsWithinStruct(xFieldValue, vsStrings, vsStructChainPerString, sCurrentStructChain + "." + string(c1chFieldNames{dFieldIndex}));
                elseif isstring(xFieldValue) || ischar(xFieldValue)
                    vsStrings = [vsStrings; string(xFieldValue)];
                    vsStructChainPerString = [vsStructChainPerString; sCurrentStructChain + "." + string(c1chFieldNames{dFieldIndex})];
                    %                 else
                    %                     vsStrings = [vsStrings; string(mat2str(xFieldValue))];
                    %                     vsStructChainPerString = [vsStructChainPerString; sCurrentStructChain + "." + string(c1chFieldNames{dFieldIndex})];
                end
            end
        end
        
        function [vsRegPaths, vsReferencedMRPath, vsNonReformatedReferencedMRPath] = MatchMRSeriesToRegistrations(sDicomPath)
            % get registration paths and referenced FOR UIDs
            sRegFolderPath = fullfile(sDicomPath, DicomImporter.chImageDatabaseRegistrationFolderName);
            
            vsRegFilenames = FileIOUtils.DirGetNamesAndIsDir(sRegFolderPath);
            dNumRegs = length(vsRegFilenames);
            
            vsRegPaths = fullfile(sRegFolderPath, vsRegFilenames);
            
            c1vsMRImageInstanceUIDsPerReg = cell(dNumRegs,1);
            vsRegMRFrameOfReferenceUIDs = strings(dNumRegs,1);
            
            for dRegIndex=1:dNumRegs
                stRegMetadata = dicominfo(vsRegPaths(dRegIndex), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                
                vsRegMRFrameOfReferenceUIDs(dRegIndex) = string(stRegMetadata.RegistrationSequence.Item_2.FrameOfReferenceUID);
                
                dNumReferencedImages = length(fieldnames(stRegMetadata.RegistrationSequence.Item_2.ReferencedImageSequence));
                vsMRImageInstanceUIDs = strings(dNumReferencedImages,1);
                
                for dImageIndex=1:dNumReferencedImages
                    vsMRImageInstanceUIDs(dImageIndex) = string(stRegMetadata.RegistrationSequence.Item_2.ReferencedImageSequence.(['Item_', num2str(dImageIndex)]).ReferencedSOPInstanceUID);
                end
                
                c1vsMRImageInstanceUIDsPerReg{dRegIndex} = vsMRImageInstanceUIDs;
            end
            
            % search the MRs for the FOR UIDs
            vsReferencedMRPath = strings(dNumRegs,1);
            vsReferencedMRAcquisitionTime = strings(dNumRegs,1);
            vsReferencedMRFolderName = strings(dNumRegs,1);
            vbReferencedFromMRSim = false(dNumRegs,1);
            
            sMRSimFolderPath = fullfile(sDicomPath, DicomImporter.chImageDatabaseMRSimFolderName);
            vsMRSimSeriesFolderNames = FileIOUtils.DirGetNamesAndIsDir(sMRSimFolderPath);
            dNumSeries = length(vsMRSimSeriesFolderNames);
            
            vsAcquisitionTimePerMRSimSeries = strings(dNumSeries,1);
            
            for dMRSimSeriesIndex=1:dNumSeries
                vsMRFilenames = FileIOUtils.DirGetNamesAndIsDir(fullfile(sMRSimFolderPath, vsMRSimSeriesFolderNames(dMRSimSeriesIndex)));
                
                stMRMetadata = dicominfo(fullfile(sMRSimFolderPath, vsMRSimSeriesFolderNames(dMRSimSeriesIndex), vsMRFilenames(1)), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                vsAcquisitionTimePerMRSimSeries(dMRSimSeriesIndex) = string(stMRMetadata.AcquisitionTime);
                
                %vbRegMatch = vsRegMRFrameOfReferenceUIDs == string(stMRMetatdata.FrameOfReferenceUID);
                
                vbRegMatch = false(dNumRegs,1);
                
                for dRegIndex=1:dNumRegs
                    if any(stMRMetadata.SOPInstanceUID == c1vsMRImageInstanceUIDsPerReg{dRegIndex})
                        vbRegMatch(dRegIndex) = true;
                    end
                end
                
                if any(vbRegMatch)
                    if sum(vbRegMatch) ~= 1
                        error(...
                            'DicomImporter:MatchMRSeriesToRegistrations:MultipleRegistrationMatches',...
                            'Single MR found to match multiple registrations.');
                    end
                    
                    dMatchIndex = find(vbRegMatch);
                    
                    if vsReferencedMRPath(dMatchIndex) ~= ""
                        error(...
                            'DicomImporter:MatchMRSeriesToRegistrations:MultipleMRMatches',...
                            'Single registration found to match multiple MRs.');
                    end
                    
                    vsReferencedMRPath(dMatchIndex) = fullfile(sMRSimFolderPath, vsMRSimSeriesFolderNames(dMRSimSeriesIndex));
                    vsReferencedMRFolderName(dMatchIndex) = vsMRSimSeriesFolderNames(dMRSimSeriesIndex);
                    vsReferencedMRAcquisitionTime(dMatchIndex) = string(stMRMetadata.AcquisitionTime);
                    vbReferencedFromMRSim(dMatchIndex) = true;
                end
            end
            
            sMRDiagFolderPath = fullfile(sDicomPath, DicomImporter.chImageDatabaseDiagnosticMRFolderName);
            vsMRDiagSeriesFolderNames = FileIOUtils.DirGetNamesAndIsDir(sMRDiagFolderPath);
            dNumSeries = length(vsMRDiagSeriesFolderNames);
            
            vsAcquisitionTimePerMRDiagSeries = strings(dNumSeries,1);
            
            for dMRDiagSeriesIndex=1:dNumSeries
                vsMRFilenames = FileIOUtils.DirGetNamesAndIsDir(fullfile(sMRDiagFolderPath, vsMRDiagSeriesFolderNames(dMRDiagSeriesIndex)));
                
                stMRMetadata = dicominfo(fullfile(sMRDiagFolderPath, vsMRDiagSeriesFolderNames(dMRDiagSeriesIndex), vsMRFilenames(1)), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                vsAcquisitionTimePerMRDiagSeries(dMRDiagSeriesIndex) = string(stMRMetadata.AcquisitionTime);
                
                %vbRegMatch = vsRegMRFrameOfReferenceUIDs == string(stMRMetatdata.FrameOfReferenceUID);
                
                vbRegMatch = false(dNumRegs,1);
                
                for dRegIndex=1:dNumRegs
                    if any(stMRMetadata.SOPInstanceUID == c1vsMRImageInstanceUIDsPerReg{dRegIndex})
                        vbRegMatch(dRegIndex) = true;
                    end
                end
                
                if any(vbRegMatch)
                    if sum(vbRegMatch) ~= 1
                        error(...
                            'DicomImporter:MatchMRSeriesToRegistrations:MultipleRegistrationMatches',...
                            'Single MR found to match multiple registrations.');
                    end
                    
                    dMatchIndex = find(vbRegMatch);
                    
                    if vsReferencedMRPath(dMatchIndex) ~= ""
                        error(...
                            'DicomImporter:MatchMRSeriesToRegistrations:MultipleMRMatches',...
                            'Single registration found to match multiple MRs.');
                    end
                    
                    if vsReferencedMRPath(dMatchIndex) ~= ""
                        error(...
                            'DicomImporter:MatchMRSeriesToRegistrations:MatchToSimAndDiag',...
                            'Matched to a simulation and diagnostic MR scan');
                    end
                    
                    vsReferencedMRPath(dMatchIndex) = fullfile(sMRDiagFolderPath, vsMRDiagSeriesFolderNames(dMRDiagSeriesIndex));
                    vsReferencedMRFolderName(dMatchIndex) = vsMRDiagSeriesFolderNames(dMRDiagSeriesIndex);
                    vsReferencedMRAcquisitionTime(dMatchIndex) = string(stMRMetadata.AcquisitionTime);
                    vbReferencedFromMRSim(dMatchIndex) = false;
                end
            end
            
            if any(vsReferencedMRPath == "")
                warning(...
                    'DicomImporter:MatchMRSeriesToRegistrations:MatchNotFound',...
                    'Not all registrations matched.');
            end
            
            % Check if any of the referenced MRs are reformatted from other
            % MRs. If they do, find the original MRI
            vsNonReformatedReferencedMRPath = strings(dNumRegs,1);
            
            for dRegIndex=1:dNumRegs
                if vbReferencedFromMRSim(dRegIndex)
                    vsAcquisitionTimePerMRSeries = vsAcquisitionTimePerMRSimSeries;
                    vsMRSeriesFolderNames = vsMRSimSeriesFolderNames;
                    sMRFolderPath = sMRSimFolderPath;
                else
                    vsAcquisitionTimePerMRSeries = vsAcquisitionTimePerMRDiagSeries;
                    vsMRSeriesFolderNames = vsMRDiagSeriesFolderNames;
                    sMRFolderPath = sMRDiagFolderPath;
                end
                
                
                if contains(lower(vsReferencedMRFolderName(dRegIndex)), lower(DicomImporter.vsMRSeriesReformatedScansKeywords)) % was a reformated scan
                    vbAcquisitionTimeMatches = vsAcquisitionTimePerMRSeries == vsReferencedMRAcquisitionTime(dRegIndex);
                    
                    vsMatchedMRSeriesNames = vsMRSeriesFolderNames(vbAcquisitionTimeMatches);
                    dNumMatches = length(vsMatchedMRSeriesNames);
                    
                    vbOriginalMR = false(dNumMatches,1);
                    
                    for dSearchIndex=1:dNumMatches
                        if ~contains(lower(vsMatchedMRSeriesNames(dSearchIndex)), lower(DicomImporter.vsMRSeriesReformatedScansKeywords)) % was not a reformated scan
                            vbOriginalMR(dSearchIndex) = true;
                        end
                    end
                    
                    if ~any(vbOriginalMR) || sum(vbOriginalMR) > 1
                        error(...
                            'DicomImporter:MatchMRSeriesToRegistrations:MultipleOriginalMRMatches',...
                            'Multiple possible original MRs.');
                    end
                    
                    vsNonReformatedReferencedMRPath(dRegIndex) = fullfile(sMRFolderPath, vsMatchedMRSeriesNames(vbOriginalMR));
                else
                    vsNonReformatedReferencedMRPath(dRegIndex) = vsReferencedMRPath(dRegIndex);
                end
            end
        end
        
        
        function DownloadDataFromDicomServer(vdPatientIdsToImport, chDownloadCachePath)
            
            [sServerIpAndHttpPort, sHttpUsername, sHttpPassword] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('DicomServerHttpConfig'),...
                DicomImporter.DicomServerHttpConfigFileIPAndPortVarName,...
                DicomImporter.DicomServerHttpConfigFileUsernameVarName,...
                DicomImporter.DicomServerHttpConfigFilePasswordVarName);
            
            oWebOpts = weboptions('Username',sHttpUsername,'Password',sHttpPassword);
            
            c1chPatientDicomUUIDs = webread("http://" + sServerIpAndHttpPort + "/patients", oWebOpts);
            dNumPatientsOnServer = length(c1chPatientDicomUUIDs);
            
            vbImportDicoms = false(dNumPatientsOnServer,1);
            vdPatientIdsOnServer = zeros(dNumPatientsOnServer,1);
            
            for dPatientIndex=1:dNumPatientsOnServer
                stPatientData = webread("http://" + sServerIpAndHttpPort + "/patients/" + string(c1chPatientDicomUUIDs{dPatientIndex}), oWebOpts);
                
                dPatientId = DicomImporter.GetPatientIdFromDicomPatientIDField(stPatientData.MainDicomTags.PatientID);
                
                if ~isempty(dPatientId) && ~isempty(find(vdPatientIdsToImport, dPatientId))
                    vbImportDicoms(dPatientIndex) = true;
                    vdPatientIdsOnServer(dPatientIndex) = dPatientId;
                end
            end
            
            c1chPatientDicomUUIDs = c1chPatientDicomUUIDs(vbImportDicoms);
            vdPatientIdsOnServer = vdPatientIdsOnServer(vbImportDicoms);
            
            for dPatientIndex=1:length(vdPatientIdsToImport)
                dPatientIdToImport = vdPatientIdsToImport(dPatientIndex);
                
                Experiment.StartNewSection("Patient " + string(num2str(dPatientIdToImport)) + " Pre-Treatment Data Download");
                
                bErrored = false;
                
                try
                    dFindIndex = find(vdPatientIdsOnServer == dPatientIdToImport);
                    
                    if isempty(dFindIndex)
                        warning("Patient " + string(num2str(dPatientIdToImport)) + " not found on Dicom server.");
                    else
                        sPatientDicomUUID = string(c1chPatientDicomUUIDs{dFindIndex});
                        
                        sPatientDicomDatabaseFolder = DicomImporter.GetDicomDatabasePatientFolderNameForPatientId(dPatientIdToImport);
                        
                        if isfolder(fullfile(chDownloadCachePath, sPatientDicomDatabaseFolder))
                            warning("Patient " + string(num2str(dPatientIdToImport)) + " appears to have already been downloaded, and so will not be downloaded again.");
                        else
                            % download the patients dicoms from server as a
                            % zip, and then unzip it
                            disp('Downloading DICOM Data .zip...');
                            
                            chZipFilePath = fullfile(chDownloadCachePath, sPatientDicomDatabaseFolder+".zip");
                            
                            oFile = fopen(chZipFilePath,'w');
                            fwrite(oFile, webread("http://" + sServerIpAndHttpPort + "/patients/" + sPatientDicomUUID + "/archive", oWebOpts));
                            fclose(oFile);
                            
                            disp('Uncompressing .zip...');
                            
                            unzip(chZipFilePath, fullfile(chDownloadCachePath, sPatientDicomDatabaseFolder));
                            delete(chZipFilePath);
                        end
                    end
                catch e
                    Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel(...
                        'Error: ', getReport(e, 'extended', 'hyperlinks', 'off')));
                end
                
                Experiment.EndCurrentSection();
            end
        end
        
        
        function ImportPreTreatmentDataForPatient(oStudyDatabase, dPatientIdToImport, chDicomDataCurationFilePath, chDownloadCachePath, chDicomImagingDatabasePath, sTreatmentPlanningSystem)
            arguments
                oStudyDatabase (1,1) StudyDatabase
                dPatientIdToImport (1,1) double
                chDicomDataCurationFilePath (1,:) char
                chDownloadCachePath (1,:) char
                chDicomImagingDatabasePath (1,:) char
                sTreatmentPlanningSystem (1,1) string
            end
            
            
            oPatient = oStudyDatabase.GetPatientByPrimaryId(dPatientIdToImport);
            oTreatmentPlan = oPatient.GetFirstBrainRadiationCourseTreatmentPlan();
            
            bErrored = false;
            
            sPatientDicomDatabaseFolder = DicomImporter.GetDicomDatabasePatientFolderNameForPatientId(dPatientIdToImport);
            
            if ~isfolder(fullfile(chDownloadCachePath, sPatientDicomDatabaseFolder))
                error("Patient " + string(num2str(dPatientIdToImport)) + " data not downloaded.");
            end
            
            if isfolder(fullfile(chDicomImagingDatabasePath, sPatientDicomDatabaseFolder, DicomImporter.chDicomDatabasePreTreatmentFolderName))
                warning("Patient " + string(num2str(dPatientIdToImport)) + " appears to have already been imported. Existing files will be deleted and replaced.");
                
                rmdir(fullfile(chDicomImagingDatabasePath, sPatientDicomDatabaseFolder, DicomImporter.chDicomDatabasePreTreatmentFolderName), 's');
            end
            
            
            mkdir(fullfile(chDicomImagingDatabasePath, sPatientDicomDatabaseFolder, DicomImporter.chDicomDatabasePreTreatmentFolderName));
            
            chRootToPath = fullfile(chDicomImagingDatabasePath, sPatientDicomDatabaseFolder, DicomImporter.chDicomDatabasePreTreatmentFolderName);
            sRootToPath = string(chRootToPath);
            
            
            if ~isfolder(fullfile(chDicomImagingDatabasePath, sPatientDicomDatabaseFolder)) % make patient dir in Dicom database if needed
                mkdir(chDicomImagingDatabasePath, sPatientDicomDatabaseFolder);
            end
            
            
            chRootFromPath = fullfile(chDownloadCachePath, sPatientDicomDatabaseFolder, sPatientDicomDatabaseFolder + " " + sPatientDicomDatabaseFolder);
            sRootFromPath = string(chRootFromPath);
            
            
            m2sDicomDataCuration = readmatrix(chDicomDataCurationFilePath, 'Sheet', StringUtils.num2str_PadWithZeros(dPatientIdToImport, 4), 'OutputType', 'string');
            
            vsCurationDataHeaders = m2sDicomDataCuration(1,:);
            
            m2sDicomDataCurationPerSeries = m2sDicomDataCuration(2:end,:);
            
            dNumSeries = size(m2sDicomDataCurationPerSeries,1);
            
            
            for dSeriesIndex=1:dNumSeries
                if m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Remove") ~= "X" % is not being removed
                    sFromFolderPath = m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Orthanc Download Folder Path");
                    
                    [chStudyName,chSeriesName] = FileIOUtils.SeparateFilePathAndFilename(sFromFolderPath);
                    
                    
                    
                    if strcmp(chSeriesName(1:2), 'CT')
                        
                        sCTFolderName = "CT (" + m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Study Date") + ")";
                        
                        if ~isfolder(fullfile(sRootToPath, sCTFolderName))
                            mkdir(sRootToPath, sCTFolderName);
                        else
                            error('CT folder already exists');
                        end
                        
                        copyfile(...
                            fullfile(chRootFromPath, sFromFolderPath),...
                            fullfile(chRootToPath, sCTFolderName));
                        
                        sImportPath = sCTFolderName;
                        
                    elseif strcmp(chSeriesName(1:2), 'MR')
                        
                        sMRFolderName = "MR (" + m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Study Date") + ")";
                        
                        if ~isfolder(fullfile(sRootToPath, sMRFolderName))
                            mkdir(sRootToPath, sMRFolderName);
                        end
                        
                        vdIndices = strfind(chSeriesName, '-');
                        
                        if ~isempty(vdIndices) && ~isnan(str2double(chSeriesName(vdIndices(end)+1 : end))) % the series name is of format "dope series name-X", where X is the repeat index
                            dCurrentRepeatIndex = 0;
                            voEntries = dir(fullfile(chRootToPath, sMRFolderName));
                            
                            for dIndex=3:length(voEntries)
                                chEntryName = voEntries(dIndex).name;
                                
                                if contains(chEntryName, chSeriesName(1 : vdIndices(end)-1))
                                    dCurrentRepeatIndex = dCurrentRepeatIndex + 1;
                                end
                            end
                            
                            chCopyToSeriesName = chSeriesName(1 : vdIndices(end)-1);
                            
                            if dCurrentRepeatIndex+1 > 1
                                chCopyToSeriesName = [chCopyToSeriesName, ' (', num2str(dCurrentRepeatIndex+1), ')'];
                            end
                        else
                            chCopyToSeriesName = chSeriesName;
                        end
                        
                        copyfile(...
                            fullfile(chRootFromPath, sFromFolderPath),...
                            fullfile(chRootToPath, sMRFolderName, chCopyToSeriesName));
                        
                        sImportPath = string(fullfile(sMRFolderName, chCopyToSeriesName));
                        
                    elseif strcmp(chSeriesName(1:3), 'REG')
                        
                        sRegFolderName = "REG (" + m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Study Date") + ")";
                        
                        if ~isfolder(fullfile(sRootToPath, sRegFolderName))
                            mkdir(sRootToPath, sRegFolderName);
                        end
                        
                        if sTreatmentPlanningSystem == "RayStation"
                            dNumRegs = length(dir(fullfile(sRootToPath, sRegFolderName))) - 2;
                            
                            chFilename = ['RE', StringUtils.num2str_PadWithZeros(dNumRegs, 6), '.dcm'];
                            
                            copyfile(...
                                fullfile(chRootFromPath, chStudyName, chSeriesName, 'RE000000.dcm'),...
                                fullfile(chRootToPath, sRegFolderName, chFilename));
                            
                            sImportPath = string(fullfile(sRegFolderName, chFilename));
                        elseif contains(sTreatmentPlanningSystem, "Pinnacle")
                            dNumExistingRegs = length(dir(fullfile(sRootToPath, sRegFolderName))) - 2;
                            dNumRegFilesToImport = length(dir(fullfile(chRootFromPath, chStudyName, chSeriesName)))-2;
                            
                            for dRegIndex=1:dNumRegFilesToImport
                                chFilename = ['RE', StringUtils.num2str_PadWithZeros(dNumExistingRegs + dRegIndex - 1, 6), '.dcm'];
                                
                                copyfile(...
                                    fullfile(chRootFromPath, chStudyName, chSeriesName, ['RE', StringUtils.num2str_PadWithZeros(dRegIndex - 1, 6), '.dcm']),...
                                    fullfile(chRootToPath, sRegFolderName, chFilename));
                            end
                            
                            sImportPath = sRegFolderName;
                        end
                        
                    elseif strcmp(chSeriesName(1:6), 'RTDOSE')
                        
                        sRTDoseFolderName = "RTDOSE (" + m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Study Date") + ")";
                        
                        if ~isfolder(fullfile(sRootToPath, sRTDoseFolderName))
                            mkdir(sRootToPath, sRTDoseFolderName);
                        end
                        
                        dNumRTDoses = length(dir(fullfile(sRootToPath, sRTDoseFolderName))) - 2;
                        
                        chFilename = ['RT', StringUtils.num2str_PadWithZeros(dNumRTDoses, 6), '.dcm'];
                        
                        copyfile(...
                            fullfile(chRootFromPath, chStudyName, chSeriesName, 'RT000000.dcm'),...
                            fullfile(chRootToPath, sRTDoseFolderName, chFilename));
                        
                        sImportPath = string(fullfile(sRTDoseFolderName, chFilename));
                        
                    elseif strcmp(chSeriesName(1:6), 'RTPLAN')
                        
                        sRTPlanFolderName = "RTPLAN (" + m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Study Date") + ")";
                        
                        if ~isfolder(fullfile(sRootToPath, sRTPlanFolderName))
                            mkdir(sRootToPath, sRTPlanFolderName);
                        end
                        
                        dNumRTPlans = length(dir(fullfile(sRootToPath, sRTPlanFolderName))) - 2;
                        
                        chFilename = ['RT', StringUtils.num2str_PadWithZeros(dNumRTPlans, 6), '.dcm'];
                        
                        copyfile(...
                            fullfile(chRootFromPath, chStudyName, chSeriesName, 'RT000000.dcm'),...
                            fullfile(chRootToPath, sRTPlanFolderName, chFilename));
                        
                        sImportPath = string(fullfile(sRTPlanFolderName, chFilename));
                        
                    elseif strcmp(chSeriesName(1:8), 'RTSTRUCT')
                        
                        sRTStructFolderName = "RTSTRUCT (" + m2sDicomDataCurationPerSeries(dSeriesIndex, vsCurationDataHeaders == "Study Date") + ")";
                        
                        if ~isfolder(fullfile(sRootToPath, sRTStructFolderName))
                            mkdir(sRootToPath, sRTStructFolderName);
                        end
                        
                        dNumRTStructs = length(dir(fullfile(sRootToPath, sRTStructFolderName))) - 2;
                        
                        chFilename = ['RT', StringUtils.num2str_PadWithZeros(dNumRTStructs, 6), '.dcm'];
                        
                        copyfile(...
                            fullfile(chRootFromPath, chStudyName, chSeriesName, 'RT000000.dcm'),...
                            fullfile(chRootToPath, sRTStructFolderName, chFilename));
                        
                        sImportPath = string(fullfile(sRTStructFolderName, chFilename));
                        
                    else
                        error('Unknown modality');
                    end
                    
                    m2sDicomDataCuration(dSeriesIndex+1, vsCurationDataHeaders == "Imported To") = fullfile(string(DicomImporter.chDicomDatabasePreTreatmentFolderName), sImportPath);
                end
            end
            
            
            % store to patient
            varargin = {};
            
            sCTImportPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "CT Sim") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(sCTImportPath)
                varargin = [varargin, {'CT', sCTImportPath}];
            end
            
            sMRT1wPrePath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR T1w Pre") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(sMRT1wPrePath)
                varargin = [varargin, {'MRT1wPre', sMRT1wPrePath}];
            end
            
            sMRT1wPostPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR T1w Post") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(sMRT1wPostPath)
                varargin = [varargin, {'MRT1wPost', sMRT1wPostPath}];
            end
            
            sMRT2wPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR T2w") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(sMRT2wPath)
                varargin = [varargin, {'MRT2w', sMRT2wPath}];
            end
            
            sMRFAPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR FA") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(sMRFAPath)
                varargin = [varargin, {'MRFA', sMRFAPath}];
            end
            
            sMRADCPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR ADC") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(sMRADCPath)
                varargin = [varargin, {'MRADC', sMRADCPath}];
            end
            
            if sTreatmentPlanningSystem == "RayStation"
                sMRT1wPostRegistrationPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR T1w Post Reg.") == "X", vsCurationDataHeaders == "Imported To");
                
                if ~isempty(sMRT1wPostRegistrationPath)
                    varargin = [varargin, {'MRT1wPostRegistration', sMRT1wPostRegistrationPath}];
                end
                
                sMRT2wRegistrationPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR T2 Reg.") == "X", vsCurationDataHeaders == "Imported To");
                
                if ~isempty(sMRT2wRegistrationPath)
                    varargin = [varargin, {'MRT2wRegistration', sMRT2wRegistrationPath}];
                end
                
            elseif contains(sTreatmentPlanningSystem, "Pinnacle")
                sMRT1wPostRegistrationPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR T1w Post Reg.") == "X", vsCurationDataHeaders == "Imported To");
                sMRT2wRegistrationPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "MR T2 Reg.") == "X", vsCurationDataHeaders == "Imported To");
                
                if isempty(sMRT2wRegistrationPath) % if registration had to be redone in MIM
                    voRegistrationSpecifications = oTreatmentPlan.GetRegistrationSpecifications();
                    
                    dNumRegSpecs = length(voRegistrationSpecifications);
                    
                    vsRegFilePathPerRegistrationSpecification = strings(dNumRegSpecs,1);
                    
                    for dRegIndex=1:dNumRegSpecs
                        if voRegistrationSpecifications(dRegIndex).GetScanType() == PinnacleRegistrationSpecificationScanType.T1Post
                            vsRegFilePathPerRegistrationSpecification(dRegIndex) = fullfile(sMRT1wPostRegistrationPath, "RE000000.dcm");
                        end
                    end
                    
                    varargin = [varargin, {'FilePathPerRegistration', vsRegFilePathPerRegistrationSpecification}];
                else
                    if sMRT1wPostRegistrationPath ~= sMRT2wRegistrationPath
                        error(...
                            'DicomImporter:ImportPreTreatmentDataForPatient:InvalidRegistrationFileStructure',...
                            'All registrations should have ended up in the same folder');
                    end
                    
                    if isempty(sMRT1wPostRegistrationPath)
                        [~, sRegFolderName] = FileIOUtils.SeparateFilePathAndFilename(sMRT2wRegistrationPath);
                    else
                        [~, sRegFolderName] = FileIOUtils.SeparateFilePathAndFilename(sMRT1wPostRegistrationPath);
                    end
                    
                    voRegFileEntries = dir(fullfile(chRootToPath, sRegFolderName));
                    voRegFileEntries = voRegFileEntries(3:end);
                    
                    dNumRegFiles = length(voRegFileEntries);
                    
                    voRegistrationSpecifications = oTreatmentPlan.GetRegistrationSpecifications();
                    
                    dNumRegSpecs = length(voRegistrationSpecifications);
                    
                    if dNumRegFiles ~= dNumRegSpecs
                        error(...
                            'DicomImporter:ImportPreTreatmentDataForPatient:InvalidNumberOfRegistrationFiles',...
                            'The number of registration files doesn''t match the number of registrations listed in Pinnacle.');
                    end
                    
                    vdClosestRegistrationSpecificationPerFile = zeros(dNumRegSpecs,1);
                    
                    m2dTransformRotationMatrixPerRegSpec = zeros(dNumRegSpecs,3,3);
                    m2dTransformTranslationPerRegSpec_mm = zeros(dNumRegSpecs,3);
                    
                    for dRegSpecIndex=1:dNumRegSpecs
                        vdRegSpecRotation_deg = voRegistrationSpecifications(dRegSpecIndex).GetTransformRotation_deg();
                        vdRegSpecTranslation_mm = voRegistrationSpecifications(dRegSpecIndex).GetTransformTranslation_mm();
                        
                        vdRegSpecTranslation_mm = [1 -1 -1] .* vdRegSpecTranslation_mm;
                        
                        m2dTransformRotationMatrixPerRegSpec(dRegSpecIndex,:,:) = eul2rotm([1 -1 -1] .* vdRegSpecRotation_deg .* pi/180, 'xyz');
                        m2dTransformTranslationPerRegSpec_mm(dRegSpecIndex,:) = vdRegSpecTranslation_mm;
                    end
                    
                    m2dRegDifferenceNormPerFilePerSpecification = zeros(dNumRegFiles, dNumRegSpecs);
                    
                    for dRegFileIndex=1:dNumRegFiles
                        oMetadata = dicominfo(fullfile(chRootToPath, sRegFolderName, voRegFileEntries(dRegFileIndex).name));
                        
                        m2dTransformMatrix = reshape(oMetadata.RegistrationSequence.Item_2.MatrixRegistrationSequence.Item_1.MatrixSequence.Item_1.FrameOfReferenceTransformationMatrix, 4, 4)';
                        
                        m2dRegFileRotationMatrix = m2dTransformMatrix(1:3,1:3);
                        vdRegFileTranslation_mm = m2dTransformMatrix(1:3,4)';
                        
                        vdRegDifferenceNormPerSpecification = zeros(dNumRegSpecs,1);
                        
                        for dRegSpecIndex=1:dNumRegSpecs
                            vdRegDifferenceNormPerSpecification(dRegSpecIndex) = ...
                                norm(m2dTransformRotationMatrixPerRegSpec(dRegSpecIndex,:) - m2dRegFileRotationMatrix(:)) + ...
                                norm(m2dTransformTranslationPerRegSpec_mm(dRegSpecIndex,:) - vdRegFileTranslation_mm);
                        end
                        
                        m2dRegDifferenceNormPerFilePerSpecification(dRegFileIndex,:) = vdRegDifferenceNormPerSpecification;
                        [~,vdClosestRegistrationSpecificationPerFile(dRegFileIndex)] = min(vdRegDifferenceNormPerSpecification);
                    end
                    
                    if length(unique(vdClosestRegistrationSpecificationPerFile)) ~= length(vdClosestRegistrationSpecificationPerFile) % there were duplicate matches
                        m2dCompareAllRotationsToFirstRegSpec = m2dTransformRotationMatrixPerRegSpec - repmat(m2dTransformRotationMatrixPerRegSpec(1,:,:), dNumRegSpecs, 1, 1);
                        m2dCompareAllTranslationsToFirstRegSpec = m2dTransformTranslationPerRegSpec_mm - repmat(m2dTransformTranslationPerRegSpec_mm(1,:), dNumRegSpecs, 1);
                        
                        % remove any rows that did match uniquely
                        vbKeepRow = true(dNumRegSpecs,1);
                        
                        for dRegSpecIndex=1:dNumRegSpecs
                            if sum(vdClosestRegistrationSpecificationPerFile == dRegSpecIndex) == 1
                                vbKeepRow(vdClosestRegistrationSpecificationPerFile == dRegSpecIndex) = false;
                            end
                        end
                        
                        m2dCompareAllRotationsToFirstRegSpec = m2dCompareAllRotationsToFirstRegSpec(vbKeepRow,:,:);
                        m2dCompareAllTranslationsToFirstRegSpec = m2dCompareAllTranslationsToFirstRegSpec(vbKeepRow,:);
                        
                        if all(m2dCompareAllRotationsToFirstRegSpec(:) == 0) && all(m2dCompareAllTranslationsToFirstRegSpec(:) == 0)
                            % all registrations are identical, so it doesn't
                            % matter how they're matched up
                            
                            for dRegFileIndex=1:dNumRegFiles
                                if sum(vdClosestRegistrationSpecificationPerFile == vdClosestRegistrationSpecificationPerFile(dRegFileIndex)) > 1
                                    vdClosestRegistrationSpecificationPerFile(vdClosestRegistrationSpecificationPerFile == vdClosestRegistrationSpecificationPerFile(dRegFileIndex)) = find(vbKeepRow);
                                    break;
                                end
                            end
                        else
                            vdRegFileIndicesToResolve = find(vbKeepRow);
                            
                            m2dRegDifferenceNormPerFilePerSpecification = m2dRegDifferenceNormPerFilePerSpecification(vdRegFileIndicesToResolve,:);
                            
                            vdRegSpecIndicesToResolve = 1:dNumRegSpecs;
                            
                            m2dRegDifferenceNormPerFilePerSpecification(:,vdClosestRegistrationSpecificationPerFile(~vbKeepRow)) = [];
                            vdRegSpecIndicesToResolve(vdClosestRegistrationSpecificationPerFile(~vbKeepRow)) = [];
                            
                            for dResolveIndex=1:length(vdRegFileIndicesToResolve)
                                [~, dMinIndex] = min(m2dRegDifferenceNormPerFilePerSpecification(:));
                                
                                [dMinRegFileIndex, dMinRegSpecIndex] = ind2sub(size(m2dRegDifferenceNormPerFilePerSpecification), dMinIndex);
                                
                                vdClosestRegistrationSpecificationPerFile(vdRegFileIndicesToResolve(dMinRegFileIndex)) = vdRegSpecIndicesToResolve(dMinRegSpecIndex);
                                
                                vdRegFileIndicesToResolve(dMinRegFileIndex) = [];
                                m2dRegDifferenceNormPerFilePerSpecification(dMinRegFileIndex,:) = [];
                                m2dRegDifferenceNormPerFilePerSpecification(:,dMinRegSpecIndex) = [];
                                vdRegSpecIndicesToResolve(dMinRegSpecIndex) = [];
                            end
                        end
                    end
                    
                    if length(unique(vdClosestRegistrationSpecificationPerFile)) ~= length(vdClosestRegistrationSpecificationPerFile) % there are STILL duplicates
                        error(...
                            'DicomImporter:ImportPreTreatmentDataForPatient:RegistrationFileAndSpecificationMismatch',...
                            'The registration files could not be matched to registrations specifications listed in Pinnacle.');
                    end
                    
                    vsRegFilePathPerRegistrationSpecification = strings(dNumRegSpecs,1);
                    
                    if isempty(sMRT1wPostRegistrationPath)
                        sRegistrationPath = sMRT2wRegistrationPath;
                    else
                        sRegistrationPath = sMRT1wPostRegistrationPath;
                    end
                    
                    for dRegSpecIndex=1:dNumRegSpecs
                        vsRegFilePathPerRegistrationSpecification(dRegSpecIndex) = string(fullfile(sRegistrationPath, voRegFileEntries(vdClosestRegistrationSpecificationPerFile==dRegSpecIndex).name));
                    end
                    
                    varargin = [varargin, {'FilePathPerRegistration', vsRegFilePathPerRegistrationSpecification}];
                end
            end
            
            sRTStructPath = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "RT Struct") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(sRTStructPath)
                varargin = [varargin, {'RTStruct', sRTStructPath}];
            end
            
            vsRTDosePaths = m2sDicomDataCuration( m2sDicomDataCuration(:, vsCurationDataHeaders == "RT Dose") == "X", vsCurationDataHeaders == "Imported To");
            
            if ~isempty(vsRTDosePaths)
                varargin = [varargin, {'RTDose', vsRTDosePaths}];
            end
            
            % set to patient
            if sTreatmentPlanningSystem == "RayStation"
                oTreatmentPlan.SetPreTreatmentImagingSeriesPathsAndRegistrationMatches(varargin{:});
            else
                oTreatmentPlan.SetPreTreatmentImagingSeriesPathsAndRegistrationFilePaths(varargin{:});
            end
            
            % write import path to dicom data curation file
            writematrix(m2sDicomDataCuration, chDicomDataCurationFilePath, 'Sheet', StringUtils.num2str_PadWithZeros(dPatientIdToImport, 4));
        end
        
        
        function m2sCurationData = GetPreTreatmentDicomCurationDataForPatient(oStudyDatabase, dPatientId, chDownloadCachePath, vsHeaders, sPatientTreatmentPlanningSystem)
            arguments
                oStudyDatabase
                dPatientId
                chDownloadCachePath
                vsHeaders
                sPatientTreatmentPlanningSystem (1,1) string {mustBeMember(sPatientTreatmentPlanningSystem, ["RayStation","Pinnacle","Generic"])}
            end
            
            oPatient = oStudyDatabase.GetPatientByPrimaryId(dPatientId);
            oTreatmentPlan = oPatient.GetFirstBrainRadiationCourseTreatmentPlan();
            
            sPatientDicomDatabaseFolder = DicomImporter.GetDicomDatabasePatientFolderNameForPatientId(dPatientId);
            
            if ~isfolder(fullfile(chDownloadCachePath, sPatientDicomDatabaseFolder))
                error("Patient " + string(num2str(dPatientId)) + " data not downloaded.");
            end
            
            
            chRootDir = fullfile(chDownloadCachePath, sPatientDicomDatabaseFolder, sPatientDicomDatabaseFolder + " " + sPatientDicomDatabaseFolder);
            
            
            % find out what series we're working with
            voStudyEntries = dir(chRootDir);
            voStudyEntries = voStudyEntries(3:end);
            dNumStudies = length(voStudyEntries);
            
            dNumSeries = 0;
            
            for dStudyIndex=1:dNumStudies
                dNumSeries = dNumSeries + (length(dir(fullfile(chRootDir, voStudyEntries(dStudyIndex).name))) - 2); % -2 to remove . and ..
            end
            
            m2sCurationData = strings(dNumSeries, length(vsHeaders));
            vsFullPathPerSeries = strings(dNumSeries, 1);
            
            
            
            stSeriesTracking = struct(...
                'vsCTSeriesFolderPaths', string.empty,...
                'vsCTSeriesDescriptions', string.empty,...
                'vsCTSeriesStudyID', string.empty,...
                'voCTSeriesDates', datetime.empty,...
                ...
                'vsMRSeriesFolderPaths', string.empty,...
                'vsMRSeriesDescriptions', string.empty,...
                'vsMRSeriesStudyID', string.empty,...
                'voMRSeriesDates', datetime.empty,...
                ...
                'vsRTDoseSeriesFolderPaths', string.empty,...
                'vsRTPlanSeriesFolderPaths', string.empty,...
                'vsRTStructSeriesFolderPaths', string.empty,...
                'vsRegistrationSeriesFolderPaths', string.empty);
            
            
            dSeriesIndex = 1;
            
            for dStudyEntryIndex=1:dNumStudies
                oStudyEntry = voStudyEntries(dStudyEntryIndex);
                
                if ~oStudyEntry.isdir
                    error('Studies must be folders');
                end
                
                voSeriesEntries = dir(fullfile(chRootDir, oStudyEntry.name));
                voSeriesEntries = voSeriesEntries(3:end);
                
                for dSeriesEntryIndex=1:length(voSeriesEntries)
                    oSeriesEntry = voSeriesEntries(dSeriesEntryIndex);
                    
                    if ~oSeriesEntry.isdir
                        error('Series must be folders');
                    end
                    
                    chSeriesName = oSeriesEntry.name;
                    
                    m2sCurationData(dSeriesIndex, vsHeaders=="Orthanc Download Folder Path") = string(fullfile(oStudyEntry.name, oSeriesEntry.name));
                    vsFullPathPerSeries(dSeriesIndex) = string(fullfile(chRootDir, oStudyEntry.name, chSeriesName));
                    
                    if strcmp(chSeriesName(1:2), 'CT')
                        stSeriesTracking.vsCTSeriesFolderPaths = [stSeriesTracking.vsCTSeriesFolderPaths; fullfile(chRootDir, oStudyEntry.name, chSeriesName)];
                        
                        stMetadata = dicominfo(fullfile(chRootDir, oStudyEntry.name, chSeriesName, 'CT000000.dcm'), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                        
                        stSeriesTracking.vsCTSeriesDescriptions = [stSeriesTracking.vsCTSeriesDescriptions; string(stMetadata.SeriesDescription)];
                        stSeriesTracking.vsCTSeriesStudyID = [stSeriesTracking.vsCTSeriesStudyID; string(stMetadata.StudyID)];
                        stSeriesTracking.voCTSeriesDates = [stSeriesTracking.voCTSeriesDates; datetime(str2double(stMetadata.StudyDate(1:4)), str2double(stMetadata.StudyDate(5:6)), str2double(stMetadata.StudyDate(7:8)))];
                    elseif strcmp(chSeriesName(1:2), 'MR')
                        stSeriesTracking.vsMRSeriesFolderPaths = [stSeriesTracking.vsMRSeriesFolderPaths; fullfile(chRootDir, oStudyEntry.name, chSeriesName)];
                        
                        stMetadata = dicominfo(fullfile(chRootDir, oStudyEntry.name, chSeriesName, 'MR000000.dcm'), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                        
                        stSeriesTracking.vsMRSeriesDescriptions = [stSeriesTracking.vsMRSeriesDescriptions; string(stMetadata.SeriesDescription)];
                        stSeriesTracking.vsMRSeriesStudyID = [stSeriesTracking.vsMRSeriesStudyID; string(stMetadata.StudyID)];
                        stSeriesTracking.voMRSeriesDates = [stSeriesTracking.voMRSeriesDates; datetime(str2double(stMetadata.StudyDate(1:4)), str2double(stMetadata.StudyDate(5:6)), str2double(stMetadata.StudyDate(7:8)))];
                    elseif contains(chSeriesName, 'RTDOSE')
                        stMetadata = dicominfo(fullfile(chRootDir, oStudyEntry.name, chSeriesName, 'RT000000.dcm'), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                        
                        stSeriesTracking.vsRTDoseSeriesFolderPaths = [stSeriesTracking.vsRTDoseSeriesFolderPaths; fullfile(chRootDir, oStudyEntry.name, chSeriesName)];
                    elseif contains(chSeriesName, 'RTPLAN')
                        stMetadata = dicominfo(fullfile(chRootDir, oStudyEntry.name, chSeriesName, 'RT000000.dcm'), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                        
                        stSeriesTracking.vsRTPlanSeriesFolderPaths = [stSeriesTracking.vsRTPlanSeriesFolderPaths; fullfile(chRootDir, oStudyEntry.name, chSeriesName)];
                    elseif contains(chSeriesName, 'RTSTRUCT')
                        stMetadata = dicominfo(fullfile(chRootDir, oStudyEntry.name, chSeriesName, 'RT000000.dcm'), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                        
                        stSeriesTracking.vsRTStructSeriesFolderPaths = [stSeriesTracking.vsRTStructSeriesFolderPaths; fullfile(chRootDir, oStudyEntry.name, chSeriesName)];
                    elseif strcmp(chSeriesName(1:3), 'REG')
                        stMetadata = dicominfo(fullfile(chRootDir, oStudyEntry.name, chSeriesName, 'RE000000.dcm'), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                        
                        stSeriesTracking.vsRegistrationSeriesFolderPaths = [stSeriesTracking.vsRegistrationSeriesFolderPaths; fullfile(chRootDir, oStudyEntry.name, chSeriesName)];
                    else
                        error('Invalid modality');
                    end
                    
                    m2sCurationData(dSeriesIndex, vsHeaders=="Study ID") = string(stMetadata.StudyID);
                    m2sCurationData(dSeriesIndex, vsHeaders=="Study Date") = string([stMetadata.StudyDate(1:4) '-' stMetadata.StudyDate(5:6) '-' stMetadata.StudyDate(7:8)]);
                    
                    dSeriesIndex = dSeriesIndex+1;
                end
            end
            
            
            % validation values
            dtFirstBrainRTDate = oPatient.GetFirstBrainRadiationCourse().GetRadiationCourseDate();
            
            dtScanCutoffDate = dtFirstBrainRTDate;
            dtScanCutoffDate.Day = eomday(dtScanCutoffDate.Year, dtScanCutoffDate.Month);
            
            dtMaxTimeBetweenScanAndBrainRT = days(60); % 2 months.
            
            % validate CTs
            dNumCTs = length(stSeriesTracking.vsCTSeriesFolderPaths);
            
            for dCTIndex=1:dNumCTs
                dtScanBrainRTTimeDifference = dtScanCutoffDate - stSeriesTracking.voCTSeriesDates(dCTIndex);
                
                if dtScanBrainRTTimeDifference < 0 || dtScanBrainRTTimeDifference > dtMaxTimeBetweenScanAndBrainRT
                    dSeriesIndex = find(vsFullPathPerSeries == stSeriesTracking.vsCTSeriesFolderPaths(dCTIndex));
                    
                    m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                    m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "Scan date does not match treatment timeline";
                end
                
                if sPatientTreatmentPlanningSystem == "RayStation"
                    if ~contains(stSeriesTracking.vsCTSeriesStudyID(dCTIndex), '(RayStation)')
                        dSeriesIndex = find(vsFullPathPerSeries == stSeriesTracking.vsCTSeriesFolderPaths(dCTIndex));
                        
                        m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                        m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "CT not exported from RayStation";
                    end
                end
                
                if sPatientTreatmentPlanningSystem == "Pinnacle"
                    if ~contains(stSeriesTracking.vsCTSeriesStudyID(dCTIndex), '(Pinnacle)')
                        dSeriesIndex = find(vsFullPathPerSeries == stSeriesTracking.vsCTSeriesFolderPaths(dCTIndex));
                        
                        m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                        m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "CT not exported from Pinnacle";
                    end
                end
            end
            
            
            % validate MRs
            dNumMRs = length(stSeriesTracking.vsMRSeriesFolderPaths);
            
            for dMRIndex=1:dNumMRs
                dtScanBrainRTTimeDifference = dtScanCutoffDate - stSeriesTracking.voMRSeriesDates(dMRIndex);
                
                if dtScanBrainRTTimeDifference < 0 || dtScanBrainRTTimeDifference > dtMaxTimeBetweenScanAndBrainRT
                    dSeriesIndex = find(vsFullPathPerSeries == stSeriesTracking.vsMRSeriesFolderPaths(dMRIndex));
                    
                    m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                    m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "Scan date does not match treatment timeline";
                end
                
                if sPatientTreatmentPlanningSystem == "RayStation"
                    if ~contains(stSeriesTracking.vsMRSeriesStudyID(dMRIndex), '(RayStation)') && ~contains(stSeriesTracking.vsMRSeriesStudyID(dMRIndex), '(GE PACS)')
                        dSeriesIndex = find(vsFullPathPerSeries == stSeriesTracking.vsMRSeriesFolderPaths(dMRIndex));
                        
                        m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                        m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "MR not exported from RayStation nor GE PACS";
                    end
                end
                
                if sPatientTreatmentPlanningSystem == "Pinnacle"
                    if ~contains(stSeriesTracking.vsMRSeriesStudyID(dMRIndex), '(Pinnacle)') && ~contains(stSeriesTracking.vsMRSeriesStudyID(dMRIndex), '(GE PACS)')
                        dSeriesIndex = find(vsFullPathPerSeries == stSeriesTracking.vsMRSeriesFolderPaths(dMRIndex));
                        
                        m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                        m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "MR not exported from Pinnacle nor GE PACS";
                    end
                end
            end
            
            
            % - Remove duplicates
            
            c1vsSeriesPathPerSeriesPerRepeat = DicomImporter.GroupDuplicateDicomSeriesFolderNames("", stSeriesTracking.vsMRSeriesFolderPaths);
            
            vsMRSeriesCopyFromPaths = string.empty;
            vsMRSeriesCopyToPaths = string.empty;
            
            for dUniqueSeriesIndex=1:length(c1vsSeriesPathPerSeriesPerRepeat)
                vsSeriesPathPerRepeat = c1vsSeriesPathPerSeriesPerRepeat{dUniqueSeriesIndex};
                
                dNumRepeats = length(vsSeriesPathPerRepeat);
                
                if dNumRepeats ~= 1
                    vsStudyIdPerRepeat = strings(dNumRepeats,1);
                    
                    for dRepeatIndex=1:dNumRepeats
                        vsStudyIdPerRepeat(dRepeatIndex) = stSeriesTracking.vsMRSeriesStudyID(stSeriesTracking.vsMRSeriesFolderPaths == vsSeriesPathPerRepeat(dRepeatIndex));
                    end
                    
                    vdRayStationIndices = find(contains(vsStudyIdPerRepeat, "(RayStation)"));
                    
                    if numel(vdRayStationIndices) == 0
                        % just choose the first repeat then,
                        % doesn't really matter
                        sMasterSeriesPath = vsSeriesPathPerRepeat(1);
                        vsSeriesPathsForRepeats = vsSeriesPathPerRepeat(2:end);
                    elseif numel(vdRayStationIndices) == 1
                        % choose the RayStation copy
                        vbIsRepeat = true(size(vsStudyIdPerRepeat));
                        vbIsRepeat(vdRayStationIndices(1)) = false;
                        
                        sMasterSeriesPath = vsSeriesPathPerRepeat(vdRayStationIndices(1));
                        vsSeriesPathsForRepeats = vsSeriesPathPerRepeat(vbIsRepeat);
                    else
                        % multiple RayStation matches
                        vbIsRepeat = true(size(vsStudyIdPerRepeat));
                        vbIsRepeat(vdRayStationIndices(1)) = false;
                        
                        sMasterSeriesPath = vsSeriesPathPerRepeat(vdRayStationIndices(2)); % ensure repeat is from another RayStation entry
                        vsSeriesPathsForRepeats = vsSeriesPathPerRepeat(vbIsRepeat);
                    end
                    
                    sRepeatedSeriesPath = m2sCurationData(vsFullPathPerSeries == sMasterSeriesPath, vsHeaders == "Orthanc Download Folder Path");
                    
                    for dRepeatIndex=1:length(vsSeriesPathsForRepeats)
                        dSeriesIndex = find(vsFullPathPerSeries == vsSeriesPathsForRepeats(dRepeatIndex));
                        
                        m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                        m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "Repeat of: " + sRepeatedSeriesPath;
                    end
                end
            end
            
            
            % Import registrations
            vsRegFolderPaths = stSeriesTracking.vsRegistrationSeriesFolderPaths;
            dNumRegFolders = length(vsRegFolderPaths);
            
            if sPatientTreatmentPlanningSystem == "RayStation"
                for dFolderIndex=1:dNumRegFolders
                    sFolderPath = vsRegFolderPaths(dFolderIndex);
                    
                    stMetadata = dicominfo(fullfile(vsRegFolderPaths(dFolderIndex), 'RE000000.dcm'), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                    
                    if isfield(stMetadata, 'SeriesTime')
                        chSeriesTime = stMetadata.SeriesTime;
                    else
                        chSeriesTime = '000000';
                    end
                    
                    dSeriesIndex = find(vsFullPathPerSeries == sFolderPath);
                    m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "Series Time: " + string(chSeriesTime(1:2)) + ":" + string(chSeriesTime(3:4)) + ":" + string(chSeriesTime(5:6));
                end
            end
            
            % Import RT structs
            vsRTStructFolderPaths = stSeriesTracking.vsRTStructSeriesFolderPaths;
            dNumRTStructFolders = length(vsRTStructFolderPaths);
            
            if sPatientTreatmentPlanningSystem == "RayStation"
                for dFolderIndex=1:dNumRTStructFolders
                    sFolderPath = vsRTStructFolderPaths(dFolderIndex);
                    
                    if contains(sFolderPath, "Unapproved", "IgnoreCase", true)
                        dSeriesIndex = find(vsFullPathPerSeries == sFolderPath);
                        
                        m2sCurationData(dSeriesIndex, vsHeaders == "Remove") = "X";
                        m2sCurationData(dSeriesIndex, vsHeaders == "Notes") = "Unapproved RT Structs are avoided to use Approved RT Structs instead.";
                    end
                end
            end
            
            m2sCurationData = [vsHeaders; m2sCurationData];
        end
        
        
        function sPatientDicomDatabaseFolder = GetDicomDatabasePatientFolderNameForPatientId(dPatientId)
            sPatientDicomDatabaseFolder = StudyConstants.sAnonymizationStudyTag + " " + string(StringUtils.num2str_PadWithZeros(dPatientId, StudyConstants.dPatientStudyIdNumDigits));
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function dPatientId = GetPatientIdFromDicomPatientIDField(chPatientId)
            arguments
                chPatientId (1,:) char
            end
            
            dPatientId = [];
            
            if contains(chPatientId, StudyConstants.sAnonymizationStudyTag)
                dPatientId = str2double(chPatientId(length(char(StudyConstants.sAnonymizationStudyTag))+2 : end));
                
                if isnan(dPatientId)
                    dPatientId = [];
                end
            end
        end
        
        function stSeriesTracking = GetSeriesPathsFromMRFolder(chImportFromPath, stSeriesTracking, bIsMRSim)
            [vsFolderNames, vbIsDir] = FileIOUtils.DirGetNamesAndIsDir(chImportFromPath);
            
            if any(~vbIsDir)
                error(...
                    'DicomImporter:GetSeriesPathsFromMRFolder:FreeFile',...
                    'There should be no free files among the series folders.');
            end
            
            dNumSeries = length(vsFolderNames);
            
            
            % remove series that have files that don't contain patient
            % geometry information. These are likely screen caps or file
            % scans, so we don't want them
            
            vbRemove = false(size(vsFolderNames));
            
            for dFolderIndex=1:length(vsFolderNames)
                sFolderName = vsFolderNames(dFolderIndex);
                
                voEntries = dir(fullfile(chImportFromPath, sFolderName));
                chFirstFilename = voEntries(3).name;
                
                stFirstFileMetadata = dicominfo(fullfile(chImportFromPath, sFolderName, chFirstFilename), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                
                if ~isfield(stFirstFileMetadata, 'ImageOrientationPatient') || isempty(stFirstFileMetadata.ImageOrientationPatient)
                    vbRemove(dFolderIndex) = true;
                end
            end
            
            vsFolderNamesToRemove = vsFolderNames(vbRemove);
            
            if bIsMRSim
                stSeriesTracking.vsMRSimNonImagingSeries = vsFolderNamesToRemove;
            else
                stSeriesTracking.vsMRDiagNonImagingSeries = vsFolderNamesToRemove;
            end
            
            vsFolderNames = vsFolderNames(~vbRemove);
            
            dNumNoGeometry = sum(vbRemove);
            
            
            % compile the list of series names and repeats
            c1vsSeriesPerSeriesPerRepeat = DicomImporter.GroupDuplicateDicomSeriesFolderNames(chImportFromPath, vsFolderNames);
            
            dNumSeries = length(c1vsSeriesPerSeriesPerRepeat);
            
            vsSeriesNames = strings(dNumSeries,1);
            
            for dSeriesIndex=1:dNumSeries
                [~,chFolderName] = FileIOUtils.SeparateFilePathAndFilename(c1vsSeriesPerSeriesPerRepeat{dSeriesIndex}(1));
                vsSeriesNames(dSeriesIndex) = string(chFolderName);
            end
            
            if length(unique(vsSeriesNames)) ~= length(vsSeriesNames)
                error(...
                    'DicomImporter:GetSeriesPathsFromMRFolder:DuplicateSeriesNames',...
                    'Duplicate series names.');
            end
            
            if bIsMRSim
                stSeriesTracking.c1vsMRSimSeriesPathPerSeriesPerRepeat = c1vsSeriesPerSeriesPerRepeat;
                stSeriesTracking.vsMRSimSeriesNamePerSeries = vsSeriesNames;
            else
                stSeriesTracking.c1vsMRDiagSeriesPathPerSeriesPerRepeat = c1vsSeriesPerSeriesPerRepeat;
                stSeriesTracking.vsMRDiagSeriesNamePerSeries = vsSeriesNames;
            end
        end
        
        function stSeriesTracking = ImportGeneralPreTreatmentFolder(chImportFromPath, stSeriesTracking)
            %[stPreTreatmentDataTracking, dNumSeries, dNumRepeats, dNumCTSeriesImported, dNumCTSeriesInvalid, dNumRTDoseImported, dNumRTDoseInvalid, dNumRTPlanImported, dNumRTPlanInvalid, dNumRTStructImported, dNumRTStructInvalid, dNumRegistrationImported, dNumRegistrationInvalid]
            
            [vsFolderNames, vbIsDir] = FileIOUtils.DirGetNamesAndIsDir(chImportFromPath);
            
            if any(~vbIsDir)
                error(...
                    'DicomImporter:ImportGeneralPreTreatmentFolder:FreeFile',...
                    'There should be no free files among the series folders.');
            end
            
            c1vsSeriesPathPerSeriesPerRepeat = DicomImporter.GroupDuplicateDicomSeriesFolderNames(chImportFromPath, vsFolderNames);
            
            
            
            % process CT folders
            dNumSeries = length(c1vsSeriesPathPerSeriesPerRepeat);
            
            vbIsCTSim = false(dNumSeries,1);
            
            for dSeriesIndex=1:dNumSeries
                [~, chFolderName] = FileIOUtils.SeparateFilePathAndFilename(c1vsSeriesPathPerSeriesPerRepeat{dSeriesIndex}(1));
                vbIsCTSim(dSeriesIndex) = startsWith(chFolderName, DicomImporter.chCTSimExportFolderName);
            end
            
            if any(vbIsCTSim)
                if ~isempty(stSeriesTracking.c1vsCTSimSeriesPathPerCTSimPerRepeat)
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:CTSimsAlreadyImported',...
                        'There were CT sims already imported for another study.');
                end
                
                stSeriesTracking.c1vsCTSimSeriesPathPerCTSimPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(vbIsCTSim);
                
                c1vsSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(~vbIsCTSim);
            end
            
            
            
            % process RT Dose folders
            dNumSeries = length(c1vsSeriesPathPerSeriesPerRepeat);
            
            vbIsRTDose = false(dNumSeries,1);
            
            for dSeriesIndex=1:dNumSeries
                [~, chFolderName] = FileIOUtils.SeparateFilePathAndFilename(c1vsSeriesPathPerSeriesPerRepeat{dSeriesIndex}(1));
                vbIsRTDose(dSeriesIndex) = startsWith(chFolderName, DicomImporter.chRTDoseExportFolderPrefix);
            end
            
            c1vsRTDoseSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(vbIsRTDose);
            c1vsSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(~vbIsRTDose);
            
            for dRTDoseSeriesIndex=1:length(c1vsRTDoseSeriesPathPerSeriesPerRepeat)
                vsRTDoseSeriesPathPerRepeat = c1vsRTDoseSeriesPathPerSeriesPerRepeat{dRTDoseSeriesIndex};
                
                if ~isscalar(vsRTDoseSeriesPathPerRepeat)
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:RepeatedRTDose',...
                        'There should be no repeated RT Dose instances.');
                end
                
                sSeriesPath = vsRTDoseSeriesPathPerRepeat;
                
                voCheckEntries = dir(sSeriesPath);
                
                if length(voCheckEntries) ~= 3
                    stSeriesTracking.vsInvalidRTDoseFilePaths = [stSeriesTracking.vsInvalidRTDoseFilePaths; sSeriesPath];
                else
                    stSeriesTracking.vsRTDoseFilePaths = [stSeriesTracking.vsRTDoseFilePaths; fullfile(sSeriesPath, DicomImporter.chRTDicomExportFilename)];
                end
            end
            
            
            
            % process RT Plan folders
            dNumSeries = length(c1vsSeriesPathPerSeriesPerRepeat);
            
            vbIsRTPlan = false(dNumSeries,1);
            
            for dSeriesIndex=1:dNumSeries
                [~, chFolderName] = FileIOUtils.SeparateFilePathAndFilename(c1vsSeriesPathPerSeriesPerRepeat{dSeriesIndex}(1));
                vbIsRTPlan(dSeriesIndex) = startsWith(chFolderName, DicomImporter.chRTPlanExportFolderPrefix);
            end
            
            c1vsRTPlanSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(vbIsRTPlan);
            c1vsSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(~vbIsRTPlan);
            
            for dRTPlanSeriesIndex=1:length(c1vsRTPlanSeriesPathPerSeriesPerRepeat)
                vsRTPlanSeriesPathPerRepeat = c1vsRTPlanSeriesPathPerSeriesPerRepeat{dRTPlanSeriesIndex};
                
                if ~isscalar(vsRTPlanSeriesPathPerRepeat)
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:RepeatedRTPlan',...
                        'There should be no repeated RT Plan instances.');
                end
                
                sSeriesPath = vsRTPlanSeriesPathPerRepeat;
                
                voCheckEntries = dir(sSeriesPath);
                
                if length(voCheckEntries) ~= 3
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:InvalidRTPlanSeriesFolder',...
                        'An RT Plan series folder cannot contain multiple files.');
                else
                    stSeriesTracking.vsRTPlanFilePaths = [stSeriesTracking.vsRTPlanFilePaths; fullfile(sSeriesPath, DicomImporter.chRTDicomExportFilename)];
                end
            end
            
            
            
            % process RT struct folders
            dNumSeries = length(c1vsSeriesPathPerSeriesPerRepeat);
            
            vbIsRTStruct = false(dNumSeries,1);
            
            for dSeriesIndex=1:dNumSeries
                [~, chFolderName] = FileIOUtils.SeparateFilePathAndFilename(c1vsSeriesPathPerSeriesPerRepeat{dSeriesIndex}(1));
                vbIsRTStruct(dSeriesIndex) = startsWith(chFolderName, DicomImporter.chRTStructExportFolderPrefix);
            end
            
            c1vsRTStructSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(vbIsRTStruct);
            c1vsSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(~vbIsRTStruct);
            
            for dRTStructSeriesIndex=1:length(c1vsRTStructSeriesPathPerSeriesPerRepeat)
                vsRTStructSeriesPathPerRepeat = c1vsRTStructSeriesPathPerSeriesPerRepeat{dRTStructSeriesIndex};
                
                if ~isscalar(vsRTStructSeriesPathPerRepeat)
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:RepeatedRTStruct',...
                        'There should be no repeated RT Struct instances.');
                end
                
                sSeriesPath = vsRTStructSeriesPathPerRepeat;
                
                voCheckEntries = dir(sSeriesPath);
                
                if length(voCheckEntries) ~= 3
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:InvalidRTStructSeriesFolder',...
                        'An RT Struct series folder cannot contain multiple files.');
                else
                    [~, sExportFolderName] = FileIOUtils.SeparateFilePathAndFilename(sSeriesPath);
                    
                    bIsApprovedStructFile = logical.empty;
                    
                    if contains(sExportFolderName, DicomImporter.chRTStructExportApprovedFilenameKeyword)
                        bIsApprovedStructFile = true;
                    elseif contains(sExportFolderName, DicomImporter.chRTStructExportUnapprovedFilenameKeyword)
                        bIsApprovedStructFile = false;
                    end
                    
                    if isempty(bIsApprovedStructFile)
                        error(...
                            'DicomImporter:ImportGeneralPreTreatmentFolder:InvalidRTStructSeriesName',...
                            'The RT struct series must be approved or unapproved.');
                    end
                    
                    if bIsApprovedStructFile
                        if ~isempty(stSeriesTracking.sRTStructApprovedFilePath)
                            error(...
                                'DicomImporter:ImportGeneralPreTreatmentFolder:ApprovedRTStructAlreadyImported',...
                                'The approved RT struct was already imported.');
                        end
                        
                        stSeriesTracking.sRTStructApprovedFilePath = fullfile(sSeriesPath, DicomImporter.chRTDicomExportFilename);
                    else
                        if ~isempty(stSeriesTracking.sRTStructUnapprovedFilePath)
                            error(...
                                'DicomImporter:ImportGeneralPreTreatmentFolder:UnapprovedRTStructAlreadyImported',...
                                'The unapproved RT struct was already imported.');
                        end
                        
                        stSeriesTracking.sRTStructUnapprovedFilePath = fullfile(sSeriesPath, DicomImporter.chRTDicomExportFilename);
                    end
                end
            end
            
            
            
            % Process registration series
            dNumSeries = length(c1vsSeriesPathPerSeriesPerRepeat);
            
            vbIsReg = false(dNumSeries,1);
            
            for dSeriesIndex=1:dNumSeries
                [~, chFolderName] = FileIOUtils.SeparateFilePathAndFilename(c1vsSeriesPathPerSeriesPerRepeat{dSeriesIndex}(1));
                vbIsReg(dSeriesIndex) = startsWith(chFolderName, DicomImporter.chRegistrationExportFolderPrefix);
            end
            
            c1vsRegSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(vbIsReg);
            c1vsSeriesPathPerSeriesPerRepeat = c1vsSeriesPathPerSeriesPerRepeat(~vbIsReg);
            
            for dRegSeriesIndex=1:length(c1vsRegSeriesPathPerSeriesPerRepeat)
                vsRegSeriesPathPerRepeat = c1vsRegSeriesPathPerSeriesPerRepeat{dRegSeriesIndex};
                
                if ~isscalar(vsRegSeriesPathPerRepeat)
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:RepeatedReg',...
                        'There should be no repeated Reg instances.');
                end
                
                sSeriesPath = vsRegSeriesPathPerRepeat;
                
                voCheckEntries = dir(sSeriesPath);
                
                if length(voCheckEntries) ~= 3
                    error(...
                        'DicomImporter:ImportGeneralPreTreatmentFolder:InvalidRegSeriesFolder',...
                        'An Reg series folder cannot contain multiple files.');
                else
                    stSeriesTracking.vsRegistrationFilePaths = [stSeriesTracking.vsRegistrationFilePaths; fullfile(sSeriesPath, DicomImporter.chRegistrationExportFilename)];
                end
            end
            
            
            % check all folders imported
            if ~isempty(c1vsSeriesPathPerSeriesPerRepeat)
                error(...
                    'DicomImporter:ImportGeneralPreTreatmentFolder:NotAllFoldersImported',...
                    'Not all folders imported.');
            end
        end
        
        function bAreDuplicates = AreDicomSeriesFoldersDuplicates(chDicomDirPath1, chDicomDirPath2)
            bAreDuplicates = false;
            
            % 1) Check that same files are in both directories
            voEntries = dir(chDicomDirPath1);
            voEntries = voEntries(3:end);
            dNumEntries = length(voEntries);
            
            vsDicomDir1Filenames = strings(dNumEntries,1);
            
            for dSearchEntryIndex=1:dNumEntries
                if voEntries(dSearchEntryIndex).isdir
                    error(...
                        'DicomImporter:AreDicomSeriesFoldersDuplicates:InvalidSeriesFile',...
                        'Only files should be within a series folder.');
                end
                
                vsDicomDir1Filenames(dSearchEntryIndex) = voEntries(dSearchEntryIndex).name;
            end
            
            % filenames from repeated dir
            voEntries = dir(chDicomDirPath2);
            voEntries = voEntries(3:end);
            dNumEntries = length(voEntries);
            
            vsDicomDir2Filenames = strings(dNumEntries,1);
            
            for dSearchEntryIndex=1:dNumEntries
                if voEntries(dSearchEntryIndex).isdir
                    error(...
                        'DicomImporter:AreDicomSeriesFoldersDuplicates:InvalidSeriesFile',...
                        'Only files should be within a series folder.');
                end
                
                vsDicomDir2Filenames(dSearchEntryIndex) = voEntries(dSearchEntryIndex).name;
            end
            
            if length(intersect(vsDicomDir2Filenames, vsDicomDir1Filenames)) == length(vsDicomDir2Filenames)
                % 2) Check that at least one file is the same
                xDicomDir1FirstFileData = dicomread(fullfile(chDicomDirPath1, vsDicomDir1Filenames(1)));
                stDicomDir1FirstFileMetadata = dicominfo(fullfile(chDicomDirPath1, vsDicomDir1Filenames(1)), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                
                if isfield(stDicomDir1FirstFileMetadata, 'InstanceNumber')
                    
                    for dFileIndex=1:length(vsDicomDir2Filenames)
                        stDicomDir2FileMetadata = dicominfo(fullfile(chDicomDirPath2, vsDicomDir2Filenames(dFileIndex)), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                        
                        if stDicomDir1FirstFileMetadata.InstanceNumber == stDicomDir2FileMetadata.InstanceNumber
                            xDicomDir2FirstFileData = dicomread(fullfile(chDicomDirPath2, vsDicomDir1Filenames(dFileIndex)));
                            
                            if ~isempty(xDicomDir1FirstFileData) && numel(xDicomDir1FirstFileData) == numel(xDicomDir2FirstFileData) && all(xDicomDir1FirstFileData(:) == xDicomDir2FirstFileData(:))
                                bAreDuplicates = true;
                            end
                            
                            break;
                        end
                    end
                end
            end
        end
        
        function c1vsSeriesPathPerSeriesPerRepeat = GroupDuplicateDicomSeriesFolderNames(sPath, vsFolderNames)
            arguments
                sPath (1,1) string
                vsFolderNames (:,1) string
            end
            
            vsFolderNames = sort(vsFolderNames, 'ascend');
            dNumFolders = length(vsFolderNames);
            
            vdSeriesNumberPerFolder = zeros(dNumFolders,1);
            dCurrentSeriesNumber = 0;
            
            for dFolderIndex=1:dNumFolders
                if vdSeriesNumberPerFolder(dFolderIndex) == 0 % hasn't already been searched
                    
                    dCurrentSeriesNumber = dCurrentSeriesNumber + 1;
                    vdSeriesNumberPerFolder(dFolderIndex) = dCurrentSeriesNumber;
                    
                    for dFolderSearchIndex=dFolderIndex+1:dNumFolders
                        if vdSeriesNumberPerFolder(dFolderSearchIndex) == 0 % hasn't already been searched
                            if DicomImporter.AreDicomSeriesFoldersDuplicates(...
                                    fullfile(sPath, vsFolderNames(dFolderIndex)),...
                                    fullfile(sPath, vsFolderNames(dFolderSearchIndex)))
                                
                                vdSeriesNumberPerFolder(dFolderSearchIndex) = dCurrentSeriesNumber;
                            end
                        end
                    end
                    
                end
            end
            
            dNumSeries = dCurrentSeriesNumber;
            
            c1vsSeriesPathPerSeriesPerRepeat = cell(dNumSeries,1);
            
            for dSeriesIndex=1:dNumSeries
                c1vsSeriesPathPerSeriesPerRepeat{dSeriesIndex} = fullfile(sPath, vsFolderNames(vdSeriesNumberPerFolder == dSeriesIndex));
            end
        end
        
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

