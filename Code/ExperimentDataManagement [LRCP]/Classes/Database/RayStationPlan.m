classdef RayStationPlan
    %RayStationPlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sName (1,1) string
        voBeamSets (:,1) RayStationBeamSet = RayStationBeamSet.empty(0,1)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RayStationPlan(sName, voBeamSets)        
            arguments
                sName (1,1) string
                voBeamSets (:,1) RayStationBeamSet = RayStationBeamSet.empty(0,1)                
            end
            
            % validate beam sets
            vdBrainMetNumbers = [];
            
            for dBeamSetIndex=1:length(voBeamSets)
                vdBrainMetNumbers = [vdBrainMetNumbers; voBeamSets(dBeamSetIndex).GetTargetedBrainMetastasisNumbers()];
            end
            
            if length(unique(vdBrainMetNumbers)) ~= length(vdBrainMetNumbers)
                error(...
                    'RayStationPlan:Constructor:InvalidBrainMetNumbersAcrossBeamSets',...
                    'The same brain met number is found across multiple beam sets.');
            end
            
            % set properities
            obj.sName = sName;
            obj.voBeamSets = voBeamSets;
        end
        
        function dNumBeamSets = GetNumberOfBeamSets(obj)
            dNumBeamSets = length(obj.voBeamSets);
        end
        
        function voBeamSets = GetBeamSets(obj)
            voBeamSets = obj.voBeamSets;
        end
        
        function dNumBrainMets = GetNumberOfTargetedBrainMetastases(obj)
            dNumBrainMets = 0;
            
            for dBeamSetIndex=1:length(obj.voBeamSets)
                dNumBrainMets = dNumBrainMets + obj.voBeamSets(dBeamSetIndex).GetNumberOfTargetedBrainMetastases();
            end
        end
        
        function bBool = ContainsTargetedBrainMetastatsisNumber(obj, dTargetedBrainMetNumber)
            bBool = false;
            
            for dBeamSetIndex=1:length(obj.voBeamSets)
                if obj.voBeamSets(dBeamSetIndex).ContainsTargetedBrainMetastatsisNumber(dTargetedBrainMetNumber)
                    bBool = true;
                    break;
                end
            end
        end
        
        function oBeamSet = GetBeamSetWithTargetedBrainMetastatsisNumber(obj, dTargetedBrainMetNumber)
            oBeamSet = [];
            
            for dBeamSetIndex=1:length(obj.voBeamSets)
                if obj.voBeamSets(dBeamSetIndex).ContainsTargetedBrainMetastatsisNumber(dTargetedBrainMetNumber)
                    oBeamSet = obj.voBeamSets(dBeamSetIndex);
                    break;
                end
            end
            
            if isempty(oBeamSet)
                error(...
                    'RayStationPlan:GetBeamSetWithTargetedBrainMetastatsisNumber:NoBeamSetFound',...
                    'No beam set with the targeted brain metastasis number provided found.');
            end
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

