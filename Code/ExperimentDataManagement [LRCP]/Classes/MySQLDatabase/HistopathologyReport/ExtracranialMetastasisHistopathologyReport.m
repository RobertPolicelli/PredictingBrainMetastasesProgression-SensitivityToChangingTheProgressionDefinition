classdef ExtracranialMetastasisHistopathologyReport < MalignantHistopathologyReport & matlab.mixin.Heterogeneous
    %ExtracranialMetastasisHistopathologyReport
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExtracranialMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType)
            %obj = ExtracranialMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType)
            
            obj@MalignantHistopathologyReport(dtDate, ePrimaryCancerSite, sREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
    end
    
    
    methods (Access = public, Static)
        
        function voReports = LoadFromDatabaseByPatientStudyId(dPatientStudyId)
            sJoin = "histopathology_reports " + ...
                "RIGHT JOIN extracranial_histopathology_reports ON histopathology_reports.id_histopathology_reports = extracranial_histopathology_reports.fk_extracranial_histopath_reports_id_histopathology_reports " +...
                "LEFT JOIN lung_cancer_receptor_reports ON histopathology_reports.id_histopathology_reports = lung_cancer_receptor_reports.fk_lung_cancer_receptor_reports_id_histopathology_reports " + ...
                "LEFT JOIN breast_cancer_receptor_reports ON histopathology_reports.id_histopathology_reports = breast_cancer_receptor_reports.fk_breast_cancer_receptor_reports_id_histopathology_reports";
            sWhere = "WHERE " + ...
                "histopathology_reports.fk_histopathology_reports_patient_study_id = " + string(dPatientStudyId) + " AND " +...
                "extracranial_histopathology_reports.source = '" + ExtracranialHistopathologySource.ExtracranialMetastasis.GetMySQLEnumValue() + "'";
            sOrderBy = "ORDER BY histopathology_reports.date";
            
            tOutput = SQLUtilities.SelectFromDatabase(MySQLDatabase.GetConnection(), sJoin, [], sWhere, sOrderBy);
            
            dNumReports = size(tOutput,1);
            
            if dNumReports == 0
                voReports = ExtracranialMetastasisHistopathologyReport.empty;
            else
                c1oReports = cell(dNumReports,1);
                
                for dReportIndex=1:dNumReports
                    tOutputRow = tOutput(dReportIndex,:);
                    
                    dtDate = tOutputRow.date{1};
                    ePrimaryCancerSite = PrimaryCancerSite.GetEnumFromMySQLEnumValue(tOutputRow.primary_cancer{1});
                    chREDCapDataCollectionNotes = tOutputRow.data_collection_notes{1};
                    dREDCapRepeatInstance = tOutputRow.redcap_repeat_instance{1};
                    eHistopathologyDifferentiation = HistopathologyDifferentiation.GetEnumFromMySQLEnumValue(tOutputRow.differentiation{1});
                    
                    if ePrimaryCancerSite == PrimaryCancerSite.Lung
                        vdMySQLPrimaryKey = [tOutputRow.id_histopathology_reports{1}, tOutputRow.id_extracranial_histopathology_reports{1}, tOutputRow.id_lung_cancer_receptor_reports{1}];
                        
                        eHistopathologyType = HistopathologyType.GetEnumFromMySQLEnumValue(tOutputRow.lung_cancer_type{1});
                        
                        ePDL1Status = PDL1Status.GetEnumFromMySQLEnumValue(tOutputRow.pd_l1_status{1});
                        eALKStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.alk_status{1});
                        eEGFRStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.egfr_status{1});
                        eROS1Status = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.ros1_status{1});
                        eBRAFStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.braf_status {1});
                        eKRASStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.kras_status{1});
                        
                        c1oReports{dReportIndex} = LungCancerExtracranialMetastasisHistopathologyReport(dtDate, chREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, ePDL1Status, eALKStatus, eEGFRStatus, eROS1Status, eBRAFStatus, eKRASStatus);
                    elseif ePrimaryCancerSite == PrimaryCancerSite.Breast
                        vdMySQLPrimaryKey = [tOutputRow.id_histopathology_reports{1}, tOutputRow.id_extracranial_histopathology_reports{1}, tOutputRow.id_breast_cancer_receptor_reports{1}];
                        
                        eHistopathologyType = HistopathologyType.GetEnumFromMySQLEnumValue(tOutputRow.non_lung_cancer_type{1});
                        
                        eEstrogenReceptorStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.estrogen_status);
                        eProgesteroneReceptorStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.progesterone_status);
                        eHer2NeuReceptorStatus = BiomarkerStatus.GetEnumFromMySQLEnumValue(tOutputRow.her2_neu_status);
                        
                        c1oReports{dReportIndex} = BreastCancerExtracranialMetastasisHistopathologyReport(dtDate, chREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType, eEstrogenReceptorStatus, eProgesteroneReceptorStatus, eHer2NeuReceptorStatus);
                    else
                        vdMySQLPrimaryKey = [tOutputRow.id_histopathology_reports{1}, tOutputRow.id_extracranial_histopathology_reports{1}];
                        
                        eHistopathologyType = HistopathologyType.GetEnumFromMySQLEnumValue(tOutputRow.non_lung_cancer_type{1});
                        
                        c1oReports{dReportIndex} = ExtracranialMetastasisHistopathologyReport(dtDate, ePrimaryCancerSite, chREDCapDataCollectionNotes, dREDCapRepeatInstance, vdMySQLPrimaryKey, eHistopathologyDifferentiation, eHistopathologyType);
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
            voValidationRecords = ValidateReport@MalignantHistopathologyReport(obj, oParentPatient, voValidationRecords);            
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

