function RankSum(LJD,controlBBIds,experimentalBBIds,alphaLevel)
%RANKSUM Pulls BB data from RankSumPrep and runs ranksum test on every
%variable. Receives controlBBIds/experimentalBBIds as vectors, and
%alphaLevel as double
%Deniz Kirca + David Kim July 2021
%Default variables
testing = false; 
%%if testing
%%   LJD = '/analysis/DenizDavidTis/DenizDavidTestOutputs/Codeshare/LabJackData.estOutputs/Codeshare/LabJackData.mat'; 
%%end
if ~exist('controlBBIds','var')
	controlBBIds = [03];
    %MUST BE IN ORDER (fix later)
end
if ~exist('experimentalBBIds','var')
	experimentalBBIds = [04];
    %MUST BE IN ORDER (fix later)
end
if ~exist('alphaLevel','var')
	alphaLevel = 0.05;
end
%Calls RankSumPrep to create data tables + prepares for nested loops 
%if testing 
%    load('/home/kirca/FakeData/test2.mat'); 
%else
%    RatesTable = RankSumPrep(LJD,0)
%end 
%tableSize = size(RatesTable{1,1});
%numVariables = tableSize(2);

%concatenates vectors containing data into one list for each variable examined
temp = LJD.BinnedDataNoLabels;
numVariables = size(temp, 2);
varList = fieldnames(LJD(1).BinnedData);
for i = 1:numVariables
    controlData = [];
    experimentalData = [];
    controlCounter = 1;
    experimentalCounter = 1;
    for j = 1:size(LJD,2)
        startControlCounter = controlCounter;
        startExperimentalCounter = experimentalCounter;
        if ~(controlCounter > length(controlBBIds))
        if ismember(LJD(j).BBName(2),int2str((controlBBIds(controlCounter))))
        controlData = [controlData; LJD(j).BinnedDataNoLabels(:,i)];
        controlCounter = controlCounter + 1;
        end
        end
        if ~(experimentalCounter > length(experimentalBBIds))
        if ismember(LJD(j).BBName(2),int2str((experimentalBBIds(experimentalCounter))))
        experimentalData = [experimentalData; LJD(j).BinnedDataNoLabels(:,i)];
        experimentalCounter = experimentalCounter + 1;
        end
        end
        if ((controlCounter > startControlCounter) && (experimentalCounter > startExperimentalCounter))
            error('Control and Experimental BBIDs overlap!')
        end
    end

%run ranksum test using concatenated lists
    p = ranksum(controlData,experimentalData);
    variableName = char(varList(i));
    %% GRAPHING -- try to combine w/ GatherCurrentLabjackData??
    MakeGraphs(controlData, experimentalData,variableName,p,i);    
    sprintf('EIO%d: %s\n', (i - 1),variableName)
    controlSize = size(controlData);
    experimentalSize = size(experimentalData);
    if testing
    sprintf('controlSize: %f ', controlSize(1))
    sprintf('experimentalSize: %f ', experimentalSize(1))
    end
    if p <= alphaLevel
        sprintf('Comparison is SIGNIFICANT. p = %f\n', p)
    else 
        sprintf('Comparison is NOT SIGNIFICANT. p = %f\n', p)
    end
end

end