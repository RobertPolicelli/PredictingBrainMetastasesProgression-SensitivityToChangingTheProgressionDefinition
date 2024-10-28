classdef (Abstract) BrainMetastasisHistopathologyReport < HistopathologyReport & matlab.mixin.Heterogeneous
    %BrainMetastasisHistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        oSampledBrainMetastasis BrainMetastasis {ValidationUtils.MustBeEmptyOrScalar}
        
        bNecrosisPresent (1,1) logical
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, oSampledBrainMetastasis, bNecrosisPresent)
            %obj = BrainMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, oSampledBrainMetastasis, bNecrosisPresent)
            
            obj@HistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey);
            
            obj.oSampledBrainMetastasis = oSampledBrainMetastasis;
            obj.bNecrosisPresent = bNecrosisPresent;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function bNecrosisPresent = IsNecrosisPresent(obj)
            bNecrosisPresent = obj.bNecrosisPresent;
        end
        
        function bBool = IsBrainMetastasisSampled(obj, dBrainMetastasisNumber)
            bBool = obj.oSampledBrainMetastasis.GetBrainMetastasisNumber() == dBrainMetastasisNumber;
        end
    end
    
    
    methods (Access = public, Static)
        
        function voReports = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            sJoin = "histopathology_reports " + ...
                "RIGHT JOIN brain_metastasis_histopathology_reports ON histopathology_reports.id_histopathology_reports = brain_metastasis_histopathology_reports.fk_bm_histopathology_reports_id_histopathology_reports " +...
                "LEFT JOIN lung_cancer_receptor_reports ON histopathology_reports.id_histopathology_reports = lung_cancer_receptor_reports.fk_lung_cancer_receptor_reports_id_histopathology_reports " + ...
                "LEFT JOIN breast_cancer_receptor_reports ON histopathology_reports.id_histopathology_reports = breast_cancer_receptor_reports.fk_breast_cancer_receptor_reports_id_histopathology_reports";
            sWhere = "WHERE histopathology_reports.fk_histopathology_reports_patient_study_id = " + string(dPatientStudyId);
            sOrderBy = "ORDER BY histopathology_reports.date";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoin, [], sWhere, sOrderBy);
            
            dNumReports = size(tOutput,1);
            
            if dNumReports == 0
                voReports = MalignantBrainMetastasisHistopathologyReport.empty;
            else
                c1oReports = cell(dNumReports,1);
                
                for dReportIndex=1:dNumReports
                    tOutputRow = tOutput(dReportIndex,:);
                    
                    dtDate = tOutputRow.date{1};
                    ePrimaryCancerSite = PrimaryCancerSite.GetEnumFromMySQLEnumValue(tOutputRow.primary_cancer{1});
                    chREDCapDataCollectionNotes = tOutputRow.data_collection_notes{1};
                    dREDCapRepeatInstance = tOutputRow.redcap_repeat_instance{1};
                    bNecrosisPresent = tOutputRow.necrosis_present{1};
                    
                    dBMNumber = tOutputRow.sampled_brain_metastasis_number{1};
                    
                    if isempty(dBMNumber)
                        oSampledBM = BrainMetastasis.empty;
                    else
                        oSampledBM = BrainMetastasis(dBMNumber, [dPatientStudyId,dBMNumber]);
                    end
                    
                    if tOutputRow.malignancy_present{1}
                        eHistopathologyDifferentiation = HistopathologyDifferentiation.GetEnumFromMySQLEnumValue(tOutputRow.differentiation{1});
                        
                        if ePrimaryCancerSite == PrimaryCancerSite.Lung
                            vdMySQLPrimaryKey = [tOutputRow.id_histopathology_reports{1}, tOutputRow.id_brain_metastasis_histopathology_reports{1}, tOutputRow.id_lung_cancer_receptor_reports{1}];
                            
                            eHistopathologyType = HistopathologyType.GetEnumFromMySQLEnumValue(tOutputRow.lung_cancer_type{1});
                            
                            ePDL1Status = PDL1Status.GetEnumFromMySQLEnumValue(tOutputRow.pd_l1_status{1});
                            eALKStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.alk_status{1});
                            eEGFRStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.egfr_status{1});
                            eROS1Status = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.ros1_status{1});
                            eBRAFStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.braf_status {1});
                            eKRASStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.kras_status{1});
                            
                            c1oReports{dReportIndex} = LungCancerBrainMetastasisHistopathologyReport(dtDate, chREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, ePDL1Status, eALKStatus, eEGFRStatus, eROS1Status, eBRAFStatus, eKRASStatus, oSampledBM, bNecrosisPresent);                                                                                                    
                        elseif ePrimaryCancerSite == PrimaryCancerSite.Breast
                            vdMySQLPrimaryKey = [tOutputRow.id_histopathology_reports{1}, tOutputRow.id_brain_metastasis_histopathology_reports{1}, tOutputRow.id_breast_cancer_receptor_reports{1}];
                            
                            eHistopathologyType = HistopathologyType.GetEnumFromMySQLEnumValue(tOutputRow.non_lung_cancer_type{1});
                            
                            eEstrogenReceptorStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.estrogen_status);
                            eProgesteroneReceptorStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.progesterone_status);
                            eHer2NeuReceptorStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.her2_neu_status);
                            
                            c1oReports{dReportIndex} = BreastCancerBrainMetastasisHistopathologyReport(dtDate, chREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, eEstrogenReceptorStatus, eProgesteroneReceptorStatus, eHer2NeuReceptorStatus, oSampledBM, bNecrosisPresent);
                        else
                            vdMySQLPrimaryKey = [tOutputRow.id_histopathology_reports{1}, tOutputRow.id_brain_metastasis_histopathology_reports{1}];
                            
                            eHistopathologyType = HistopathologyType.GetEnumFromMySQLEnumValue(tOutputRow.non_lung_cancer_type{1});
                            
                            c1oReports{dReportIndex} = MalignantBrainMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, chREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, oSampledBM, bNecrosisPresent);
                        end
                    else                        
                        vdMySQLPrimaryKey = [tOutputRow.id_histopathology_reports{1}, tOutputRow.id_brain_metastasis_histopathology_reports{1}];
                        
                        c1oReports{dReportIndex} = NonMalignantBrainMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, chREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, oSampledBM, bNecrosisPresent);
                    end
                end
                
                voReports = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oReports);
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                       PROTECTED METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function voValidationRecords = ValidateReport(obj, oParentPatient, voValidationRecords)
            voValidationRecords = ValidateReport@HistopathologyReport(obj, oParentPatient, voValidationRecords);
            
            % - oSampledBrainMetastasis
            % -- BM number exceeds number of BMs
            if obj.oSampledBrainMetastasis.GetBrainMetastasisNumber() > oParentPatient.GetNumberOfBrainMetastases()
                voValidationRecords = DataValidationRecord.ProcessValidationError(voValidationRecords, DataValidationRecord(obj, "oSampledBrainMetastasis", "Brain metastasis number exceeds the number of brain metastases"));
            end
        
            % - bNecrosisPresent
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

