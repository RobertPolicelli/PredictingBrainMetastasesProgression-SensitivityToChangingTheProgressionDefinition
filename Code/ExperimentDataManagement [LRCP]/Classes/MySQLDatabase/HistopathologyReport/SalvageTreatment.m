classdef SalvageTreatment
    %SalvageTreatment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)   
        dtTreatmentDate datetime {ValidationUtils.MustBeEmptyOrScalar} % if empty, start date was not known
        
        eType (1,1) SalvageTreatmentType
        sTypeOther string {ValidationUtils.MustBeEmptyOrScalar} % only set if eType == SalvageTreatmentType.Other
        
        bNewBrainMetastasesTargeted (1,1) logical
        voBrainMetastasesTargeted (:,1) BrainMetastasis % if empty, all brain metastases were targeted
                   
        sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}        
        dREDCapRepeatInstance (1,1) double {mustBeInteger, mustBePositive} = 1
        
        dMySQLPrimaryKey (1,1) double % id_salvage_treatments
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = SalvageTreatment(dtTreatmentDate, eType, sTypeOther, bNewBrainMetastasesTargeted, voBrainMetastasesTargeted, sREDCapDataCollectionNotes, dREDCapRepeatInstance, dMySQLPrimaryKey)
            %obj = SalvageTreatment(dtTreatmentDate, eType, sTypeOther, bNewBrainMetastasesTargeted, voBrainMetastasesTargeted, sREDCapDataCollectionNotes, dREDCapRepeatInstance, dMySQLPrimaryKey)
            arguments
                dtTreatmentDate datetime {ValidationUtils.MustBeEmptyOrScalar}                
                eType (1,1) SalvageTreatmentType
                sTypeOther string {ValidationUtils.MustBeEmptyOrScalar}
                bNewBrainMetastasesTargeted (1,1) logical                
                voBrainMetastasesTargeted (:,1) BrainMetastasis
                sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}
                dREDCapRepeatInstance (1,1) double {mustBeInteger, mustBePositive}
                dMySQLPrimaryKey
            end
            
            obj.dtTreatmentDate = dtTreatmentDate;
            
            obj.eType = eType;
            obj.sTypeOther = sTypeOther;
            
            obj.bNewBrainMetastasesTargeted = bNewBrainMetastasesTargeted;            
            obj.voBrainMetastasesTargeted = voBrainMetastasesTargeted;
            
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
            obj.dREDCapRepeatInstance = dREDCapRepeatInstance;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtTreatmentDate = GetTreatmentDate(obj)
            dtTreatmentDate = obj.dtTreatmentDate;
        end
        
        function eType = GetType(obj)
            eType = obj.eType;
        end
        
        function dMySQLPrimaryKey = GetMySQLPrimaryKey(obj)
            dMySQLPrimaryKey = obj.dMySQLPrimaryKey;
        end
        
        function bBool = IsBrainMetastasisTargeted(obj, dBrainMetastasisNumber)
            arguments
                obj (1,1) SalvageTreatment
                dBrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if obj.eType == SalvageTreatmentType.WBRT
                bBool = true;
            elseif obj.eType == SalvageTreatmentType.SRS || obj.eType == SalvageTreatmentType.SRT || obj.eType == SalvageTreatmentType.Surgery
                bBool = false;
                
                for dBMIndex=1:length(obj.voBrainMetastasesTargeted)
                    if obj.voBrainMetastasesTargeted(dBMIndex).GetBrainMetastasisNumber() == dBrainMetastasisNumber
                        bBool = true;
                        break;
                    end
                end
            else
                if obj.sTypeOther == "Palliative, conventional fractionation"
                    bBool = true;
                else
                    error(...
                        'SalvageTreatment:IsBrainMetastasisTargeted:Other',...
                        'Type "Other" must be manually accounted for');
                end
            end
        end
    end
    
    
    methods (Access = public, Static)
        
        function voTreatments = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            sTable = "salvage_treatments";
            sWhere = "WHERE salvage_treatments.fk_salvage_treatments_patient_study_id = " + string(dPatientStudyId);
            sOrderBy = "ORDER BY salvage_treatments.treatment_date";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTable, [], sWhere, sOrderBy);
            
            dNumTreatments = size(tOutput,1);
            
            if dNumTreatments == 0
                voTreatments = SalvageTreatment.empty;
            else
                c1oTherapies = cell(dNumTreatments,1);
                
                for dTreatmentIndex=1:dNumTreatments
                    tOutputRow = tOutput(dTreatmentIndex,:);
                    
                    dtTreatmentDate = tOutputRow.treatment_date{1};
                    
                    eType = SalvageTreatmentType.GetEnumFromMySQLEnumValue(tOutputRow.type{1});
                    sTypeOther = tOutputRow.type_other{1};
                    
                    bNewBrainMetastasesTargeted = tOutputRow.new_metastases_targeted{1};
                    
                    chREDCapDataCollectionNotes = tOutputRow.data_collection_notes{1};
                    dREDCapRepeatInstance = tOutputRow.redcap_repeat_instance{1};
                    
                    sTable = "salvage_treatments_has_brain_metastases";
                    sWhere = "WHERE salvage_treatments_has_brain_metastases.fk_st_has_bms_id_salvage_treatments = " + string(tOutputRow.id_salvage_treatments{1});
                    sOrderBy = "ORDER BY salvage_treatments_has_brain_metastases.fk_st_has_bms_brain_metastases_brain_metastasis_number";
                    
                    tTargetedBMsOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTable, [], sWhere, sOrderBy);
                    
                    vdTargetedBrainMetastasesNumbers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tTargetedBMsOutput.fk_st_has_bms_brain_metastases_brain_metastasis_number);
                    dNumBrainMetastases = length(vdTargetedBrainMetastasesNumbers);
                    
                    if dNumBrainMetastases == 0
                        voTargetedBrainMetastases = BrainMetastasis.empty;
                    else
                        c1oTargetedBrainMetastases = cell(dNumBrainMetastases,1);
                        
                        for dBrainMetastasisIndex=1:dNumBrainMetastases
                            c1oTargetedBrainMetastases{dBrainMetastasisIndex} = BrainMetastasis(vdTargetedBrainMetastasesNumbers(dBrainMetastasisIndex), [dPatientStudyId, vdTargetedBrainMetastasesNumbers(dBrainMetastasisIndex)]);
                        end
                        
                        voTargetedBrainMetastases = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oTargetedBrainMetastases);
                    end    
                    
                    c1oTherapies{dTreatmentIndex} = SalvageTreatment(dtTreatmentDate, eType, sTypeOther, bNewBrainMetastasesTargeted, voTargetedBrainMetastases, chREDCapDataCollectionNotes, dREDCapRepeatInstance, tOutputRow.id_salvage_treatments{1});
                end
                
                voTreatments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oTherapies);
            end
        end
        
        function voValidationRecords = Validate(voSalvageTreatments, oParentPatient, voValidationRecords)
            for dTreatmentIndex=1:length(voSalvageTreatments)
                oTreatment = voSalvageTreatments(dTreatmentIndex);
                
                % - dtTreatmentDate 
                % -- is empty
                if isempty(oTreatment.dtTreatmentDate)
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTreatment, "dtTreatmentDate", "Is empty"));
                end
                
                % -- after approximate date of death
                if calmonths(between(oParentPatient.GetApproximateDateOfDeath(), oTreatment.dtTreatmentDate)) > 0
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTreatment, "dtTreatmentDate", "Is after the patient's approximate date of death"));
                end
                
                % -- before or at same time as first brain radiotherpy 
                if calmonths(between(oParentPatient.GetFirstBrainRadiationTherapyDate(), oTreatment.dtTreatmentDate)) <= 0
                    voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTreatment, "dtTreatmentDate", "Is before or concurrent with the first brain radiation therapy"));
                end                  
                
                % - eType 
                % none
                
                % - sTypeOther 
                % none
                
                % - bNewBrainMetastasesTargeted 
                % none
                
                % - voBrainMetastasesTargeted 
                % -- BM number exceeds number of BMs for patient
                for dBMIndex=1:length(oTreatment.voBrainMetastasesTargeted)
                    if oTreatment.voBrainMetastasesTargeted(dBMIndex).GetBrainMetastasisNumber() > oParentPatient.GetNumberOfBrainMetastases()
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTreatment, "voBrainMetastasesTargeted", "Invalid brain metastasis number"));
                    end
                end
                                
                % - sREDCapDataCollectionNotes
                % none
                
                % - dREDCapRepeatInstance 
                % none
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

