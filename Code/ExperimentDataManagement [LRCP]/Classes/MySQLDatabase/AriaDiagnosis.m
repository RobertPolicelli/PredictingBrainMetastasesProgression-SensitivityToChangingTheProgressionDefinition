classdef AriaDiagnosis
    %AriaDiagnosis
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sDiseaseSiteCode (1,1) string
        eDiseaseSite (1,1) AriaDiagnosisDiseaseSite
        dtDate (1,1) datetime % month and year are correct, ignore day (set to default of 1)
        
        dMySQLPrimaryKey double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger, mustBeNonnegative}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = AriaDiagnosis(sDiseaseSiteCode, eDiseaseSite, dtDate, dMySQLPrimaryKey)
            %obj = AriaDiagnosis(sDiseaseSiteCode, eDiseaseSite, dtDate, dMySQLPrimaryKey)
            arguments
                sDiseaseSiteCode
                eDiseaseSite
                dtDate
                dMySQLPrimaryKey = []
            end
            
            
            obj.sDiseaseSiteCode = sDiseaseSiteCode;
            obj.eDiseaseSite = eDiseaseSite;            
            obj.dtDate = dtDate;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function sDiseaseSiteCode = GetDiseaseSiteCode(obj)
            sDiseaseSiteCode = obj.sDiseaseSiteCode;
        end
        
        function eDiseaseSite = GetDiseaseSite(obj)
            eDiseaseSite = obj.eDiseaseSite;
        end
        
        function dtDate = GetDate(obj)
            dtDate = obj.dtDate;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
        
        function bBool = eq(obj1, obj2)
            bBool = ...
                obj1.sDiseaseSiteCode == obj2.sDiseaseSiteCode &&...
                obj1.eDiseaseSite == obj2.eDiseaseSite &&...
                obj1.dtDate == obj2.dtDate;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voDiagnoses = LoadFromDatabase(dPatientStudyId)
            arguments
                dPatientStudyId (1,1) double {mustBeInteger, mustBePositive}
            end
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), "aria_diagnoses", [], "WHERE fk_aria_diagnoses_patient_study_id = " + string(dPatientStudyId) + " ORDER BY date");
            
            dNumDiagnoses = size(tOutput,1);
            
            if dNumDiagnoses == 0
                voDiagnoses = AriaDiagnosis.empty;
            else
                c1oDiagnoses = cell(dNumDiagnoses,1);
                
                for dDiagnosisIndex=1:dNumDiagnoses     
                    sDiseaseSiteCode = string(tOutput.disease_site_code{dDiagnosisIndex});
                    eDiseaseSite = AriaDiagnosisDiseaseSite.GetEnumFromMySQLEnumValue(tOutput.disease_site{dDiagnosisIndex});
                    dtDate = tOutput.date{dDiagnosisIndex};
                    
                    c1oDiagnoses{dDiagnosisIndex} = AriaDiagnosis(sDiseaseSiteCode, eDiseaseSite, dtDate, tOutput.id_aria_diagnoses{dDiagnosisIndex});                    
                end
                
                voDiagnoses = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oDiagnoses);
            end
        end
        
        function obj = CreateFromSpreadsheetData(sDiseaseSiteCode, dDateYear, dDateMonth)
            eDiseaseSite = AriaDiagnosisDiseaseSite.GetEnumFromSiteCode(sDiseaseSiteCode);
            dtDate = datetime(dDateYear, dDateMonth,1);
            
            obj = AriaDiagnosis(sDiseaseSiteCode, eDiseaseSite, dtDate);
        end
        
        function voValidationRecords = Validate(voDiagnoses, oParentPatient, voValidationRecords)
            % no duplicates
            bHasDuplicate = false;
            
            for dDiagnosisIndex1=1:length(voDiagnoses)
                for dDiagnosisIndex2=dDiagnosisIndex1+1:length(voDiagnoses)
                    if voDiagnoses(dDiagnosisIndex1) == voDiagnoses(dDiagnosisIndex2)
                        bHasDuplicate = true;
                        break;
                    end
                end
            end
            
            if bHasDuplicate
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(voDiagnoses, "obj", "Duplicate values"));
            end
            
            % per diagnosis:
            for dDiagnosisIndex=1:length(voDiagnoses)
                oDiagnosis = voDiagnoses(dDiagnosisIndex);
                
                % - sDiseaseSiteCode
                % none
                
                % - eDiseaseSite
                % none
                
                % - dtDate
                % -- after date of death
                if oParentPatient.GetDeceasedStatus() ~= DeceasedStatus.NotDeceased
                    if oDiagnosis.dtDate > oParentPatient.GetApproximateDateOfDeath()
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oDiagnosis, "dtDate", "After date of death"));
                    end
                end
                
                % -- before 2010
                if oDiagnosis.dtDate.Year < 2010
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oDiagnosis, "dtDate", "Before 2010"));
                end
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

