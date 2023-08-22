function [GSD, BadIdxs, WaterBadIdxs] = GatherCurrentCheckData(startDay, numDays)
%GATHERCURRENTCHECKDATA Pulls data from Google Sheet and places it into a
%struct for easier processing and storage
%   Deniz Kirca September 2021

%%line graph of before vs after ketamine during cort -- ignore baseline %%
dt.Format = 'dd-MMM-yyyy';
format short g;
%PREFERENCES 
checkPlacePref = false;
MakeGraphs = true;
analysis = true;
usingPresetBadIdxs = true;
%VARIABLES
if ~exist('alphaLevel','var')
    alphaLevel = 0.05;
end
if ~exist('startDay','var')
    startDay = datetime(2022,06,10,0,00,0);
end
if ~exist('AnalysisOutputPath','var')
    AnalysisOutputPath = 'C:\Users\kirca\Desktop\MatLab';
end
if ~exist('numDays','var')
    numDays = 28;
%59
%precort: 30 (29 excluding frist day)
%postcort: 29
%cort on june 10, ketamine on june 24
%%line graph of before vs after cort -- from june 10 to june 24 %% start
%%date is May 12
end
if ~exist('BBIds','var')
    BBIds = {'04','05','08','14'};
	%All = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13' '14' '15' '16'};
    %%A = {'01','02','03','06','07','09','10','15'}; no cort
    %%B = {'04','05','08','11','12','13','14','16'}; cort
    %%X = {'06','07','09','11','12','13','15','16'}; saline
    %%Z = {'01','02','03','04','05','08','10','14'}; ketamine
    %%AX = {'06','07','09','15'};
    %%AZ = {'01','02','03','10'};
    %%BX = {'11','12','13','16'};
    %%BZ = {'04','05','08','14'};
    temp = size(BBIds);
    numBoxes = temp(2);
end
if ~exist('binningtime','var')
	binningtime = 'hourly';
end
if ~exist('WaterBadIdxs','var')
    WaterBadIdxs = [6,10,14]; %%ADJUST FOR NEW BIN PERIOD -- subtract 30 for new calc (14 days)
    %WaterBadIdxs = [6,10,14]; %%ADJUST FOR NEW BIN PERIOD -- subtract 30 for new calc (14 days)
	%WaterBadIdxs = [7,20,36,40,54]; %%ADJUST FOR NEW BIN PERIOD
    %[8,21,37,41,55]
end
if ~exist('BadIdxs','var')
    BadIdxs = [5, 6, 10, 14, 21, 24];
	%BadIdxs = [7, 20, 35, 36, 40, 44, 51, 54];
%BadIdxs = [8, 21, 36, 37, 41, 45, 52, 55];
end
ID = '1ZcAycD_tzYTNN4xpyttKNKAJNyeDC0bLP0VAGc9Ox8E';
%sheet_name = 'My Sheet';
%url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
%    ID, sheet_name);
try
    dispenserLUT = GetGoogleSpreadsheet('1kSJgVS7loS6y1TLcr0y7l9IybzDgWw24hRPaCn2RNBM');
catch
    warning('Could not load LUT from webpage')
    load('/home/kirca/Desktop/testLUT.mat')
end
try 
    sheet_data = GetGoogleSpreadsheet(ID);
    sheet_data(1,:) = [];
    timestamps = sheet_data(:,1);
    usingDownloadedData = false;
catch
    warning('Could not load sheet data from webpage')
    load('/home/kirca/Desktop/sheet_data.mat');
    sheet_data(1,:) = [];
    timestamps = cellstr(sheet_data(:,1));
    usingDownloadedData = true;
end
currDay = startDay;
timestamps = datetime(timestamps);
%timestamps = timestamps(2:size(timestamps),1);
indexData.Times = timestamps;
indexData.BBIDs =  str2double(sheet_data(:,7));
%for i - 1:numDays
dayCounter = 1;
while numDays >= dayCounter
    timeIndicies{dayCounter} = find(isbetween(indexData.Times,currDay,(currDay + hours(23) + minutes(59))));
   % indexTable(dayCounter,:) = index;
    currDay = currDay + caldays(1);
    dayCounter = dayCounter + 1;
end
missedEntries = 0;
for j = 1:numBoxes
    %disp(j)
