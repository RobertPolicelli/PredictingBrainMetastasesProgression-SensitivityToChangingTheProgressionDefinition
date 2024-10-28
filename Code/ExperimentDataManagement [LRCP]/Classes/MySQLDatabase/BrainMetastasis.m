classdef BrainMetastasis < handle
    %BrainMetastasis
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dBrainMetastasisNumber (1,1) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(dBrainMetastasisNumber,10)} = 1 
        
        vdMySQLPrimaryKey (1,:) double % patient ID, BM Number
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainMetastasis(dBrainMetastasisNumber, vdMySQLPrimaryKey)
            obj.dBrainMetastasisNumber = dBrainMetastasisNumber;
            obj.vdMySQLPrimaryKey = vdMySQLPrimaryKey;
        end

        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dNumber = GetBrainMetastasisNumber(obj)
            dNumber = obj.dBrainMetastasisNumber;
        end
        
        function vdMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            vdMySQLPrimaryKey = obj.vdMySQLPrimaryKey;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voBMs = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastases", [], "WHERE fk_brain_metastases_patient_study_id = " + string(dPatientStudyId));
            
            dNumBMs = size(tOutput,1);
            
            if dNumBMs == 0
                voBMs = BrainMetastasis.empty;
            else
                c1oBMs = cell(dNumBMs,1);
            
                for dBMIndex=1:dNumBMs
                    c1oBMs{dBMIndex} = BrainMetastasis(tOutput.brain_metastasis_number{dBMIndex}, [tOutput.fk_brain_metastases_patient_study_id{dBMIndex},tOutput.brain_metastasis_number{dBMIndex}]);
                end
                
                voBMs = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBMs);
            end
        end
        
        function oBM = LoadFromDatabaseByPatientStudyIdAndBrainMetastasisNumber(dPatientStudyId, dBMNumber)
            arguments
                dPatientStudyId (1,1) double
                dBMNumber (1,1) double
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "brain_metastases", [],...
                "WHERE fk_brain_metastases_patient_study_id = " + string(dPatientStudyId) + " AND brain_metastasis_number = " + string(dBMNumber));
            
            dNumBMs = size(tOutput,1);
            
            if dNumBMs == 0
                oBM = BrainMetastasis.empty;
            elseif dNumBMs > 1
                error(...
                    'BrainMetastais:GetFromDatabaseByPatientStudyIdAndBrainMetastasisNumber:NonUniqueEntry',...
                    'Multiple matches to the patient ID and brain metastasis number found.');
            else
                oBM = BrainMetastasis(tOutput.brain_metastasis_number{1}, [tOutput.fk_brain_metastases_patient_study_id{1},tOutput.brain_metastasis_number{1}]);
            end
        end
        
        function voValidationRecords = Validate(voBrainMetastases, oParentPatient, voValidationRecords)
            % no missing BM numbers
            dNumBMs = length(voBrainMetastases);
            vdBMNumbers = zeros(dNumBMs,1);
            
            for dBMIndex=1:dNumBMs
                vdBMNumbers(dBMIndex) = voBrainMetastases(dBMIndex).GetBrainMetastasisNumber();
            end
            
            if any(vdBMNumbers ~= (1:dNumBMs)')
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voBrainMetastases, "obj", "Brain metastasis numbers must be from 1 to n, the number of brain metastases"));
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

