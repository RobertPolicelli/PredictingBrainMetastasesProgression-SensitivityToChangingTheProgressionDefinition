Experiment.StartNewSection('Analysis');

[vdPatientIds, vdBMNumbers] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.mat'),...
    'vdPatientIdPerSample', 'vdBMNumberPerSample');

dNumberOfSamples = length(vdPatientIds);

vsTrajectoryPerSample = strings(dNumberOfSamples,1);
for dSampleIndex=1:dNumberOfSamples
    dPatientId = vdPatientIds(dSampleIndex);
    dBMNumber = vdBMNumbers(dSampleIndex);
    
    %disp(string(dPatientId) + "-" + string(dBMNumber));
    
    oPatient = Patient.LoadFromDatabase(dPatientId);   
    
    [~, oPreRadiationRadiologyAssessment, voFollowUpRadiologyAssessments] = oPatient.GetRadiologyAssessmentsForBrainMetastasis(dBMNumber);
    
    % Pre-treatment Measurements
    dStartingVolume_mm3 = oPreRadiationRadiologyAssessment.GetPseudoVolumetricMeasurement_mm();
    
    % Follow-up Measurements
    % - Any time followups
    dNumFollowUps = length(voFollowUpRadiologyAssessments);
    
    vdtFollowUpRadiologyAssessmentDates = NaT(dNumFollowUps,1);
    vdFollowUpRadiologyAssessmentTimeFromTreatment_months = zeros(dNumFollowUps,1);
    
    dtBrainRTTreatmentDate = oPatient.GetFirstBrainRadiationTherapyDate();
    
    for dFollowUpIndex=1:dNumFollowUps
        vdtFollowUpRadiologyAssessmentDates(dFollowUpIndex) = voFollowUpRadiologyAssessments(dFollowUpIndex).GetScanDate();
        vdFollowUpRadiologyAssessmentTimeFromTreatment_months(dFollowUpIndex) = calmonths(between(dtBrainRTTreatmentDate, voFollowUpRadiologyAssessments(dFollowUpIndex).GetScanDate()));
    end
    
    vbKeepFollowUp = vdFollowUpRadiologyAssessmentTimeFromTreatment_months < 24; % disregard past 2 years
    voFollowUpRadiologyAssessments = voFollowUpRadiologyAssessments(vbKeepFollowUp); 
    vdFollowUpVolumes_mm3 = zeros(length(voFollowUpRadiologyAssessments),1);
    
    for dAssessmentIndex=1:length(voFollowUpRadiologyAssessments)
        vdFollowUpVolumes_mm3(dAssessmentIndex) = voFollowUpRadiologyAssessments(dAssessmentIndex).GetPseudoVolumetricMeasurement_mm();
    end
                
    vdChangeInComparisonToPreviousFollowUps = zeros(length(vdFollowUpVolumes_mm3)+1,1); % -1: decrease, +1: increase, 0: no large change
        
    vdVolumesIncludingBaseline = [dStartingVolume_mm3; vdFollowUpVolumes_mm3];
    
    for dFollowUpIndex=1:length(vdFollowUpVolumes_mm3)
        dCurrentVolume = vdFollowUpVolumes_mm3(dFollowUpIndex);
        
        for dLookBackIndex = dFollowUpIndex : -1 : 1
            dChange = ComputeChangeAtTwoTimepoints(vdVolumesIncludingBaseline(dLookBackIndex), dCurrentVolume);
            
            if dChange == -1
                vdChangeInComparisonToPreviousFollowUps(dFollowUpIndex+1) = -1;
                break;
            elseif dChange == +1
                vdChangeInComparisonToPreviousFollowUps(dFollowUpIndex+1) = +1;
                break;
            end
            
            if vdChangeInComparisonToPreviousFollowUps(dLookBackIndex) ~= 0
                break;
            end
        end
    end
    
    vdChangeInComparisonToPreviousFollowUps(vdChangeInComparisonToPreviousFollowUps == 0) = [];
    
    vbRemove = false(size(vdChangeInComparisonToPreviousFollowUps));
    
    for dCheckIndex=2:length(vbRemove)
        if vdChangeInComparisonToPreviousFollowUps(dCheckIndex) == vdChangeInComparisonToPreviousFollowUps(dCheckIndex-1)
            vbRemove(dCheckIndex) = true;
        end
    end
    
    vdChangeInComparisonToPreviousFollowUps(vbRemove) = [];
    
    chChangeSequence = repmat(' ', [1,length(vdChangeInComparisonToPreviousFollowUps)]);
    chChangeSequence(vdChangeInComparisonToPreviousFollowUps == -1) = '-';
    chChangeSequence(vdChangeInComparisonToPreviousFollowUps == 1) = '+';
    
    vsTrajectoryPerSample(dSampleIndex) = string(chChangeSequence);
