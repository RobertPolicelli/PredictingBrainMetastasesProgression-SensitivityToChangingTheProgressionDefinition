classdef REDCapStudyDatabase < handle
    %REDCapStudyDatabase
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voPatients (1,:) REDCapPatient = REDCapPatient.empty(1,0)
    end
    
    properties (Constant = true, GetAccess = private)
        chDatabaseMatfileVarName = 'oDatabase'
        sExperimentAssetTypeCode = "RDB"
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapStudyDatabase(voPatients)
            %obj = PatientDatabase()
            
            arguments
                voPatients (1,:) REDCapPatient = REDCapPatient.empty(1,:)
            end
            
            obj.voPatients = voPatients;
        end
        
        function Update(obj)
            % update contained objects
            
            for dPatientIndex=1:length(obj.voPatients)
                disp(['Patient : ', num2str(dPatientIndex)]);
                
                obj.voPatients(dPatientIndex).Update();
            end
        end
        
        function AddPatient(obj, oPatient)
            %addPatients(obj, patient)
            
            if isempty(obj.FindPatient(oPatient))
                obj.voPatients = [obj.voPatients, oPatient];
            else
                error(['Patient with same Primary ID already exists: ', num2str(oPatient.GetPrimaryId())]);
            end
        end
        
        function AddPatients(obj, voPatients)
            %addPatients(obj, patients)
            
            for dNewPatientIndex=1:length(voPatients)
                obj.AddPatient(voPatients(dNewPatientIndex));
            end
        end
        
        function oFoundPatient = FindPatient(obj, oPatient)
            oFoundPatient = [];
            
            for dPatientIndex=1:length(obj.voPatients)
                if obj.voPatients(dPatientIndex).GetPrimaryId() == oPatient.GetPrimaryId()
                    oFoundPatient = obj.voPatients(dPatientIndex);
                    break;
                end
            end
        end
        
        function SortPatientsByPrimaryId(obj)
            vdPrimaryIds = obj.GetAllPrimaryIds();
            dNumPatients = length(obj.voPatients);
            
            [~,vdSortIndex] = sort(vdPrimaryIds, 'ascend');
            
            obj.voPatients = obj.voPatients(vdSortIndex);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> DATABASE QUERYING <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function [c2xQueryResults, c2chColumnHeaders] = ExecuteQuery(obj, oDatabaseQuery)
            [c2xQueryResults, c2chColumnHeaders] = oDatabaseQuery.Execute(obj);
        end
        
        function ExportQueryToXls(obj, chWritePath, varargin)
            
            for dSheetIndex=1:2:length(varargin)
                [c2xQueryResults, c2chColumnHeaders] = obj.ExecuteQuery(varargin{dSheetIndex+1});
                
                c2xQueryResults = DatabaseQuery.ConvertResultsToStringOrNumeric(c2xQueryResults);
                
                % write sheet
                writecell(...
                    [c2chColumnHeaders; c2xQueryResults],...
                    chWritePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', varargin{dSheetIndex});
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> LOAD / SAVE <<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function Save(obj, chSavePath)
            arguments
                obj (1,1) REDCapStudyDatabase
                chSavePath (1,:) char = ''
            end
            
            if isempty(chSavePath)
                chResultsDir = Experiment.GetResultsDirectory();
                
                vdIndices = strfind(chResultsDir, 'Results');
                dLastIndex = vdIndices(end);
                
                chExperimentRootPath = chResultsDir(1:dLastIndex-2);
                
                vdSlashIndices = strfind(chExperimentRootPath, filesep);
                
                chExpTypeCode = chExperimentRootPath(vdSlashIndices(end-1)+1:vdSlashIndices(end)-1);
                
                chExpName = chExperimentRootPath(vdSlashIndices(end)+1:end);
                
                vdSpaceIndices = strfind(chExpName, ' ');
                
                if isempty(vdSpaceIndices)
                    chExpCode = chExpName;
                else
                    chExpCode = chExpName(1:vdSpaceIndices(1)-1);
                end
                
                if ~strcmp(chExpTypeCode, REDCapStudyDatabase.sExperimentAssetTypeCode)
                    error(...
                        'REDCapStudyDatabase:Save:InvalidExperimentCode',...
                        "The experiment must have an experiment asset type code of " + REDCapStudyDatabase.sExperimentAssetTypeCode);
                end
                
                chAssetIdTag = [chExpTypeCode, '-', chExpCode];
                
                chSavePath = fullfile(chResultsDir, [chAssetIdTag, '.mat']);
            end
            
            FileIOUtils.SaveMatFile(chSavePath, REDCapStudyDatabase.chDatabaseMatfileVarName, obj, '-v7', '-nocompression');
        end
        
        % See Public, Static methods for "Load"
        
        
        % >>>>>>>>>>>>>>>>>>>>> PATIENT GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        
        function voPatients = GetPatients(obj)
            voPatients = obj.voPatients;
        end
        
        function voPatients = GetPatientsByPrimaryIds(obj, vdPrimaryIds)
            dNumIds = length(vdPrimaryIds);
            
            % pre-allocate
            voPatients = repmat(obj.voPatients(1), dNumIds, 1);
            
            % find patients
            for dIdIndex=1:dNumIds
                oFoundPatient = obj.GetPatientByPrimaryId(vdPrimaryIds(dIdIndex));
                
                if isempty(oFoundPatient)
                    error(...
                        'REDCapStudyDatabase:GetPatientsByPrimaryIds:IdNotFound',...
                        ['No Patient with the Primary ID: ', num2str(vdPrimaryIds(dIdIndex)), ' was found in the database.']);
                else
                    voPatients(dIdIndex) = oFoundPatient;
                end
            end
            
        end
        
        function oFoundPatient = GetPatientByPrimaryId(obj, dPrimaryId)
            oFoundPatient = DatabasePatient.empty;
            
            for dPatientIndex=1:length(obj.voPatients)
                if obj.voPatients(dPatientIndex).GetPrimaryId() == dPrimaryId
                    oFoundPatient = obj.voPatients(dPatientIndex);
                    break;
                end
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dNumPatients = GetNumberOfPatients(obj)
            dNumPatients = length(obj.voPatients);
        end
        
        function voBMs = GetBrainMetastases(obj)
            dNumBMs = 0;
            
            for dPatientIndex=1:length(obj.voPatients)
                dNumBMs = dNumBMs + obj.voPatients(dPatientIndex).GetNumberOfBrainMetastases();
            end
            
            c1oBMs = cell(dNumBMs,1);
            dBMInsertIndex = 1;
            
            for dPatientIndex=1:length(obj.voPatients)
                dNumBMs = obj.voPatients(dPatientIndex).GetNumberOfBrainMetastases();
                
                for dBMIndex=1:dNumBMs
                   c1oBMs{dBMInsertIndex} = obj.voPatients(dPatientIndex).GetBrainMetastasis(dBMIndex); 
                   dBMInsertIndex = dBMInsertIndex + 1;
                end
            end
            
            voBMs = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBMs);
        end
    end
    
    methods (Access = public, Static)
        
        function CalculatePatientAgeAndSurvivalFromREDCapExport(chLoadPath, chSavePath)
            c2xExcelData = readcell(chLoadPath);
            
            vsHeaders = string(c2xExcelData(1,:));
            c2xExcelData = c2xExcelData(2:end,:);
            
            vdPatientIdPerRow = c2xExcelData(:, vsHeaders == "study_id");
            vdPatientIdPerRow = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(vdPatientIdPerRow);
            
            vsREDCapRepeatInstrumentPerRow = string(c2xExcelData(:, vsHeaders == "redcap_repeat_instrument"));
            vsREDCapRepeatInstancePerRow = string(c2xExcelData(:, vsHeaders == "redcap_repeat_instance"));
            
            vdUniquePatientIds = unique(vdPatientIdPerRow);
            dNumPatients = length(vdUniquePatientIds);
            
            c1sHeadersToSave = {"Patient ID", "Patient Age at First Brain RT [Months]", "Survival Time After First Brain RT [Months]"};
            c2xDataToSave = cell(dNumPatients, length(c1sHeadersToSave));
            vbKeepPatient = true(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                dPatientId = vdUniquePatientIds(dPatientIndex);
                c2xDataToSave{dPatientIndex,1} = dPatientId;
                
                dtPatientBirthDate = c2xExcelData{vdPatientIdPerRow == dPatientId & ismissing(vsREDCapRepeatInstrumentPerRow),  vsHeaders == "patient_date_of_birth"};
                    
                if ismissing(dtPatientBirthDate)
                    vbKeepPatient(dPatientIndex) = false;
                else                
                    dtFirstBrainRadiationDate = c2xExcelData{vdPatientIdPerRow == dPatientId & vsREDCapRepeatInstrumentPerRow == "brain_radiation_course" & vsREDCapRepeatInstancePerRow == "1",  vsHeaders == "brain_rt_course_date"};
                    
                    dPatientAgeAtFirstBrainRadiation_months = calmonths(between(dtPatientBirthDate, dtFirstBrainRadiationDate));
                    c2xDataToSave{dPatientIndex,2} = dPatientAgeAtFirstBrainRadiation_months;
                    
                    
                    eDeathStatus = REDCapPatientDeathStatus.GetEnumFromREDCapCode(c2xExcelData{vdPatientIdPerRow == dPatientId & ismissing(vsREDCapRepeatInstrumentPerRow),  vsHeaders == "patient_deceased"});
                    
                    if eDeathStatus == REDCapPatientDeathStatus.NotDeceased
                        % no survival time
                    else
                        if eDeathStatus == REDCapPatientDeathStatus.Deceased
                            dtDeathDate = c2xExcelData{vdPatientIdPerRow == dPatientId & ismissing(vsREDCapRepeatInstrumentPerRow),  vsHeaders == "patient_date_of_death"};
                        elseif eDeathStatus == REDCapPatientDeathStatus.LikelyDeceased
                            dtDeathDate = c2xExcelData{vdPatientIdPerRow == dPatientId & ismissing(vsREDCapRepeatInstrumentPerRow),  vsHeaders == "patient_last_interaction_date"};
                        end
                        
                        dSurvival_months = calmonths(between(dtFirstBrainRadiationDate, dtDeathDate));
                        c2xDataToSave{dPatientIndex,3} = dSurvival_months;
                    end
                end
            end
            
            writecell([c1sHeadersToSave; c2xDataToSave(vbKeepPatient,:)], chSavePath);
        end
        
        function CollateAllPopulatedNotesFields(chLoadPath, chSavePath)
            vsNotesFields = ["patient_notes", "primary_cancer_notes", "systemic_therapy_notes", "salvage_treatment_notes", "brain_radiology_pretreatment_notes", "brain_radiology_followup_notes", "brain_radiology_last_followup_notes", "brain_radiology_conclusion_notes"];
            
            c2xExcelData = readcell(chLoadPath);
            
            vsHeaders = string(c2xExcelData(1,:));
            c2xExcelData = c2xExcelData(2:end,:);
            
            vdPatientIdPerRow = c2xExcelData(:, vsHeaders == "study_id");
            vdPatientIdPerRow = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(vdPatientIdPerRow);
            
            vsREDCapRepeatInstrumentPerRow = string(c2xExcelData(:, vsHeaders == "redcap_repeat_instrument"));
            vsREDCapRepeatInstancePerRow = string(c2xExcelData(:, vsHeaders == "redcap_repeat_instance"));
            
            c1xDefaultHeaders = {"study_id", "redcap_repeat_instrument", "redcap_repeat_instance"};
            
            for dFieldIndex=1:length(vsNotesFields)
                c1xDataToWriteHeaders = [c1xDefaultHeaders, {vsNotesFields(dFieldIndex)}];
                
                c2xDataToWrite = cell(0,length(c1xDataToWriteHeaders));
                
                for dRowIndex=1:size(c2xExcelData,1)
                    if ~ismissing(string(c2xExcelData{dRowIndex, vsHeaders == vsNotesFields(dFieldIndex)}))
                        c1xDataToAdd = {...
                            c2xExcelData{dRowIndex, vsHeaders == "study_id"},...
                            c2xExcelData{dRowIndex, vsHeaders == "redcap_repeat_instrument"},...
                            c2xExcelData{dRowIndex, vsHeaders == "redcap_repeat_instance"},...
                            c2xExcelData{dRowIndex, vsHeaders == vsNotesFields(dFieldIndex)}};
                        
                        for dElementIndex=1:numel(c1xDataToAdd)
                            if ismissing(c1xDataToAdd{dElementIndex})
                                c1xDataToAdd{dElementIndex} = [];
                            end
                        end
                        
                        c2xDataToWrite = [c2xDataToWrite; c1xDataToAdd];
                    end
                end
                
                if ~isempty(c2xDataToWrite)
                    chSheetName = char(vsNotesFields(dFieldIndex));
                    chSheetName = chSheetName(1:min(31, length(chSheetName)));
                    
                    writecell(...
                        [c1xDataToWriteHeaders; c2xDataToWrite],...
                        chSavePath,...
                        'Sheet', chSheetName);
                end
            end
        end
        
        function obj = LoadFromREDCapExport(chLoadPath, chIdentifierBasedDataFilePath, vdPatientIdsToLoad)
            c2xIdentifierBasedData = readcell(chIdentifierBasedDataFilePath);
            vsIdentifierBasedDataHeaders = string(c2xIdentifierBasedData(1,:));
            c2xIdentifierBasedData = c2xIdentifierBasedData(2:end,:);
            
            vdIdentifierBasedData_PatientIds = c2xIdentifierBasedData(:, vsIdentifierBasedDataHeaders == "Patient ID");
            vdIdentifierBasedData_PatientIds = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(vdIdentifierBasedData_PatientIds);
            
            vdIdentifierBasedData_PatientAge = c2xIdentifierBasedData(:, vsIdentifierBasedDataHeaders == "Patient Age at First Brain RT [Months]");
            vdIdentifierBasedData_PatientAge = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(vdIdentifierBasedData_PatientAge);
            
            vdIdentifierBasedData_PatientSurvival = c2xIdentifierBasedData(:, vsIdentifierBasedDataHeaders == "Survival Time After First Brain RT [Months]");
            vdIdentifierBasedData_PatientSurvival = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(vdIdentifierBasedData_PatientSurvival);
            
            
            c2xExcelData = readcell(chLoadPath);
            
            vsHeaders = string(c2xExcelData(1,:));
            c2xExcelData = c2xExcelData(2:end,:);
            
            vdPatientIdPerRow = c2xExcelData(:, vsHeaders == "study_id");
            vdPatientIdPerRow = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(vdPatientIdPerRow);
            
            vdUniquePatientIds = unique(vdPatientIdPerRow);
            
            for dPatientIdToLoadIndex=1:length(vdPatientIdsToLoad)
                if ~any(vdPatientIdsToLoad(dPatientIdToLoadIndex) == vdUniquePatientIds)
                    error(...
                        'REDCapStudyDatabase:LoadFromREDCapExport:PatientIdNotInREDCapExport',...
                        "The patient ID " + string(vdPatientIdsToLoad(dPatientIdToLoadIndex)) + " was not found in the REDCap exported data.");
                end
            end
            
            dNumPatients = length(vdPatientIdsToLoad);
            
            c1oPatients = cell(dNumPatients,1);
            vbNoError = false(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                try
                    c1oPatients{dPatientIndex} = REDCapPatient.CreateFromREDCapExport(...
                        c2xExcelData(vdPatientIdPerRow == vdPatientIdsToLoad(dPatientIndex), :),...
                        vsHeaders,...
                        vdIdentifierBasedData_PatientAge(vdIdentifierBasedData_PatientIds == vdPatientIdsToLoad(dPatientIndex)),...
                        vdIdentifierBasedData_PatientSurvival(vdIdentifierBasedData_PatientIds == vdPatientIdsToLoad(dPatientIndex))...
                        );
                    
                    vbNoError(dPatientIndex) = true;
                    fprintf(string(c1oPatients{dPatientIndex}.GetPrimaryId()) + ": Success");
                catch e
                    vbNoError(dPatientIndex) = false;
                    fprintf(string(vdUniquePatientIds(dPatientIndex)) + ": Failure");
                    
                    FileIOUtils.SaveMatFile(...
                        fullfile(Experiment.GetResultsDirectory(), "Pt. " + string(StringUtils.num2str_PadWithZeros(vdPatientIdsToLoad(dPatientIndex),4)) + " Error Message.mat"),...
                        'oError', e);
                end
                
                fprintf(newline);
            end
            
            c1oPatients = c1oPatients(vbNoError);
            obj = REDCapStudyDatabase(CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPatients));
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static)
        
        function vdPrimaryIds = GetAllPrimaryIds(obj)
            dNumPatients = length(obj.voPatients);
            
            vdPrimaryIds = zeros(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                vdPrimaryIds(dPatientIndex) = obj.voPatients{dPatientIndex}.GetPrimaryId();
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

