classdef Diagnosis
    %Diagnosis
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eDiseaseSite (1,1) DiseaseSite
        sDiseaseSiteCode (1,1) string
        dtDiagnosisDate (1,1) datetime % month and year are correct, ignore day (set to default of 1)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Diagnosis(sDiseaseSiteCode, dYear, dMonth)
            %obj = Diagnosis(sDiseaseSiteCode, dYear, dMonth)
            
            obj.eDiseaseSite = DiseaseSite.GetEnumFromImportLabel(sDiseaseSiteCode);
            obj.sDiseaseSiteCode = sDiseaseSiteCode;
            
            dtDiagnosisDate = datetime(dYear, dMonth, 1);
            
            if datetime(2000,1,1) > dtDiagnosisDate || datetime(2020,11,1) < dtDiagnosisDate
                error(...
                    'Diagnosis:Constructor:InvalidDate',...
                    'The date is invalid.');
            end
            
            obj.dtDiagnosisDate = dtDiagnosisDate;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function eDiseaseSite = GetDiseaseSite(obj)
            eDiseaseSite = obj.eDiseaseSite;
        end
        
        function dtDiagnosisDate = GetDiagnosisDate(obj)
            dtDiagnosisDate = obj.dtDiagnosisDate;
        end
        
        function sDiseaseSiteCode = GetDiseaseSiteCode(obj)
            sDiseaseSiteCode = obj.sDiseaseSiteCode;
        end
        
        function sDiseaseDescription = GetDiseaseSiteDescription(obj)
            persistent vsDiagnosisCodes;
            persistent vsDiagnosisDescriptions;
            
            if isempty(vsDiagnosisCodes) || isempty(vsDiagnosisDescriptions)
                [vsDiagnosisCodes, vsDiagnosisDescriptions] = FileIOUtils.LoadMatFile('DiagnosisCodeDescriptions.mat', 'vsDiagnosisCodes', 'vsDiagnosisDescriptions');
            end
            
            dMatchIndex = find(obj.sDiseaseSiteCode == vsDiagnosisCodes);
            
            if ~isscalar(dMatchIndex)
                error(...
                    'Diagnosis:GetDiseaseSiteDescription:CodeNotFound',...
                    'The code was not found in the lookup table.');
            end
            
            sDiseaseDescription = vsDiagnosisDescriptions(dMatchIndex);
        end
    end
    
    
    methods (Access = public, Static)
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

