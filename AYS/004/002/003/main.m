Experiment.StartNewSection('Analysis');

[vdPatientIds, vdBMNumbers] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-004-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'),...
    'vdPatientIdPerSample', 'vdBMNumberPerSample');

dNumberOfSamples = length(vdPatientIds);
vbRemoveBMAtEnd = false(dNumberOfSamples, 1);
vsTrajectoryPerSample = strings(dNumberOfSamples,1);
vbIsPsuedoDD = FileIOUtils.LoadMatFile("vbIsPsuedoDD.mat", "IsPsuedoDD");
vbIsProgressionPerSample = false(dNumberOfSamples,1);
vbIsPsuedoPerSample = false(dNumberOfSamples,1);
vbIsPsuedoPerSample(vbIsPsuedoDD == 1) = true;
vbIsProgressionPerSample(vbIsPsuedoDD == 1) = false;
StartingDi = [];
for dSampleIndex=75:dNumberOfSamples
    dPatientId = vdPatientIds(dSampleIndex);
    dBMNumber = vdBMNumbers(dSampleIndex);
    
    %disp(string(dPatientId) + "-" + string(dBMNumber));
    
    oPatient = Patient.LoadFromDatabase(dPatientId);   
    
    [~, oPreRadiationRadiologyAssessment, voFollowUpRadiologyAssessments] = oPatient.GetRadiologyAssessmentsForBrainMetastasis(dBMNumber);
    
    % Pre-treatment Measurements
    dStartingRANO_mm = oPreRadiationRadiologyAssessment.GetRANOMeasurement_mm();
    StartingDi = [StartingDi;dStartingRANO_mm];
%     dStartingDiameterSum_mm = oPreRadiationRadiologyAssessment.GetSumofDiameter_mm();
%     if dStartingRANO_mm == 0 && dStartingDiameterSum_mm ~=0
%         vbRemoveBMAtEnd(dSampleIndex) = true;
%     end
%     % Follow-up Measurements
%     % - Any time followups
%     dNumFollowUps = length(voFollowUpRadiologyAssessments);
%     
%     vdtFollowUpRadiologyAssessmentDates = NaT(dNumFollowUps,1);
%     vdFollowUpRadiologyAssessmentTimeFromTreatment_months = zeros(dNumFollowUps,1);
%     vdFollowUpRadiologyAssessmentRANOLength_mm = zeros(dNumFollowUps,1);
%     vdFollowUpRadiologyAssessmentDiameterSum_mm = zeros(dNumFollowUps,1);
%     
%     dtBrainRTTreatmentDate = oPatient.GetFirstBrainRadiationTherapyDate();
%     
%     for dFollowUpIndex=1:dNumFollowUps
%         vdtFollowUpRadiologyAssessmentDates(dFollowUpIndex) = voFollowUpRadiologyAssessments(dFollowUpIndex).GetScanDate();
%         vdFollowUpRadiologyAssessmentTimeFromTreatment_months(dFollowUpIndex) = calmonths(between(dtBrainRTTreatmentDate, voFollowUpRadiologyAssessments(dFollowUpIndex).GetScanDate()));
%         vdFollowUpRadiologyAssessmentRANOLength_mm(dFollowUpIndex) = voFollowUpRadiologyAssessments(dFollowUpIndex).GetRANOMeasurement_mm();
%         vdFollowUpRadiologyAssessmentDiameterSum_mm(dFollowUpIndex) = voFollowUpRadiologyAssessments(dFollowUpIndex).GetSumofDiameter_mm();
%     end
%     
%     vbKeepFollowUp = vdFollowUpRadiologyAssessmentTimeFromTreatment_months <= 24; % disregard past 2 years
%     vdFollowUpRadiologyAssessmentRANOLength_mm = vdFollowUpRadiologyAssessmentRANOLength_mm(vbKeepFollowUp); 
%     vdFollowUpRadiologyAssessmentDiameterSum_mm = vdFollowUpRadiologyAssessmentDiameterSum_mm(vbKeepFollowUp);
%     vbDeleteRANO = vdFollowUpRadiologyAssessmentRANOLength_mm ==0 & vdFollowUpRadiologyAssessmentDiameterSum_mm ~= 0;
%     vdFollowUpRadiologyAssessmentRANOLength_mm = vdFollowUpRadiologyAssessmentRANOLength_mm(~vbDeleteRANO);
%                 
%     vdChangeInComparisonToPreviousFollowUps = zeros(length(vdFollowUpRadiologyAssessmentRANOLength_mm)+1,1); % -1: decrease, +1: increase, 0: no large change
%         
%     vdRANOIncludingBaseline = [dStartingRANO_mm; vdFollowUpRadiologyAssessmentRANOLength_mm];
%     
%     for dFollowUpIndex=1:length(vdFollowUpRadiologyAssessmentRANOLength_mm)
%         dCurrentDiameter = vdFollowUpRadiologyAssessmentRANOLength_mm(dFollowUpIndex);
%         
%         for dLookBackIndex = dFollowUpIndex : -1 : 1
%             dChange = ComputeChangeAtTwoTimepoints(vdRANOIncludingBaseline(dLookBackIndex), dCurrentDiameter);
%             
%             if dChange == -1
%                 vdChangeInComparisonToPreviousFollowUps(dFollowUpIndex+1) = -1;
%                 break;
%             elseif dChange == +1
%                 vdChangeInComparisonToPreviousFollowUps(dFollowUpIndex+1) = +1;
%                 break;
%             end
%             
%             if vdChangeInComparisonToPreviousFollowUps(dLookBackIndex) ~= 0
%                 break;
%             end
%         end
%     end
%     
%     vdChangeInComparisonToPreviousFollowUps(vdChangeInComparisonToPreviousFollowUps == 0) = [];
%     
%     vbRemove = false(size(vdChangeInComparisonToPreviousFollowUps));
%     
%     for dCheckIndex=2:length(vbRemove)
%         if vdChangeInComparisonToPreviousFollowUps(dCheckIndex) == vdChangeInComparisonToPreviousFollowUps(dCheckIndex-1)
%             vbRemove(dCheckIndex) = true;
%         end
%     end
%     
%     vdChangeInComparisonToPreviousFollowUps(vbRemove) = [];
%     
%     chChangeSequence = repmat(' ', [1,length(vdChangeInComparisonToPreviousFollowUps)]);
%     chChangeSequence(vdChangeInComparisonToPreviousFollowUps == -1) = '-';
%     chChangeSequence(vdChangeInComparisonToPreviousFollowUps == 1) = '+';
%     if length(chChangeSequence) < 2
%         vbIsPsuedoPerSample(dSampleIndex) = false;
%     end
%     vsTrajectoryPerSample(dSampleIndex) = string(chChangeSequence);
%     
end
StartingDi(108) = [];
StartingDi(24) = [];
% "": no increase or decrease
% "-": decrease
% "+": increase
% "-+": decrease then increase
% "+-": increase then decrease
% "-+-": decrease then increase then decrease
% "-+-+": decrease then increase then decrease then increase
vsTrajectoryPerSample = vsTrajectoryPerSample(~vbRemoveBMAtEnd);
dNumberOfSamples = dNumberOfSamples - sum(vbRemoveBMAtEnd);
vbIsProgressionPerSample = vbIsProgressionPerSample(~vbRemoveBMAtEnd);
vbIsPsuedoPerSample = vbIsPsuedoPerSample(~vbRemoveBMAtEnd);
vbIsRadionecrosisPerSample = false(dNumberOfSamples,1);
vbIsAdverseRadiationEffectPerSample = false(dNumberOfSamples,1);
vbHasConfoundingFactorsPerSample = false(dNumberOfSamples,1);


