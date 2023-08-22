function GSD = GatherCurrentCheckData(startDay, numDays)
%GATHERCURRENTCHECKDATA Pulls data from Google Sheet and places it into a
%struct for easier processing and storage
%   Deniz Kirca September 2021
dt.Format = 'dd-MMM-yyyy';
format short g;
%PREFERENCES 
checkPlacePref = true;
MakeGraphs = true;
analysis = true;
%VARIABLES
if ~exist('alphaLevel','var')
    alphaLevel = 0.05;
end
if ~exist('startDay','var')
    startDay = datetime(2022,05,10,0,00,0);
end
if ~exist('AnalysisOutputPath','var')
    AnalysisOutputPath = 'C:\Users\kirca\Desktop\MatLab';
end
if ~exist('numDays','var')
    numDays = 8;
end
if ~exist('BBIds','var')
	BBIds = {'01' '02'};
    numBoxes = size(BBIds, 2);
end
if ~exist('binningtime','var')
	binningtime = 'hourly';
end
ID = '1fI8s-WgoV8ambhGVDdn2efoQCPBoy7KuhRNn_qdgjwA';
%sheet_name = 'My Sheet';
%url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
%    ID, sheet_name);
%try
%   dispenserLUT = GetGoogleSpreadsheet('1kSJgVS7loS6y1TLcr0y7l9IybzDgWw24hRPaCn2RNBM');
%catch
%    warning('Could not load LUT from webpage')
%    load('/home/kirca/Desktop/testLUT.mat')
%end
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
for i = 1:size(timeIndicies,2)
        daySize = size(timeIndicies{1,i});
        %if daySize(1) ~= numBoxes
        %    error('BoxIDs do not match number of boxes for day %f', i);
        %end
        %NOTE: need 'str2num' if using google sheet! FIX
        if usingDownloadedData
            BBIDIndex = find((cell2mat(sheet_data(timeIndicies{1,i},2))) == str2double(BBIds(j)));
        else
            BBIDIndex = find((str2num(cell2mat(sheet_data(timeIndicies{1,i},2)))) == str2double(BBIds(j)));
        end
        tempData = sheet_data((timeIndicies{1,i}(BBIDIndex)),:);
        if isempty(tempData)
            %implement system that indexes missed days/BBIDs
            fieldName = sprintf('b%g',j);
            null = str2cell('N');
            boxWeight(i) = 999;
            boxWater1(i) = 999;
            boxWater2(i) = 999;
            boxDate(i) = null;
            missedEntries = missedEntries + 1;
        else
        weight = tempData(12);
        water1 = tempData(4);
        water2 = tempData(5);
        date = tempData(1);
        end
        boxID = (str2double(cell2mat(tempData(2))));
        fieldName = sprintf('b%g',boxID);
        %NOTE: NEEDS str2double if using google sheet data! FIX
        if usingDownloadedData
        boxWeight(i) = cell2mat(weight);
        boxWater1(i) = (100 - cell2mat(water1));
        boxWater2(i) = (100 - cell2mat(water2));
        else
        boxWeight(i) = str2double(cell2mat(weight));   
        boxWater1(i) = (100 - str2double(cell2mat(water1)));
        boxWater2(i) = (100 - str2double(cell2mat(water2)));
        boxDate(i) = date;
        end
end
        totalWater1(j,:) = boxWater1;
        totalWater2(j,:) = boxWater2;
        totalWeights(j,:) = boxWeight;
        dataTable(:,1) = boxWater1;
        dataTable(:,2) = boxWater2;
        dataTable(:,3) = boxWeight;
        GSD(j).BBName = cell2mat(BBIds(j));
        GSD(j).weight = boxWeight;
        GSD(j).dates = boxDate;
        GSD(j).BinnedDataNoLabels = dataTable;
        clear dataTable binnedDataNoLabels boxWeight boxregH20 boxsucH20 date;
end
    %TO DO: add way to sort by groups -- last row is AVERAGES
    dataTable(:,1) = mean(totalWater1,1);
    dataTable(:,2) = mean(totalWater2,1);
    dataTable(:,3) = mean(totalWeights,1);
    GSD(j+1).BinnedDataNoLabels = dataTable;
    GSD(j+1).BBName = 'AVG';
    sprintf('Operation Completed! Missed Entries: %f \nData saved to %s', missedEntries, AnalysisOutputPath)
    [BadIdxs, GSDclean] = RemoveBadDays(GSD, 100);
if analysis
    sprintf('Now analyzing data -- RankSum')
    for i = 1:size(GSD,2)
        water1DataClean = GSD(i).BinnedDataNoLabels(:,1);
        water2DataClean = GSD(i).BinnedDataNoLabels(:,2);
        water1DataClean(BadIdxs,:) = [];
        water2DataClean(BadIdxs,:) = [];
        p = ranksum(water1DataClean,water2DataClean);
        statData(i).BBName = GSD(i).BBName;
        statData(i).sucAvg = mean(water1DataClean);
        statData(i).regAvg = mean(water2DataClean);
        statData(i).SucPrefpvalue = p;
        if i == size(GSD,2)
            sprintf('BBID : Average')
        else
            sprintf('BBID : %d',i)
        end
        sprintf('Regular Average Consumption: %g ml \n  Sucrose Average Consumption: %g ml',statData(i).regAvg, statData(i).sucAvg)
        if p <= alphaLevel
            sprintf('Comparison is SIGNIFICANT. p = %f\n', p)
        else 
            sprintf('Comparison is NOT SIGNIFICANT. p = %f\n', p)
        end
        if MakeGraphs
            sucPrefGraph = GraphSucrosePreference(GSD, BadIdxs, p, i);
            figSavePath = fullfile(AnalysisOutputPath, 'figures');
            savefigsasindir(figSavePath,sucPrefGraph,'fig');
            savefigsasindir(figSavePath,sucPrefGraph,'png');
        end
        dataPath = fullfile(AnalysisOutputPath, 'statData.mat');
    end
end
save(dataPath, 'statData');
end