classdef (Abstract) HistopathologyReport
    %HistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)   
        dtDate (1,1) datetime
        ePrimaryCancerSite (1,1) PrimaryCancerSite     
        
        sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}
        
        dREDCapRepeatInstance (1,1) double {mustBeInteger, mustBePositive} = 1
        
        vdMySQLPrimaryKey (1,:) double
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = HistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey)
            %obj = HistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey)
            
            obj.dtDate = dtDate;
            obj.ePrimaryCancerSite = ePrimaryCancerSite;
            
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
            
            obj.dREDCapRepeatInstance = dREDCapRepeatInstance;
            
            obj.vdMySQLPrimaryKey = vdMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDate = GetDate(obj)
            dtDate = obj.dtDate;
        end
        
        function ePrimaryCancerSite = GetPrimaryCancerSite(obj)
            ePrimaryCancerSite = obj.ePrimaryCancerSite;
        end
        
        function vdMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            vdMySQLPrimaryKey = obj.vdMySQLPrimaryKey;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voValidationRecords = Validate(voHistopathologyReports, oParentPatient, voValidationRecords)
            for dReportIndex=1:length(voHistopathologyReports)
                voValidationRecords = voHistopathologyReports(dReportIndex).ValidateReport(oParentPatient, voValidationRecords);                
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                       PROTECTED METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function voValidationRecords = ValidateReport(obj, oParentPatient, voValidationRecords)
            % - dtDate (more specific validation is likely performed in
            % children classes)
            % -- After approximate date of death
            if calmonths(between(oParentPatient.GetApproximateDateOfDeath(), obj.dtDate)) > 0
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(obj, "dtDate", "Is after the patient's approximate date of death"));
            end
            
            % -- More than 10 years before first brain radiation treatment
            if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), obj.dtDate)) < -10*12
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(obj, "dtDate", "Is more than 10 years before the first brain radiation therapy"));
            end
            
            % - ePrimaryCancerSite
            % -- must match one of the Aria diagnoses of the parent patient
            bMatchFound = false;
            voAriaDiagnoses = oParentPatient.GetAriaDiagnoses();
            
            for dDiagnosisIndex=1:length(voAriaDiagnoses)
                if string(voAriaDiagnoses(dDiagnosisIndex).GetDiseaseSite()) == string(obj.ePrimaryCancerSite)
                    bMatchFound = true;
                    break;
                end
            end
            
            if ~bMatchFound
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(obj, "ePrimaryCancerSite", "The primary cancer site does not match any of the Aria diagnosis sites"));
            end
            
            % -- breast/gyne/ovarian *typically* associated with female
            % patients
            if oParentPatient.GetSex() == Sex.Male && (any(obj.ePrimaryCancerSite == [PrimaryCancerSite.Breast PrimaryCancerSite.Gynecological PrimaryCancerSite.Ovarian]))
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(obj, "ePrimaryCancerSite", "The primary cancer site is not typical for a male patient"));
            end
                
            % -- prostate/testicular *typically* associated with male
            % patients
            if oParentPatient.GetSex() == Sex.Female && (any(obj.ePrimaryCancerSite == [PrimaryCancerSite.Prostate PrimaryCancerSite.Testicular]))
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(obj, "ePrimaryCancerSite", "The primary cancer site is not typical for a female patient"));
            end
            
            % - sREDCapDataCollectionNotes
            % none
            
            % - dREDCapRepeatInstance
            % none
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

