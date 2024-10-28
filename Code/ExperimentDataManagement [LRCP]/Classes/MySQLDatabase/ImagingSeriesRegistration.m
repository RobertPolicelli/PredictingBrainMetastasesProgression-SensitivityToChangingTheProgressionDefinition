classdef ImagingSeriesRegistration
    %ImagingSeriesRegistration
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eSource(1,1) ImagingSeriesRegistrationSource
        
        sDicomSOPInstanceUID string {ValidationUtils.MustBeEmptyOrScalar} % will be empty for series, will be populated for single files
        dDicomInstanceNumber (1,1) double {mustBeNonnegative, mustBeInteger}
        
        sDicomFilepath string {ValidationUtils.MustBeEmptyOrScalar}
        
        oRegistrationFileDicomSeries DicomSeries {ValidationUtils.MustBeEmptyOrScalar} = DicomSeries.empty
        oPrimaryImagingDicomSeries DicomSeries {ValidationUtils.MustBeEmptyOrScalar} = DicomSeries.empty
        oSecondaryImagingDicomSeries DicomSeries {ValidationUtils.MustBeEmptyOrScalar} = DicomSeries.empty
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImagingSeriesRegistration(eSource, sDicomSOPInstanceUID, dDicomInstanceNumber, sDicomFilepath, oRegistrationFileDicomSeries, oPrimaryImagingDicomSeries, oSecondaryImagingDicomSeries)
            obj.eSource = eSource;
            
            obj.sDicomSOPInstanceUID = sDicomSOPInstanceUID;
            obj.dDicomInstanceNumber =dDicomInstanceNumber;
            
            obj.sDicomFilepath = sDicomFilepath;
            
            obj.oRegistrationFileDicomSeries = oRegistrationFileDicomSeries;
            obj.oPrimaryImagingDicomSeries = oPrimaryImagingDicomSeries;
            obj.oSecondaryImagingDicomSeries = oSecondaryImagingDicomSeries;
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<    
        
        function eSource = GetSource(obj)
            eSource = obj.eSource;
        end
        
        function oRegistrationFileDicomSeries = GetRegistrationFileDicomSeries(obj)
            oRegistrationFileDicomSeries = obj.oRegistrationFileDicomSeries;
        end
        
        function oPrimaryImagingDicomSeries = GetPrimaryImagingDicomSeries(obj)
            oPrimaryImagingDicomSeries = obj.oPrimaryImagingDicomSeries;
        end
            
        function oSecondaryImagingDicomSeries = GetSecondaryImagingDicomSeries(obj)
            oSecondaryImagingDicomSeries = obj.oSecondaryImagingDicomSeries;
        end
        
        function [oRegistrationDicomSeries, oRegistrationDicomStudy] = GetRegistrationFileDicomSeriesAndStudy(obj, oParentPatient)
            oRegistrationDicomSeries = obj.oRegistrationFileDicomSeries;
            oRegistrationDicomStudy = oParentPatient.GetDicomStudyForDicomSeries(oRegistrationDicomSeries);
        end
        
        function sDicomFilePath = GetRegistrationDicomFilePath(obj, oParentPatient)
            [oRegistrationDicomSeries, oRegistrationDicomStudy] = obj.GetRegistrationFileDicomSeriesAndStudy(oParentPatient);
            
            sDicomSeriesPath = string(fullfile(Experiment.GetDataPath('DicomImagingDatabase'), oParentPatient.GetDicomFolderName(), oRegistrationDicomStudy.GetDicomFolderName(), oRegistrationDicomSeries.GetDicomFolderName()));
            
            voEntries = dir(sDicomSeriesPath);
            
            if length(voEntries) ~= 3
                error("Multiple files!");
            else
                sDicomFilePath = fullfile(sDicomSeriesPath, DicomModality.REG.GetDefaultDicomFilenamePrefix() + "000000.dcm");
            end
        end
        
        function sMatFilePath = GetRegistrationMatFilePath(obj, oParentPatient, sExperimentCode)
            [oRegistrationDicomSeries, oRegistrationDicomStudy] = obj.GetRegistrationFileDicomSeriesAndStudy(oParentPatient);
            
            sMatFilePath = string(fullfile(Experiment.GetDataPath('ProcessedImagingDatabase'), oParentPatient.GetDicomFolderName(), oRegistrationDicomStudy.GetDicomFolderName(), oRegistrationDicomSeries.GetDicomFolderName(), sExperimentCode+".mat"));            
        end
    end
    
    
    methods (Access = public, Static)
        
        function voRegistrations = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double
            end
            
            sJoin = "imaging_series_registrations " +...
                "JOIN dicom_series ON dicom_series.id_dicom_series = imaging_series_registrations.fk_registration_series_id_dicom_series " + ...
                "JOIN dicom_studies ON dicom_studies.id_dicom_studies = dicom_series.fk_dicom_series_id_dicom_studies";
            sWhere = "WHERE dicom_studies.fk_dicom_studies_patient_study_id = " + string(dPatientStudyId);
            sOrderBy = "ORDER BY imaging_series_registrations.dicom_sop_instance_uid";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoin, [], sWhere, sOrderBy);
            
            dNumRegistrations = size(tOutput,1);
            
            if dNumRegistrations == 0
                voRegistrations = ImagingSeriesRegistration.empty;
            else            
                c1oRegistrations = cell(dNumRegistrations,1);
                
                
                for dRegistrationIndex=1:dNumRegistrations
                    tRow = tOutput(dRegistrationIndex,:);
                    
                    oRegistrationDicomSeries = DicomSeries.LoadFromDatabaseByDicomSeriesId(tRow.fk_registration_series_id_dicom_series{1});
                    oPrimaryDicomSeries = DicomSeries.LoadFromDatabaseByDicomSeriesId(tRow.fk_primary_imaging_series_id_dicom_series{1});
                    oSecondaryDicomSeries = DicomSeries.LoadFromDatabaseByDicomSeriesId(tRow.fk_secondary_imaging_series_id_dicom_series{1});
                    
                    c1oRegistrations{dRegistrationIndex} = ImagingSeriesRegistration(...
                        ImagingSeriesRegistrationSource.GetEnumFromMySQLEnumValue(tRow.source{1}),...
                        tRow.dicom_sop_instance_uid{1},...
                        tRow.dicom_instance_number{1},...
                        tRow.dicom_filepath{1},...
                        oRegistrationDicomSeries,...
                        oPrimaryDicomSeries,...
                        oSecondaryDicomSeries);
                end
                
                voRegistrations = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oRegistrations);
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

