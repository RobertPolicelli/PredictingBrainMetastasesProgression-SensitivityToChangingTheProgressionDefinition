classdef REDCapPrimaryCancerInformation < matlab.mixin.Heterogeneous
    %REDCapPrimaryCancerInformation
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        ePrimaryCancerSite (1,1) REDCapPrimaryCancerSite
        
        dtHistopathologyDate (1,1) datetime
        eHistopathologyDifferentiation (1,1) REDCapHistopathologyDifferentiation
        eHistopathologyType (1,1) {ValidationUtils.MustBeA(eHistopathologyType, ["REDCapLungCancerHistopathologyType", "REDCapHistopathologyType"])} = REDCapHistopathologyType.CarcinomaAdeno
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapPrimaryCancerInformation(ePrimaryCancerSite, dtHistopathologyDate, eHistopathologyDifferentiation, eHistopathologyType)
            %obj = REDCapPrimaryCancerInformation(ePrimaryCancerSite, dtHistopathologyDate, eHistopathologyDifferentiation, eHistopathologyType)
            
            obj.ePrimaryCancerSite = ePrimaryCancerSite;
            obj.dtHistopathologyDate = dtHistopathologyDate;
            obj.eHistopathologyDifferentiation = eHistopathologyDifferentiation;
            obj.eHistopathologyType = eHistopathologyType;            
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtHistopathologyDate = GetHistopathologyDate(obj)
            dtHistopathologyDate = obj.dtHistopathologyDate;
        end
        
        function ePrimaryCancerSite = GetPrimaryCancerSite(obj)
            ePrimaryCancerSite = obj.ePrimaryCancerSite;
        end
        
        function eHistopathologyDifferentiation = GetHistopathologyDifferentiation(obj)
            eHistopathologyDifferentiation = obj.eHistopathologyDifferentiation;
        end
        
        function eHistopathologyType = GetHistopathologyType(obj)
            eHistopathologyType = obj.eHistopathologyType;
        end
    end
    
    
    methods (Access = public, Static)
        
        function obj = CreateFromREDCapExport(c1xREDCapExportDataForPrimaryCancer, vsREDCapExportHeaders)
            eSite = REDCapPrimaryCancerSite.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_site"});
            dtDate = c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_histopathology_date"};
            eDifferentiation = REDCapHistopathologyDifferentiation.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_histopathology_differentiation"});
            
            if eSite == REDCapPrimaryCancerSite.Lung
                eType = REDCapLungCancerHistopathologyType.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_lung_histopathology_type"});
                
                ePDL1 = REDCapPDL1Status.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_lung_pd_l1"});
                eALK = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_lung_alk"});
                eEGFR = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_lung_egfr"});
                eROS1 = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_lung_ros1"});
                eBRAF = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_lung_braf"});
                eKRAS = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_lung_kras"});
                
                obj = REDCapLungPrimaryCancerInformation(eSite, dtDate, eDifferentiation, eType, ePDL1, eALK, eEGFR, eROS1, eBRAF, eKRAS);
            else
                eType = REDCapHistopathologyType.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_non_lung_histopathology_type"});
                
                if eSite == REDCapPrimaryCancerSite.Breast
                    eEstrogen = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_breast_estrogen"});
                    eProgesterone = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_breast_progesterone"});
                    eHer2Neu = REDCapBiomarkerStatus.GetEnumFromREDCapCode(c1xREDCapExportDataForPrimaryCancer{vsREDCapExportHeaders == "primary_cancer_breast_her2_neu"});
                    
                    obj = REDCapBreastPrimaryCancerInformation(eSite, dtDate, eDifferentiation, eType, eEstrogen, eProgesterone, eHer2Neu);
                else
                    obj = REDCapPrimaryCancerInformation(eSite, dtDate, eDifferentiation, eType);
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

