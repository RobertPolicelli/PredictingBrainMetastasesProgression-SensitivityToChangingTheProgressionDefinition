classdef DicomSeries
    %DicomSeries
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dtDicomDateTime datetime {ValidationUtils.MustBeEmptyOrScalar} % if empty, no series date in the Dicom metadata
        
        sDicomInstanceUID (1,1) string
        
        sOrthancUUID (1,1) string
        
        sDicomDescription string {ValidationUtils.MustBeEmptyOrScalar} 
        eDicomModality (1,1) DicomModality
        dNumberOfInstances (1,1) double {mustBeInteger, mustBePositive} = 1
        
        voImagingSeriesAssignments (:,1) ImagingSeriesAssignment = ImagingSeriesAssignment.empty(0,1)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DicomSeries(dtDicomDateTime, sDicomInstanceUID, sOrthancUUID, sDicomDescription, eDicomModality, dNumberOfInstances, voImagingSeriesAssignments)
            %obj = DicomSeries(dtDicomDateTime, sDicomID, sDicomInstanceUID, sOrthancUUID, sDicomDescription, eDicomModality, dNumberOfInstances, voImagingSeriesAssignments)
            
            obj.dtDicomDateTime = dtDicomDateTime;
            
            obj.sDicomInstanceUID = sDicomInstanceUID;
            
            obj.sOrthancUUID = sOrthancUUID;
            
            obj.sDicomDescription = sDicomDescription;
            
            obj.eDicomModality = eDicomModality;
            obj.dNumberOfInstances = dNumberOfInstances;
            
            obj.voImagingSeriesAssignments = voImagingSeriesAssignments;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function sOrthancUUID = GetOrthancUUID(obj)
            sOrthancUUID = obj.sOrthancUUID;
        end
        
        function voImagingSeriesAssignments = GetImagingSeriesAssignments(obj)
            voImagingSeriesAssignments = obj.voImagingSeriesAssignments;
        end
        
        function bBool = HasImagingSeriesAssignmentType(obj, eImagingSeriesAssignmentType)
            arguments
                obj (1,1) DicomSeries
                eImagingSeriesAssignmentType (1,1) ImagingSeriesAssignmentType
            end
            
            bBool = false;
            
            for dAssignmentIndex=1:length(obj.voImagingSeriesAssignments)
                if obj.voImagingSeriesAssignments(dAssignmentIndex).GetType() == eImagingSeriesAssignmentType
                    bBool = true;
                    break;
                end
            end
        end
        
        function eDicomModality = GetDicomModality(obj)
            eDicomModality = obj.eDicomModality;
        end
        
        function sDicomFolderName = GetDicomFolderName(obj)
            sDicomFolderName = obj.eDicomModality.GetMySQLEnumValue();
            
            if ~isempty(obj.sDicomDescription)
                sDicomFolderName = sDicomFolderName + " " + obj.sDicomDescription;
            end
            
            sDicomFolderName = strrep(sDicomFolderName, ":", "");
            sDicomFolderName = strrep(sDicomFolderName, "-", "");
            sDicomFolderName = strrep(sDicomFolderName, "(", "");            
            sDicomFolderName = strrep(sDicomFolderName, ")", "");
            sDicomFolderName = regexprep(sDicomFolderName, " +", " ");
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> OTHER METHODS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function sFilePath = GetDicomFilePath(obj, oParentPatient)
            arguments
                obj (1,1) DicomSeries
                oParentPatient (1,1) Patient
            end
            
            oDicomStudy = oParentPatient.GetDicomStudyForDicomSeries(obj);
            
            sFilePath = string(fullfile(Experiment.GetDataPath('DicomImagingDatabase'), oParentPatient.GetDicomFolderName(), oDicomStudy.GetDicomFolderName(), obj.GetDicomFolderName(), obj.GetDefaultDicomFilename()));
        end
        
        function sFilePath = GetMatFilePath(obj, oParentPatient, sIMGPPCode, dBrainMetastasisNumber)
            arguments
                obj (1,1) DicomSeries
                oParentPatient (1,1) Patient
                sIMGPPCode (1,1) string
                dBrainMetastasisNumber double {ValidationUtils.MustBeEmptyOrScalar} = []
            end
            
            oDicomStudy = oParentPatient.GetDicomStudyForDicomSeries(obj);
            
            if isempty(dBrainMetastasisNumber)
                sBMInsert = "";
            else
                sBMInsert = " (BM " + string(StringUtils.num2str_PadWithZeros(dBrainMetastasisNumber, 2)) + ")";
            end
            
            sFilePath = string(fullfile(Experiment.GetDataPath('ProcessedImagingDatabase'), oParentPatient.GetDicomFolderName(), oDicomStudy.GetDicomFolderName(), obj.GetDicomFolderName(), sIMGPPCode+sBMInsert+".mat"));
        end
        
        function sDefaultDicomFilename = GetDefaultDicomFilename(obj)
            sDefaultDicomFilename = obj.eDicomModality.GetDefaultDicomFilenamePrefix() + "000000.dcm";
        end
        
        function DownloadSeriesFromOrthanc(obj, oParentPatient, oParentDicomStudy, sDicomDatabaseFilePath)
            arguments
                obj
                oParentPatient (1,1) Patient
                oParentDicomStudy (1,1) DicomStudy
                sDicomDatabaseFilePath (1,1) string = ""
            end
            
            if sDicomDatabaseFilePath == ""
                sDicomDatabaseFilePath = Experiment.GetDataPath("DicomImagingDatabase");
            end
                        
            if isfolder(fullfile(sDicomDatabaseFilePath, oParentPatient.GetDicomFolderName(), oParentDicomStudy.GetDicomFolderName(), obj.GetDicomFolderName()))
                error(...
                    'DicomSeries:DownloadSeriesFromOrthanc:AlreadyDownloaded',...
                    'The Dicom series is already downloaded.');
            end
            
            [sServerIpAndHttpPort, sHttpUsername, sHttpPassword] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('DicomServerHttpConfig'),...
                DicomImporter.DicomServerHttpConfigFileIPAndPortVarName,...
                DicomImporter.DicomServerHttpConfigFileUsernameVarName,...
                DicomImporter.DicomServerHttpConfigFilePasswordVarName);
            oWebOpts = weboptions('Username', sHttpUsername, 'Password', sHttpPassword);
            
            sZipFilePath = string(tempname) + ".zip";
            
            oFile = fopen(sZipFilePath,'w');
            fwrite(oFile, webread("http://" + sServerIpAndHttpPort + "/series/" + obj.sOrthancUUID + "/archive", oWebOpts));
            fclose(oFile);
                        
            unzip(sZipFilePath, sDicomDatabaseFilePath);
            delete(sZipFilePath);
        end
    end
    
    
    methods (Access = public, Static)
                
        function voSeries = LoadFromDatabaseByDicomStudyId(dDicomStudyId)
            arguments
                dDicomStudyId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "dicom_series", [], "WHERE fk_dicom_series_id_dicom_studies = " + string(dDicomStudyId), "ORDER BY dicom_datetime");
            
            if size(tOutput,1) == 0
                voSeries = DicomSeries.empty;                
            else
                dNumSeries = size(tOutput,1);
                c1oSeries = cell(dNumSeries,1);
                
                for dSeriesIndex=1:dNumSeries
                    tRow = tOutput(dSeriesIndex,:);
                    
                    dtDicomDateTime = tRow.dicom_datetime{1};
                    sDicomInstanceUID = tRow.dicom_instance_uid{1};
                    sOrthancUUID = tRow.orthanc_pacs_uuid{1};
                    sDicomDescription = tRow.dicom_description{1};
                    eDicomModality = DicomModality.GetEnumFromMySQLEnumValue(tRow.dicom_modality{1});
                    dNumberOfInstances = tRow.number_of_instances{1};
                    
                    voImagingSeriesAssignments = ImagingSeriesAssignment.LoadFromDatabaseByDicomSeriesId(tRow.id_dicom_series{1});
                    
                    c1oSeries{dSeriesIndex} = DicomSeries(dtDicomDateTime, sDicomInstanceUID, sOrthancUUID, sDicomDescription, eDicomModality, dNumberOfInstances, voImagingSeriesAssignments);
                end
                                
                voSeries = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oSeries);
            end
        end   
        
        function oSeries = LoadFromDatabaseByDicomSeriesId(dDicomSeriesId)
            arguments
                dDicomSeriesId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "dicom_series", [], "WHERE id_dicom_series = " + string(dDicomSeriesId));
            
            if size(tOutput,1) > 1
                error(...
                    'DicomSeries:LoadFromDatabaseByDicomSeriesId:NonUniqueMatch',...
                    'Multiple values found for unique id.');            
            elseif size(tOutput,1) == 0
                oSeries = DicomSeries.empty;                
            else                    
                dtDicomDateTime = tOutput.dicom_datetime{1};
                sDicomInstanceUID = tOutput.dicom_instance_uid{1};
                sOrthancUUID = tOutput.orthanc_pacs_uuid{1};
                sDicomDescription = tOutput.dicom_description{1};
                eDicomModality = DicomModality.GetEnumFromMySQLEnumValue(tOutput.dicom_modality{1});
                dNumberOfInstances = tOutput.number_of_instances{1};
                
                voImagingSeriesAssignments = ImagingSeriesAssignment.LoadFromDatabaseByDicomSeriesId(tOutput.id_dicom_series{1});
                
                oSeries = DicomSeries(dtDicomDateTime, sDicomInstanceUID, sOrthancUUID, sDicomDescription, eDicomModality, dNumberOfInstances, voImagingSeriesAssignments);
            end
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

