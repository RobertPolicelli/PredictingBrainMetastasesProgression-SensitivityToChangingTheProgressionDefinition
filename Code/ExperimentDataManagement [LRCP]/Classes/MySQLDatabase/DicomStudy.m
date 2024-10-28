classdef DicomStudy
    %DicomStudy
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dtDicomDateTime (1,1) datetime
        
        sDicomID (1,1) string
        sDicomInstanceUID (1,1) string
        
        sOrthancUUID (1,1) string
        
        sDicomDescription (1,1) string
        
        voDicomSeries (:,1) DicomSeries = DicomSeries.empty(0,1)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DicomStudy(dtDicomDateTime, sDicomID, sDicomInstanceUID, sOrthancUUID, sDicomDescription, voDicomSeries)
            %obj = DicomStudy(dtDicomDateTime, sDicomID, sDicomInstanceUID, sOrthancUUID, sDicomDescription, voDicomSeries)
            
            obj.dtDicomDateTime = dtDicomDateTime;
            
            obj.sDicomID = sDicomID;
            obj.sDicomInstanceUID = sDicomInstanceUID;
            
            obj.sOrthancUUID = sOrthancUUID;
            
            obj.sDicomDescription = sDicomDescription;
            
            obj.voDicomSeries = voDicomSeries;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function voDicomSeries = GetDicomSeries(obj)
            voDicomSeries = obj.voDicomSeries;
        end
        
        function sDicomFolderName = GetDicomFolderName(obj)
            sDicomFolderName = obj.sDicomDescription;
            
            sDicomFolderName = strrep(sDicomFolderName, ":", "");
            sDicomFolderName = strrep(sDicomFolderName, "-", "");
            sDicomFolderName = strrep(sDicomFolderName, "(", "");            
            sDicomFolderName = strrep(sDicomFolderName, ")", "");
            sDicomFolderName = regexprep(sDicomFolderName, " +", " ");
        end
        
        function bBool = DoesContainDicomSeries(obj, oDicomSeries)
            arguments
                obj (1,1) DicomStudy
                oDicomSeries (1,1) DicomSeries
            end
            
            bBool = false;
            
            for dSeriesIndex=1:length(obj.voDicomSeries)
                if obj.voDicomSeries(dSeriesIndex).GetOrthancUUID() == oDicomSeries.GetOrthancUUID()
                    bBool = true;
                    break;
                end
            end
        end
    end
    
    
    methods (Access = public, Static)
                
        function voStudies = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "dicom_studies", [], "WHERE fk_dicom_studies_patient_study_id = " + string(dPatientStudyId), "ORDER BY dicom_datetime");
            
            if size(tOutput,1) == 0
                voStudies = DicomStudy.empty;                
            else
                dNumStudies = size(tOutput,1);
                c1oStudies = cell(dNumStudies,1);
                
                for dStudyIndex=1:dNumStudies
                    tRow = tOutput(dStudyIndex,:);
                    
                    dtDicomDateTime = tRow.dicom_datetime{1};
                    sDicomID = tRow.dicom_id{1};
                    sDicomInstanceUID = tRow.dicom_instance_uid{1};
                    sOrthancUUID = tRow.orthanc_pacs_uuid{1};
                    sDicomDescription = tRow.dicom_description{1};
                    voDicomSeries = DicomSeries.LoadFromDatabaseByDicomStudyId(tRow.id_dicom_studies{1});                    
                    
                    c1oStudies{dStudyIndex} = DicomStudy(dtDicomDateTime, sDicomID, sDicomInstanceUID, sOrthancUUID, sDicomDescription, voDicomSeries);
                end
                                
                voStudies = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oStudies);
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