end

% "": no increase or decrease
% "-": decrease
% "+": increase
% "-+": decrease then increase
% "+-": increase then decrease
% "-+-": decrease then increase then decrease
% "-+-+": decrease then increase then decrease then increase

vbIsProgressionPerSample = false(dNumberOfSamples,1);
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

% - Special cases:
vbSampleSelect = vdPatientIds == 3 & vdBMNumbers == 3;

vbIsProgressionPerSample(vbSampleSelect) = true;
vbIsAdverseRadiationEffectPerSample(vbSampleSelect) = false;


vbSampleSelect = vdPatientIds == 16 & vdBMNumbers == 1;

vbIsRadionecrosisPerSample(vbSampleSelect) = true;
vbIsAdverseRadiationEffectPerSample(vbSampleSelect) = false;


vbSampleSelect = vdPatientIds == 65 & vdBMNumbers == 1;

vbHasConfoundingFactorsPerSample(vbSampleSelect) = true;


vbSampleSelect = vdPatientIds == 89 & vdBMNumbers == 1;

vbHasConfoundingFactorsPerSample(vbSampleSelect) = true;


vbSampleSelect = vdPatientIds == 90 & vdBMNumbers == 2;

vbHasConfoundingFactorsPerSample(vbSampleSelect) = true;


vbSampleSelect = vdPatientIds == 429 & vdBMNumbers == 1;

vbIsRadionecrosisPerSample(vbSampleSelect) = true;
vbIsAdverseRadiationEffectPerSample(vbSampleSelect) = false;


% "-+" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "-+") = true;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "-+") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "-+") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "-+") = false;

% - Special cases:
vbSampleSelect = vdPatientIds == 192 & vdBMNumbers == 2;

vbHasConfoundingFactorsPerSample(vbSampleSelect) = true;


% "-+-" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "-+-") = false;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "-+-") = true;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "-+-") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "-+-") = false;

% - Special cases:
vbSampleSelect = vdPatientIds == 192 & vdBMNumbers == 1;

vbIsProgressionPerSample(vbSampleSelect) = true;
vbIsRadionecrosisPerSample(vbSampleSelect) = false;
vbHasConfoundingFactorsPerSample(vbSampleSelect) = true;


% "-+-+" Trajectory
vbIsProgressionPerSample(vsTrajectoryPerSample == "-+-+") = true;
vbIsRadionecrosisPerSample(vsTrajectoryPerSample == "-+-+") = false;
vbIsAdverseRadiationEffectPerSample(vsTrajectoryPerSample == "-+-+") = false;
vbHasConfoundingFactorsPerSample(vsTrajectoryPerSample == "-+-+") = false;


% Save to disk
FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'Outcomes Per Sample.mat'),...
    'vbIsProgressionPerSample', vbIsProgressionPerSample,...
    'vbIsRadionecrosisPerSample', vbIsRadionecrosisPerSample,...
    'vbIsAdverseRadiationEffectPerSample', vbIsAdverseRadiationEffectPerSample,...
    'vbHasConfoundingFactorsPerSample', vbHasConfoundingFactorsPerSample);


function dChange = ComputeChangeAtTwoTimepoints(dVolume1, dVolume2)
% for two volumes (dVolume1, dVolume2), for which dVolume1 is the first
% volume temporalily, the change is given as:
% -1: decrease
%  0: stable
% +1: increase
% where a 25% change is used to define an increase or decrease (as per
% Rodrigues 2013 definition).
% HOWEVER, this falls down for small BMs, as a 25% change is very easy to
% occur. Therefore we look to RANO-BM for guidance on small BMs.
% According to RANO-BM for *uni-dimensional* measurements, for small (<10
% mm largest diameter) BMs, at least a 3mm change in the largest diameter
% is needed to indicate progression. Taking this to 3D, that would
% correspond to a 3x3x3=27mm3 volume change.
% We can then find at which BM volume a 27mm3 change is equivalent to the
% 25% change used (e.g. 27mm3/25% = 108mm3). Therefore if either dVolume1
% or dVolume2 is less than 108, the absolute change of 27mm3 will be used,
% otherwise, the relative 25% measure is used.

    if dVolume1 <= 135 || dVolume2 <= 135 % then (3mm)^3 minimum change is used
        if dVolume2 - dVolume1 >= 27
            dChange = +1;
        elseif dVolume2 - dVolume1 <= -27
            dChange = -1;
        else
            dChange = 0;
        end
    else
        dPercentChange = (dVolume2/dVolume1)-1;
        
        if dPercentChange >= 0.20
            dChange = +1;
        elseif dPercentChange <= -0.20
            dChange = -1;
        else
            dChange = 0;
        end
    end
end
