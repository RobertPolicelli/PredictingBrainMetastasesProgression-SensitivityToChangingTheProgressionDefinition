% Experiment.StartNewSection('Progression');
% sExpCodes = ["001-113R", "001-112R","001-111R", "001-110R","001-109R","002-103","002-108", "002-118","002-120", "002-101",...
%     "003-101R","003-102R","003-103R","003-104R"];
% sLBLCodes = ["003-009R", "003-010R","003-012R", "003-012R","003-013R","004-008R","004-016", "004-018R","004-001R", "004-020R", "004-003",...
%     "005-001R","005-002R","005-003R","005-004R"];
% for CurrentExp = 1: length(sExpCodes)
% sExpCode_Radiomic_LRCP = fullfile("EXP-200-"+sExpCodes(CurrentExp));
% 
% oLBL = ExperimentManager.Load(fullfile("LBL-002-"+sLBLCodes(CurrentExp)));
% oLabelledFeatureValues = oLBL.GetLabelledFeatureValues();
% 
% dNumPositives = sum(oLabelledFeatureValues.GetLabels() == oLabelledFeatureValues.GetPositiveLabel());
% dNumNegatives = sum(oLabelledFeatureValues.GetLabels() == oLabelledFeatureValues.GetNegativeLabel());
% 
% [AUC, CI] = GenerateROCAndCIMetrics(sExpCode_Radiomic_LRCP);
% vdAUCs(CurrentExp) = AUC;
% CIMin(CurrentExp) = vdAUCs(CurrentExp)-CI(1);
% CIMax(CurrentExp) = CI(2)-vdAUCs(CurrentExp);
% 
% %disp(fullfile(sExpCodes(CurrentExp) + "    AUC: " + string(AUC)+ "  CI:  " + string(round(CI(1),3))+ "-" + string(round(CI(2),3))))
% end
Label = {'','F- <9 Months', 'F- <12 Months', 'F- <15 Months', 'F- <18 Months', 'F- <24 Months', 'S- >20% RANO-BM Diameter',...
    'S- >10% Volume', 'S- >15% Volume', 'S- >20% Volume', 'S- >25% Volume', 'T- True Progression',...
    'T- True and RN', 'T- True and PP', 'T- True and TRSC'};


Experiment.StartNewSection('Progression and Stable');
sExpCodes = ["001-120R", "001-119R","001-118R", "001-117R","001-116R","002-104","002-109", "002-119","002-121", "002-102",...
    "003-105R","003-106R","003-107R","003-108R"];
sLBLCodes = ["003-016R", "003-017R","003-018R", "003-019R","003-020R","004-002R","004-004", "004-007R","004-009R", "004-011R", "004-013R","004-015R",...
    "005-005R","005-006R","005-007R","005-008R"];
for CurrentExp = 1: length(sExpCodes)
sExpCode_Radiomic_LRCP = fullfile("EXP-200-"+sExpCodes(CurrentExp));

oLBL = ExperimentManager.Load(fullfile("LBL-002-"+sLBLCodes(CurrentExp)));
oLabelledFeatureValues = oLBL.GetLabelledFeatureValues();

dNumPositives = sum(oLabelledFeatureValues.GetLabels() == oLabelledFeatureValues.GetPositiveLabel());
dNumNegatives = sum(oLabelledFeatureValues.GetLabels() == oLabelledFeatureValues.GetNegativeLabel());

[AUC, CI] = GenerateROCAndCIMetrics(sExpCode_Radiomic_LRCP);
vdAUCs(CurrentExp) = AUC;
CIMin(CurrentExp) = vdAUCs(CurrentExp)-CI(1);
CIMax(CurrentExp) = CI(2)-vdAUCs(CurrentExp);
disp(fullfile(sExpCodes(CurrentExp) + "    AUC: " + string(AUC)+ "  CI:  " + string(round(CI(1),3))+ "-" + string(round(CI(2),3))))
end
hold on
chart = bar(vdAUCs)
set(chart,'FaceColor', '#d3d3d3');
errorbar([1:14],vdAUCs,CIMin,CIMax,'LineStyle','none', 'Color', 'k')
Label = {'','F- <9 Months', 'F- <12 Months', 'F- <15 Months', 'F- <18 Months', 'F- <24 Months', 'S- >-30% RANO-BM Diameter',...
    'S- >-10% Volume', 'S- >-15% Volume', 'S- >-20% Volume', 'S- >-25% Volume', 'T- True Progression',...
    'T- True and RN', 'T- True and PP', 'T- True and TRSC'};
set(gca, 'XTick', 0:1:107)
set(get(gca, 'XAxis'), 'FontWeight', 'bold');
set(get(gca, 'YAxis'), 'FontWeight', 'bold');
xticklabels(Label)
xtickangle(50)
ylabel("AUC [CI]",'FontWeight','bold')
xlabel("Experiment",'FontWeight','bold')
title("Model Performance (Progresseion + Stable BMs Vs Regression BMs)")
ylim([0.45 0.75])




function [AUC, CI] = GenerateROCAndCIMetrics(sExpCode)

sExpResultsPath = ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode);

vdAllAUCs = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "03 Performance", "AUC Metrics.mat"), "vdAUCPerBootstrap");
AUC = mean(vdAllAUCs);
SEM = std(vdAllAUCs)/sqrt(length(vdAllAUCs)); 
ts = tinv([0.025  0.975],length(vdAllAUCs)-1);  
CI = mean(vdAllAUCs) + ts*SEM;   

end
