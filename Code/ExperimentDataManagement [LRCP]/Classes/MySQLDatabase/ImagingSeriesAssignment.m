classdef ImagingSeriesAssignment
    %ImagingSeriesAssignment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eType (1,1) ImagingSeriesAssignmentType
        
        sDicomSOPInstanceUID string {ValidationUtils.MustBeEmptyOrScalar} % will be empty for series, will be populated for single files
        
        sDicomFilepath string {ValidationUtils.MustBeEmptyOrScalar}
        sMatFileFilePath string {ValidationUtils.MustBeEmptyOrScalar}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImagingSeriesAssignment(eType, sDicomSOPInstanceUID, sDicomFilepath, sMatFileFilePath)
            obj.eType = eType;
            
            obj.sDicomSOPInstanceUID = sDicomSOPInstanceUID;
            
            obj.sDicomFilepath = sDicomFilepath;
            obj.sMatFileFilePath = sMatFileFilePath;
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
               
        function eType = GetType(obj)
            eType = obj.eType;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voAssignments = LoadFromDatabaseByDicomSeriesId(dDicomSeriesId)
            arguments
                dDicomSeriesId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "imaging_series_assignments", [], "WHERE fk_imaging_series_assignments_id_dicom_series = " + string(dDicomSeriesId));
            
            dNumAssignments = size(tOutput,1);
            
            if dNumAssignments == 0
                voAssignments = ImagingSeriesAssignment.empty;
            else            
                c1oAssignments = cell(dNumAssignments,1);
                
                for dAssignmentIndex=1:dNumAssignments
                    c1oAssignments{dAssignmentIndex} = ImagingSeriesAssignment(...
                        ImagingSeriesAssignmentType.GetEnumFromMySQLEnumValue(tOutput.assignment_type{dAssignmentIndex}),...
                        tOutput.dicom_sop_instance_uid{dAssignmentIndex},...
                        tOutput.dicom_filepath{dAssignmentIndex},...
                        tOutput.mat_file_filepath{dAssignmentIndex});
                end
                
                voAssignments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oAssignments);
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

