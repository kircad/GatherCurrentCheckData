function [finalData] = rebin(labjackData, datesArray, totalBins)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%GOAL: PRODUCE A TABLE WITH 24 ROWS FOR EACH BBID, EACH ROW CONTAINING AVERAGE HOURLY
%CONSUMPTION ACROSS ALL DAYS IN LAST COL
fieldnames = fields(labjackData(1).binnedData);
fieldnames(end-2:end) = [];
fieldnames(1) = []; %just to get standard named fields
for j = 1:size(labjackData,2)
        BBIDdata = labjackData(j).binnedData;
        averageHolder = [];
    for i = 1:totalBins
        averages = [];
        %makes array of all dates with this hour
        datesNew = datesArray + hours(i - 1);
        %initializes hourlyVal as empty timetable
        hourlyVal = timetable(datesNew');
        for k = 1:size(fieldnames,1)
            label = char(fieldnames(k));
            hourlyVal.(label) = zeros(size(datesNew,2),1); 
        end
        %grabs ALL dates with data for this specific hour, replaces matching
        %rows with this data, leaving a complete timetable with 0s in missing time slots
        incompleteHourData = BBIDdata(ismember(BBIDdata.time, datesNew', 'rows'),:);
        hourlyVal(ismember(hourlyVal.Time, incompleteHourData.time),:) = cell2num(table2timetable(incompleteHourData));
        %last row of each column is averages by hour
        for k = 1:size(fieldnames,1)
            label = char(fieldnames(k));
            average = mean(hourlyVal.(label));
            averages = [averages; average]; %saved in order specified in finalData.fieldnames for each BBID
        end
        averageHolder = [averageHolder; averages'];
        fieldname = sprintf("Bin%d", i);
        hourlyData(i).data = hourlyVal;
        hourlyData(i).averages = averages;
    end
    if j == 1
        finalAverages = averageHolder;
    else
        finalAverages = (finalAverages + averageHolder);
    end
    fieldname = sprintf("BB%d", j);
    finalData.(fieldname) = hourlyData;
    %now make averages across BBIDs
end
    finalData.Average = (finalAverages / totalBins);
    finalData.fieldnames = fieldnames;
    finalData.totalBins = totalBins;
end

