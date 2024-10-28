classdef RadiationCourse
    %RadiationCourse
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dtRadiationCourseDate (1,1) datetime
        eIntent (1,1) RadiationCourseIntent
        
        voRadiationCoursePortions (1,:) RadiationCoursePortion
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RadiationCourse(dtRadiationCourseDate, eIntent, voRadiationCoursePortions)
            %obj = RadiationCourse(dtRadiationCourseDate, eIntent, voRadiationCoursePortions)
            
            if dtRadiationCourseDate < datetime(2000,1,1) || dtRadiationCourseDate > datetime(2020,11,1)
                error(...
                    'RadiationCourse:Constructor:InvalidRadiationCourseDate',...
                    'Invalid radiation course date.');
            end
            
            obj.dtRadiationCourseDate = dtRadiationCourseDate;
            obj.eIntent = eIntent;
            obj.voRadiationCoursePortions = voRadiationCoursePortions;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtRadiationCourseDate = GetRadiationCourseDate(obj)
            dtRadiationCourseDate = obj.dtRadiationCourseDate;
        end
        
        function eIntent = GetIntent(obj)
            eIntent = obj.eIntent;
        end
        
        function voPortions = GetRadiationCoursePortions(obj)
            voPortions = obj.voRadiationCoursePortions;
        end
        
        function dNumPortions = GetNumberOfRadiationCoursePortions(obj)
            dNumPortions = length(obj.voRadiationCoursePortions);
        end
        
        function vdNumberOfPrescribedFxPerPortion = GetNumberOfFractionsPrescribedPerRadiationCoursePortion(obj)
            dNumPortions = length(obj.voRadiationCoursePortions);
            
            vdNumberOfPrescribedFxPerPortion = zeros(1,dNumPortions);
            
            for dPortionIndex=1:dNumPortions
                vdNumberOfPrescribedFxPerPortion(dPortionIndex) = obj.voRadiationCoursePortions(dPortionIndex).GetNumberOfFractionsPrescribed();
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function voCombinedCourses = CombinePortionsOnSameDateIntoSingleCourse(voCourses)
            arguments
                voCourses (1,:) RadiationCourse
            end
            
            if isempty(voCourses)
                voCombinedCourses = voCourses;
            else
                c1oCombinedCourses = {};
                dInsertIndex = 1;
                
                while ~isempty(voCourses)
                    dtSearchDate = voCourses(1).dtRadiationCourseDate;
                    eSearchIntent = voCourses(1).eIntent;
                    
                    voPortions = voCourses(1).voRadiationCoursePortions;
                    
                    vbRemoveCourse = false(1,length(voCourses));
                    vbRemoveCourse(1) = true;
                    
                    for dSearchIndex=2:length(voCourses)
                        if voCourses(dSearchIndex).dtRadiationCourseDate == dtSearchDate && voCourses(dSearchIndex).eIntent == eSearchIntent
                            vbRemoveCourse(dSearchIndex) = true;
                            
                            voPortions = [voPortions, voCourses(dSearchIndex).voRadiationCoursePortions];
                        end
                    end
                    
                    voCourses(1).voRadiationCoursePortions = voPortions;
                    c1oCombinedCourses{dInsertIndex} = voCourses(1);
                    dInsertIndex = dInsertIndex + 1;
                    
                    voCourses = voCourses(~vbRemoveCourse);
                end
                
                voCombinedCourses = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oCombinedCourses);
            end
        end
        
        function voCourses = SortCoursesByDate(voCourses)
            dNumCourses = length(voCourses);
            
            vdtCourseDates = NaT(1, dNumCourses);
            
            for dCourseIndex=1:dNumCourses
                vdtCourseDates(dCourseIndex) = voCourses(dCourseIndex).GetRadiationCourseDate();
            end
            
            [~, vdSortIndices] = sort(vdtCourseDates, 'ascend');
            
            voCourses = voCourses(vdSortIndices);
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