% "" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "") = false;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "") = false;


% "-" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "-") = false;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "-") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "-") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "-") = false;


% "+" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "+") = true;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "+") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "+") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "+") = false;


% "+-" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "+-") = false;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "+-") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "+-") = true;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "+-") = false;


% "-+" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "-+") = true;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "-+") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "-+") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "-+") = false;


% "-+-" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "-+-") = false;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "-+-") = true;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "-+-") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "-+-") = false;


% "-+-+" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "-+-+") = true;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "-+-+") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "-+-+") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "-+-+") = false;

vbIsProgressionPerSample(vbIsPsuedoPerSample == 1) = false;


% Special Cases:
vbIsProgressionPerSample(77) = true;
vbIsRadionecrosisPerSample(77) = false;
vbIsAdverseRadiationEffectPerSample(77) = false;
vbIsProgressionPerSample(78) = true;
vbIsRadionecrosisPerSample(78) = false;
vbIsAdverseRadiationEffectPerSample(78) = false;


% Save to disk
FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'Outcomes Per Sample.mat'),...
    'vbIsProgressionPerSample', vbIsProgressionPerSample,...
    'vbIsRadionecrosisPerSample', vbIsRadionecrosisPerSample,...
    'vbIsAdverseRadiationEffectPerSample', vbIsAdverseRadiationEffectPerSample,...
    'vbHasConfoundingFactorsPerSample', vbHasConfoundingFactorsPerSample);


function dChange = ComputeChangeAtTwoTimepoints(dDiameter1, dDiameter2)
% for two diameters (dDiameter1, dDiameter2), for which dDiameter1 is the first
% diameter temporalily, the change is given as:
% -1: decrease
%  0: stable
% +1: increase
% where a 25% change is used to define an increase or decrease (as per
% Rodrigues 2013 definition).
% HOWEVER, this falls down for small BMs, as a 25% change is very easy to
% occur. Therefore we look to RANO-BM for guidance on small BMs.
% According to RANO-BM for *uni-dimensional* measurements, for small (<10
% mm largest diameter) BMs, at least a 3mm change in the largest diameter
% is needed to indicate progression. 

    if dDiameter1 <= 10 || dDiameter2 <= 10 % then 3mm minimum change is used
        if dDiameter2 - dDiameter1 >= 3
            dChange = +1;
        elseif dDiameter2 - dDiameter1 <= -3
            dChange = -1;
        else
            dChange = 0;
        end
    else
        dPercentChange = (dDiameter2/dDiameter1)-1;
        
        if dPercentChange >= 0.20
            dChange = +1;
        elseif dPercentChange <= -0.30
            dChange = -1;
        else
            dChange = 0;
        end
    end
end
