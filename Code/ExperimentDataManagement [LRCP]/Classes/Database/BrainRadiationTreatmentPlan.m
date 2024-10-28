classdef BrainRadiationTreatmentPlan < handle
    %BrainRadiationTreatmentPlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sBrainRegionOfInterestName string {ValidationUtils.MustBeEmptyOrScalar} = string.empty
    end
    
    properties (Constant = true, GetAccess = private)
        sCTSimIMGPPBase = "IMGPP-002-001-000"
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract = true)
        sPath = GetCTSimDicomFolderPath(obj)
    end
    
    methods (Access = public)
        
        function obj = BrainRadiationTreatmentPlan()        
        end
        
        function SetBrainRegionOfInterestName(obj, sBrainRegionOfInterestName)
            arguments
                obj BrainRadiationTreatmentPlan
                sBrainRegionOfInterestName (1,1) string
            end
            
            if ~isempty(obj.sBrainRegionOfInterestName)
                error(...
                    'BrainRadiationTreatmentPlan:SetBrainRegionOfInterestName:NameAlreadySet',...
                    'The BrainRegionOfInterestName is already set.');
            end
            
            obj.sBrainRegionOfInterestName = sBrainRegionOfInterestName;
        end
        
        function oImageVolume = GetCTSimImageVolume(obj, dPatientPrimaryId)
            oImageVolume = ImageVolume.Load(fullfile(...
                Experiment.GetDataPath('ProcessedImagingDatabase'),...
                DicomImporter.GetDicomDatabasePatientFolderNameForPatientId(dPatientPrimaryId),...
                obj.GetCTSimDicomFolderPath(),...
                BrainRadiationTreatmentPlan.sCTSimIMGPPBase + ".mat"));
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

