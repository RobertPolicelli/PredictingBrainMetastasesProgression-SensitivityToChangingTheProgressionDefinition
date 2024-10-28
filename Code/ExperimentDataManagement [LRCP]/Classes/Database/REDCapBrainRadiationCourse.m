classdef REDCapBrainRadiationCourse
    %REDCapBrainRadiationCourse
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dtDate (1,1) datetime
        
        eIntent (1,1) REDCapRadiationCourseIntent
        
        voBeamSets (:,1) REDCapBeamSet = REDCapBeamSet.empty(0,1)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = REDCapBrainRadiationCourse(dtDate, eIntent, voBeamSets)
            %obj = REDCapBrainRadiationCourse(dtDate, eIntent, voBeamSets)
            
            obj.dtDate = dtDate;
            obj.eIntent = eIntent;
            obj.voBeamSets = voBeamSets;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDate = GetDate(obj)
            dtDate = obj.dtDate;
        end
    end
    
    
    methods (Access = public, Static)
        
        function obj = CreateFromREDCapExport(c1xREDCapExportDataForCourse, vsREDCapExportHeaders)
            dtDate = c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_date"};
            eIntent = REDCapRadiationCourseIntent.GetEnumFromREDCapCode(c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_intent"});
            
            dNumberOfBeamSets = c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_number_of_beam_sets"};
            
            c1oBeamSets = cell(dNumberOfBeamSets,1);
            
            for dBeamSetIndex=1:dNumberOfBeamSets
                dFractions = c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_fractions_prescribed"};
                
                if ismissing(c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_prescribed_dose_gy"}) % get the calculated dose instead
                    dDose_Gy = c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_calculated_dose_gy"};
                    
                    c1oBeamSets{dBeamSetIndex} = REDCapGeneralBrainRadiationCourseBeamSet(dDose_Gy, dFractions);
                else
                    dDose_Gy = c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_prescribed_dose_gy"};
                    
                    vdBMNumbers = str2double(strsplit(c1xREDCapExportDataForCourse{vsREDCapExportHeaders == "brain_rt_course_beamset" + string(dBeamSetIndex) + "_targeted_bms"}, "BM"));
                    vdBMNumbers = vdBMNumbers(~isnan(vdBMNumbers));
                    
                    c1oBeamSets{dBeamSetIndex} = REDCapFirstBrainRadiationCourseBeamSet(dDose_Gy, dFractions, vdBMNumbers);
                end
            end
            
            voBeamSets = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBeamSets);
            
            obj = REDCapBrainRadiationCourse(dtDate, eIntent, voBeamSets);
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

