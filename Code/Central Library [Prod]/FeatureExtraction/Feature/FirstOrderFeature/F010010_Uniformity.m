classdef F010010_Uniformity < FirstOrderFeature
    %Image
    %
    % Based on Aerts et al. 2014, DOI: 10.1038/ncomms5006
    % Equation is on page 12 of supplementary materials
    
    % Primary Author: Salma Dammak
    % Created: May 10, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        sFeatureName = "F010010"
        sFeatureDisplayName = "Uniformity"
    end    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public)
        
        function obj = F010010_Uniformity()
        end
    end
    methods (Access = protected)
        function dValue = ExtractFeature(obj,oImage, oFeatureExtractionParameters)
            % dValue = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % SYNTAX:
            % dValue = ExtractFeature(obj, oImageVolumeHandler, oFeatureExtractionParameters)
            %
            % DESCRIPTION:
            %  Extracts the uniformity feature value.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Extraction object
            %  oImageVolumeHandler: Image volume handler to define the ROI
            %   and image to extract the feature.
            %  oFeatureExtractionParameters: Object containing all
            %   feature extraction parameterrs.
            %
            % OUTPUTS ARGUMENTS:
            %  dValue: Resulting feature value.

            % Primary Author: Salma Dammak
            % Created: May 10, 2019
            
            % Get mean
            [m3xImageData, m3bMask] = oImage.GetCurrentRegionOfInterestImageDataAndMask(oFeatureExtractionParameters);
            
            % Get the histogram using user specified number of bins
            vdNumberOfElementsInEachBin = histcounts(double(m3xImageData(m3bMask)),...
                oFeatureExtractionParameters.GetEntropyAndUniformityNumberOfBins()); 
            
            % Get the probability of the histogram
            vdProbabilityForEachBin = vdNumberOfElementsInEachBin./ sum(vdNumberOfElementsInEachBin);
            
            dValue = sum(vdProbabilityForEachBin.*vdProbabilityForEachBin);
            % Matches PyRadiomics for a bin size of 4. No hand calculations.
        end

    end
  
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************

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

