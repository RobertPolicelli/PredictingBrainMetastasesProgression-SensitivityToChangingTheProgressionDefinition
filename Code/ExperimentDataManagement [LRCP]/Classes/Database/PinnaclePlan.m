classdef PinnaclePlan
    %PinnaclePlan
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sName (1,1) string
        voPlanTrials (:,1) PinnaclePlanTrial = PinnaclePlanTrial.empty(0,1)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = PinnaclePlan(sName, voTrials)        
            arguments
                sName (1,1) string
                voTrials (:,1) PinnaclePlanTrial = PinnaclePlanTrial.empty(0,1)                
            end
            
            % validate beam sets
            vdBrainMetNumbers = [];
            
            for dPlanTrialIndex=1:length(voTrials)
                vdBrainMetNumbers = [vdBrainMetNumbers; voTrials(dPlanTrialIndex).GetTargetedBrainMetastasisNumbers()];
            end
            
            if length(unique(vdBrainMetNumbers)) ~= length(vdBrainMetNumbers)
                error(...
                    'PinnaclePlan:Constructor:InvalidBrainMetNumbersAcrossPlanTrials',...
                    'The same brain met number is found across multiple beam sets.');
            end
            
            % set properities
            obj.sName = sName;
            obj.voPlanTrials = voTrials;
        end
        
        function dNumPlanTrials = GetNumberOfPlanTrials(obj)
            dNumPlanTrials = length(obj.voPlanTrials);
        end
        
        function voPlanTrials = GetPlanTrials(obj)
            voPlanTrials = obj.voPlanTrials;
        end
        
        function dNumBrainMets = GetNumberOfTargetedBrainMetastases(obj)
            dNumBrainMets = 0;
            
            for dPlanTrialIndex=1:length(obj.voPlanTrials)
                dNumBrainMets = dNumBrainMets + obj.voPlanTrials(dPlanTrialIndex).GetNumberOfTargetedBrainMetastases();
            end
        end
        
        function bBool = ContainsTargetedBrainMetastatsisNumber(obj, dTargetedBrainMetNumber)
            bBool = false;
            
            for dPlanTrialIndex=1:length(obj.voPlanTrials)
                if obj.voPlanTrials(dPlanTrialIndex).ContainsTargetedBrainMetastatsisNumber(dTargetedBrainMetNumber)
                    bBool = true;
                    break;
                end
            end
        end
        
        function oPlanTrial = GetPlanTrialWithTargetedBrainMetastatsisNumber(obj, dTargetedBrainMetNumber)
            oPlanTrial = [];
            
            for dPlanTrialIndex=1:length(obj.voPlanTrials)
                if obj.voPlanTrials(dPlanTrialIndex).ContainsTargetedBrainMetastatsisNumber(dTargetedBrainMetNumber)
                    oPlanTrial = obj.voPlanTrials(dPlanTrialIndex);
                    break;
                end
            end
            
            if isempty(oPlanTrial)
                error(...
                    'PinnaclePlan:GetPlanTrialWithTargetedBrainMetastatsisNumber:NoPlanTrialFound',...
                    'No trial with the targeted brain metastasis number provided found.');
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

