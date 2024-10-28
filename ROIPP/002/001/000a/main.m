oDB = ExperimentManager.Load('DB-006-004');

sProcessedImageDatabaseRootPath = Experiment.GetDataPath('ProcessedImagingDatabase');

% get Patient IDs
m2dSampleIds = readmatrix(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-002-003-001'), '01 Analysis', 'SRS Analysis Cohort Sample IDs.xlsx'));

vdPatientIds = m2dSampleIds(:,1);
vdPatientIds = unique(vdPatientIds);

sROIPPLoadCode = "ROIPP-001-001-000a";

sIMGPPRegisterToCode = "IMGPP-002-001-000a";

sROIPPSaveCode = "ROIPP-002-001-000a";

bForceApplyTransforms = false;
bAppend = false;

for dPatientIndex=35%1:length(vdPatientIds)
    try
        disp(vdPatientIds(dPatientIndex));
        
        oPatient = oDB.GetPatientByPrimaryId(vdPatientIds(dPatientIndex));
        
        oT1wCEMRI = oPatient.LoadImageVolume(sIMGPPRegisterToCode);
        oROIs = oPatient.LoadRegionsOfInterest(sROIPPLoadCode);
        
        % need to convert to MATLABLabelMapRegionsOfInterest to allow for
        % interpolation onto MR image volume geometry
        oROIsForInterpolation = MATLABLabelMapRegionsOfInterest(oROIs.GetMasks(), oROIs.GetImageVolumeGeometry(), oROIs.GetRegionsOfInterestNames());
                
        sDicomRegFilePath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetT1PostContrastMRIToCTSimRegistrationDicomFilePath();
        m2dAffineTransformMatrix = RigidTransform.GetAffineTransformMatrixFromDicomRegFile(fullfile(oPatient.GetDicomDatabaseRootPath(), sDicomRegFilePath));
        
        if oPatient.GetFirstBrainRadiationCourseTreatmentPlan().IsMRT1wPostContrastRegistrationOntoMR()
            % do nothing
        else
            m2dAffineTransformMatrix = inv(m2dAffineTransformMatrix); % need to invert, need to register CT/RT struct onto MRI T1wCE
        end
                
        oROIsForInterpolation.PerformRigidTransform(m2dAffineTransformMatrix);        
        oROIsForInterpolation.InterpolateOntoTargetGeometry(oT1wCEMRI.GetImageVolumeGeometry(), 'interpolate3D', 'linear');
                
        oROIsForInterpolation.ForceApplyAllTransforms();
        
        sRTStructDicomFilePath = oPatient.GetFirstBrainRadiationCourseTreatmentPlan().GetRTStructDicomFilePath();
        sPatientDicomDatabaseFolder = strrep(oPatient.GetDicomDatabaseRootPath(), Experiment.GetDataPath('DicomImagingDatabase'), '');
        
        sROIPPPath = fullfile(sProcessedImageDatabaseRootPath, sPatientDicomDatabaseFolder, FileIOUtils.SeparateFilePathAndFilename(sRTStructDicomFilePath));
        
        FileIOUtils.MkdirIfItDoesNotExist(sROIPPPath);
        
        oROIsForInterpolation.Save(fullfile(sROIPPPath, sROIPPSaveCode + ".mat"), bForceApplyTransforms, bAppend, '-v7','-nocompression');
    catch e
        disp(['Patient ', num2str(vdPatientIds(dPatientIndex)), ' failed.']);
    end
end