for i = 1:size(timeIndicies,2)
    %disp(i)
        daySize = size(timeIndicies{1,i});
        %if daySize(1) ~= numBoxes
        %    error('BoxIDs do not match number of boxes for day %f', i);
        %end
        %NOTE: need 'str2num' if using google sheet! FIX
        if usingDownloadedData
            BBIDIndex = find((cell2mat(sheet_data(timeIndicies{1,i},2))) == str2double(BBIds(j)));
        else
            BBIDIndex = find((str2num(cell2mat(sheet_data(timeIndicies{1,i},2)))) == str2double(BBIds(j))); %%COMMON ERROR: CELL2MAT -- MAKE SURE ALL BBIDS ARE TWO DIGITS LONG (EX. '01' NOT '1')
        end
        tempData = sheet_data((timeIndicies{1,i}(BBIDIndex)),:);
        if isempty(tempData)
            %implement system that indexes missed days/BBIDs
            fieldName = sprintf('b%g',j);
            null = str2cell('N');
            boxWeight(i) = 999;
            boxRegH20(i) = 999;
            boxSucH20(i) = 999;
            boxDate(i) = null;
            sucPos = null;
            regPos = null;
            switchBool = null;
            missedEntries = missedEntries + 1;
            boxID = j;
            BadIdxs = [BadIdxs, i];
        else
        weight = tempData(14);
        regH20 = tempData(4);
        sucH20 = tempData(5);
        sucPos = tempData(21);
        regPos = tempData(22);
        date = tempData(1);
        comments = tempData(20);
        switchBool = tempData(13);
        boxID = (str2double(cell2mat(tempData(2))));
        fieldName = sprintf('b%g',boxID);
        %NOTE: NEEDS str2double if using google sheet data! FIX
        if usingDownloadedData
        boxWeight(i) = cell2mat(weight);
        boxRegH20(i) = (10 - cell2mat(regH20));
        boxSucH20(i) = (10 - cell2mat(sucH20));
        else
        boxComments(i) = comments;
        boxWeight(i) = str2double(cell2mat(weight));   
        boxRegH20(i) = (10 - str2double(cell2mat(regH20)));
        boxSucH20(i) = (10 - str2double(cell2mat(sucH20)));
        boxSucPos(i) = sucPos;
        boxRegPos(i) = regPos;
        boxSwitchBool(i) = switchBool;
        boxDate(i) = date;
        end
        end
end
        totalRegH20(j,:) = boxRegH20;
        totalSucH20(j,:) = boxSucH20;
        totalWeights(j,:) = boxWeight;
        dataTable(:,1) = boxSucH20;
        dataTable(:,2) = boxRegH20;
        PositionTable(:,1) = boxSucPos;
        PositionTable(:,2) = boxRegPos;
        PositionTable(:,3) = boxSwitchBool;
        GSD(j).BBName = cell2mat(BBIds(j));
        GSD(j).weight = boxWeight;
        GSD(j).dates = boxDate;
        GSD(j).comments = boxComments;
        GSD(j).BinnedDataNoLabels = dataTable;
        GSD(j).positions = PositionTable;
        clear dataTable binnedDataNoLabels boxWeight boxregH20 box sucH20 date;
end
    %TO DO: add way to sort by groups -- last row is AVERAGES
    dataTable(:,1) = mean(totalSucH20,1);
    dataTable(:,2) = mean(totalRegH20,1);
    GSD(j+1).BinnedDataNoLabels = dataTable;
    GSD(j+1).weight = mean(totalWeights,1);
    GSD(j+1).dates = GSD(j).dates;
    GSD(j+1).BBName = 'AVG';
    sprintf('Operation Completed! Missed Entries: %f \nData saved to %s', missedEntries, AnalysisOutputPath)
    GSD = RemoveBadDays(GSD, 10, BadIdxs, WaterBadIdxs, usingPresetBadIdxs);
    %GSD = GSDclean; %probably a better way to do this lol-- figure out how to pass GSD by reference into the function above. Thanks a lot MATLAB memory allocation!
