classdef RadionecrosisTreatment
    %RadionecrosisTreatment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)   
        dtTreatmentDate datetime {ValidationUtils.MustBeEmptyOrScalar} % if empty, start date was not known
        
        eType (1,1) RadionecrosisTreatmentType
        sTypeOther string {ValidationUtils.MustBeEmptyOrScalar} % only set if eType == RadionecrosisTreatmentType.Other
        
        bNewBrainMetastasesTargeted logical {ValidationUtils.MustBeEmptyOrScalar} % if empty, all brain metastases were targeted
        voBrainmetastasesTargeted (:,1) BrainMetastasis % if empty, all brain metastases were targeted
                   
        sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}        
        dREDCapRepeatInstance (1,1) double {mustBeInteger, mustBePositive} = 1
        
        dMySQLPrimaryKey (1,1) double % id_radionecrosis_treatments
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RadionecrosisTreatment(dtTreatmentDate, eType, sTypeOther, bNewBrainMetastasesTargeted, voBrainmetastasesTargeted, sREDCapDataCollectionNotes, dREDCapRepeatInstance, dMySQLPrimaryKey)
            %obj = RadionecrosisTreatment(dtTreatmentDate, eType, sTypeOther, bNewBrainMetastasesTargeted, voBrainmetastasesTargeted, sREDCapDataCollectionNotes, dREDCapRepeatInstance, dMySQLPrimaryKey)
            arguments
                dtTreatmentDate datetime {ValidationUtils.MustBeEmptyOrScalar}                
                eType (1,1) RadionecrosisTreatmentType
                sTypeOther string {ValidationUtils.MustBeEmptyOrScalar}
                bNewBrainMetastasesTargeted logical {ValidationUtils.MustBeEmptyOrScalar}          
                voBrainmetastasesTargeted (:,1) BrainMetastasis
                sREDCapDataCollectionNotes string {ValidationUtils.MustBeEmptyOrScalar}
                dREDCapRepeatInstance (1,1) double {mustBeInteger, mustBePositive}
                dMySQLPrimaryKey (1,1) double
            end
            
            obj.dtTreatmentDate = dtTreatmentDate;
            
            obj.eType = eType;
            obj.sTypeOther = sTypeOther;
            
            obj.bNewBrainMetastasesTargeted = bNewBrainMetastasesTargeted;            
            obj.voBrainmetastasesTargeted = voBrainmetastasesTargeted;
            
            obj.sREDCapDataCollectionNotes = sREDCapDataCollectionNotes;
            obj.dREDCapRepeatInstance = dREDCapRepeatInstance;
            
            obj.dMySQLPrimaryKey = dMySQLPrimaryKey;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtTreatmentDate = GetTreatmentDate(obj)
            dtTreatmentDate = obj.dtTreatmentDate;
        end
                
        function bBool = IsBrainMetastasisTargeted(obj, dBrainMetastasisNumber)
            arguments
                obj (1,1) RadionecrosisTreatment
                dBrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if obj.eType == RadionecrosisTreatmentType.HyperbaricOxygen || obj.eType == RadionecrosisTreatmentType.Dexamethasone
                bBool = true;
            elseif obj.eType == RadionecrosisTreatmentType.Resection
                bBool = false;
                
                for dBMIndex=1:length(obj.voBrainmetastasesTargeted)
                    if obj.voBrainmetastasesTargeted(dBMIndex).GetBrainMetastasisNumber() == dBrainMetastasisNumber
                        bBool = true;
                        break;
                    end
                end
            else
                error(...
                    'RadionecrosisTreatment:IsBrainMetastasisTargeted:Other',...
                    'Type "Other" must be manually accounted for');                
            end
        end
    end
    
    
    methods (Access = public, Static)
        
        function voTreatments = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            sTable = "radionecrosis_treatments";
            sWhere = "WHERE radionecrosis_treatments.fk_radionecrosis_treatments_patient_study_id = " + string(dPatientStudyId);
            sOrderBy = "ORDER BY radionecrosis_treatments.treatment_date";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTable, [], sWhere, sOrderBy);
            
            dNumTreatments = size(tOutput,1);
            
            if dNumTreatments == 0
                voTreatments = RadionecrosisTreatment.empty;
            else
                c1oTherapies = cell(dNumTreatments,1);
                
                for dTreatmentIndex=1:dNumTreatments
                    tOutputRow = tOutput(dTreatmentIndex,:);
                    
                    dtTreatmentDate = tOutputRow.treatment_date{1};
                    
                    eType = RadionecrosisTreatmentType.GetEnumFromMySQLEnumValue(tOutputRow.type{1});
                    sTypeOther = tOutputRow.type_other{1};
                    
                    bNewBrainMetastasesTargeted = tOutputRow.new_metastases_targeted{1};
                    
                    chREDCapDataCollectionNotes = tOutputRow.data_collection_notes{1};
                    dREDCapRepeatInstance = tOutputRow.redcap_repeat_instance{1};
                    
                    sTable = "radionecrosis_treatments_has_brain_metastases";
                    sWhere = "WHERE radionecrosis_treatments_has_brain_metastases.fk_rt_has_bms_id_radionecrosis_treatments = " + string(tOutputRow.id_radionecrosis_treatments{1});
                    sOrderBy = "ORDER BY radionecrosis_treatments_has_brain_metastases.fk_rt_has_bms_brain_metastases_brain_metastasis_number";
                    
                    tTargetedBMsOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sTable, [], sWhere, sOrderBy);
                    
                    vdTargetedBrainMetastasesNumbers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(tTargetedBMsOutput.fk_rt_has_bms_brain_metastases_brain_metastasis_number);
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
                    
                    c1oTherapies{dTreatmentIndex} = RadionecrosisTreatment(dtTreatmentDate, eType, sTypeOther, bNewBrainMetastasesTargeted, voTargetedBrainMetastases, chREDCapDataCollectionNotes, dREDCapRepeatInstance, tOutputRow.id_radionecrosis_treatments{1});
                end
                
                voTreatments = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oTherapies);
            end
        end
        
        function voValidationRecords = Validate(voRadionecrosisTreatments, oParentPatient, voValidationRecords)
            for dTreatmentIndex=1:length(voRadionecrosisTreatments)
                oTreatment = voRadionecrosisTreatments(dTreatmentIndex);
                
                % - dtTreatmentDate 
                % -- isempty
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
                for dBMIndex=1:length(oTreatment.voBrainmetastasesTargeted)
                    if oTreatment.voBrainmetastasesTargeted(dBMIndex).GetBrainMetastasisNumber() > oParentPatient.GetNumberOfBrainMetastases()
                        voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(oTreatment, "voBrainmetastasesTargeted", "Invalid brain metastasis number"));
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