if checkPlacePref
    sprintf('Now analyzing for presence of place preference in water data')
    %Sterilization Protocol -- First indexes bad days, then removes
    %them across ALL boxes since you can't compare them;
    totalPos1 = [];
    totalPos2 = [];
    for i = 1:(size(GSD,2))
        if (i == size(GSD,2))
           pos1AvgInt = mean(totalPos1);
           pos2AvgInt = mean(totalPos2);
           if analysis
                sprintf('AVG Place Pref Analyais')
                statData(i).pos1Avg = pos1AvgInt;
                statData(i).pos2Avg = pos2AvgInt;
                p = ranksum(totalPos1, totalPos2);
                sprintf('Position 1 Average Consumption: %g ml \n  Position 2 Average Consumption: %g ml', pos1AvgInt,pos2AvgInt)
                if p <= alphaLevel
                    sprintf('Comparison is SIGNIFICANT. p = %f\n', p)
                else
                    sprintf('Comparison is NOT SIGNIFICANT. p = %f\n', p)
                end
                statData(i).PlacePrefpvalue = p;
            end
            statData(i).pos1Avg = (pos1AvgInt);
            statData(i).pos2Avg = (pos2AvgInt);
            statData(i).pos1Total =  mean(pos1All,1);
            statData(i).pos2Total =  mean(pos2All,1);
            statData(i).BBName = 'AVG';
            if MakeGraphs
                placePrefGraph = GraphPlacePreference(statData(i), statData(i).pos1Total, statData(i).pos2Total, WaterBadIdxs, p);
                sucFigSavePath = fullfile(AnalysisOutputPath, 'figures');
                savefigsasindir(sucFigSavePath,placePrefGraph,'fig');
                savefigsasindir(sucFigSavePath,placePrefGraph,'png');
            end
        else
            [pos1DataClean, pos2DataClean, p] = CheckPlacePreference(GSD(i), binningtime, AnalysisOutputPath, WaterBadIdxs, 2, dispenserLUT, MakeGraphs);
            statData(i).BBName = GSD(i).BBName;
            statData(i).pos1Avg = mean(pos1DataClean);
            statData(i).pos2Avg = mean(pos2DataClean);
            statData(i).pos1Total = pos1DataClean;
            statData(i).pos2Total = pos2DataClean;
            pos1All(i,:) = pos1DataClean;
            pos2All(i,:) = pos2DataClean;
            totalPos1 = [totalPos1; mean(pos1DataClean)];
            totalPos2 = [totalPos2; mean(pos2DataClean)];
        end
        statData(i).PlacePrefpvalue = p;
        dataPath = fullfile(AnalysisOutputPath, 'statData.mat');
        save(dataPath, 'statData');
    end
end
if analysis %07/15 -- analysis/checkplacepref/graphing is kinda fucked because of changes to GSD structure. Will be better in the long run though
    %Modify so it reflects that all data in GSD is now clean-- should be a
    %lot simpler
    sprintf('Now analyzing data -- RankSum')
    for i = 1:size(GSD,2)
        sucDataClean = GSD(i).BinnedDataNoLabelsClean(:,1);
        regDataClean = GSD(i).BinnedDataNoLabelsClean(:,2);
        %%sucDataClean(BadIdxs,:) = []; redundant now?
        %%regDataClean(BadIdxs,:) = [];
        p = ranksum(sucDataClean,regDataClean);
        statData(i).BBName = GSD(i).BBName;
        statData(i).sucAvg = mean(sucDataClean);
        statData(i).regAvg = mean(regDataClean);
        statData(i).SucPrefpvalue = p;
        if i == size(GSD,2)
            sprintf('BBID : Average')
        else
            sprintf('BBID : %d',str2num(statData(i).BBName))
        end
        sprintf('Regular Average Consumption: %g ml \n  Sucrose Average Consumption: %g ml',statData(i).regAvg, statData(i).sucAvg)
        if p <= alphaLevel
            sprintf('Comparison is SIGNIFICANT. p = %f\n', p)
        else 
            sprintf('Comparison is NOT SIGNIFICANT. p = %f\n', p)
        end
        if MakeGraphs
            %try LOL
            sucPrefGraph = GraphSucrosePreference(GSD, BBIds, numDays, BadIdxs, WaterBadIdxs, p, i);
            weightGraph = GraphWeights(GSD, BBIds, numDays, BadIdxs, i);
            %catch
            %    [y, fs] = audioread('boxvislib.wav');
            %    sound(y, fs); 
            %end
            sucFigSavePath = fullfile(AnalysisOutputPath, 'Sucrose Preference Figures');
            weightFigSavePath = fullfile(AnalysisOutputPath, 'Weight Figures');
            savefigsasindir(sucFigSavePath,sucPrefGraph,'fig');
            savefigsasindir(sucFigSavePath,sucPrefGraph,'png');
            savefigsasindir(weightFigSavePath,weightGraph,'fig');
            savefigsasindir(weightFigSavePath,weightGraph,'png');
        end
        dataPath = fullfile(AnalysisOutputPath, 'statData.mat');
    end
    save(dataPath, 'statData');
end
end

%%TO DO: add system that removes specifically water bad idxs in addition to
%%regular badidxs but DOES NOT remove stuff from main data struct-- the
%%only data removed from this struct should be idxs with no corresponding
%%data at all. Make sure checkplacepreference, graphsucrosepreference, and
%%graphplace preference all reflect this and TEST RIGOROUSLY!!!!!!!!!!!!!
%%Check to make sure averages reflect this too