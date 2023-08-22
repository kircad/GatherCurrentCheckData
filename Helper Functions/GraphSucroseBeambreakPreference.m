function [sucrosePrefGraph, weightPrefGraph] = GraphSucroseBeambreakPreference(GSD, labjackData, BBIds, numDays, BadIdxs, WaterBadIdxs, index)
%GRAPHSUCROSEPREFERENCE Summary of this function goes here
%   Detailed explanation goes here
    sucroseData = GSD(index).BinnedDataNoLabels(:,1);
    regularData = GSD(index).BinnedDataNoLabels(:,2);
    str = sprintf('BB%g Sucrose Preference Beambreaks vs. Water Levels -- Binned into switch periods',str2double(GSD(index).BBName));
    time = linspace(1,numDays,numDays);
    if index == size(GSD,2)
        str = 'Average Sucrose Preference -- Binned into switch periods';
        for i = 1:size(BBIds,2)
            fullSucData(:, i) = GSD(i).BinnedDataNoLabels(:,1);
            fullRegData(:, i) = GSD(i).BinnedDataNoLabels(:,2);
        end
        for j = 1:size(fullSucData,1)
            errSuc(j) = std(fullSucData(j,:));
            errReg(j) = std(fullRegData(j,:));
        end
    else
        errSuc = (zeros(size(time,2,1)) + 0.2)';
        errReg = (zeros(size(time,2,1)) + 0.2)';
    end
    sucrosePrefGraph = figure('Name', str);
    totalBadIdxs = unique(sort([BadIdxs, WaterBadIdxs]));
    sucroseData(totalBadIdxs,:) = NaN;
    regularData(totalBadIdxs,:) = NaN; %count bad days in error calc?
    errSuc(totalBadIdxs) = 0;
    errReg(totalBadIdxs) = 0;
    xSpacer = 0.5:3:size(sucroseData);
    hold on 
    title(str)
    xlabel('Day');
    ylabel('Water Consumption (mL)');
    plot(time, smooth(sucroseData), 'b');
    plot(time, smooth(regularData), 'r');
    %errorbar(time, sucroseData, errSuc, 'b:');
    %errorbar(time, regularData, errReg, 'r:'); %%AVERAGE-- WHY IS THERE NEGATIVE VALS???? REDO IDX STUFF
    for o = 1:size(totalBadIdxs,2)
        plot(totalBadIdxs(o),0,'green*'); 
    end
    legend('Sucrose Data', 'Regular Data','AutoUpdate','off');
    for o = 1:(size(xSpacer,2)) 
        xval = xSpacer(o);
        xline(xval, 'k--');
    end
    xlim([0 numDays])
    ylim([0 10])
    yyaxis right
    ylabel('Water Beambreaks');
    ylim([0 200]); %ylim should be same for all
    regData = str2double(labjackData(index).binnedData.Regular_Water_Beambreak);
    sucData = str2double(labjackData(index).binnedData.Sucrose_Water_Beambreak);
    sucData(totalBadIdxs,:) = NaN;
    regData(totalBadIdxs,:) = NaN;
    plot(time, smooth(sucData), 'b.');
    plot(time, smooth(regData), 'r.');
    hold off
    str = sprintf('BB%g Sucrose Preference Beambreaks vs. Weight -- Binned into switch periods',str2double(GSD(index).BBName));
    weightData = GSD(index).weight;
    err = (zeros(size(time,2,1)) + 0.2)';
    weightData(BadIdxs) = NaN;
    err(BadIdxs) = 0;
    weightPrefGraph = figure('Name', str);
    hold on 
    title(str)
    xlabel('Day');
    ylabel('Weight (g)');
    plot(time, smooth(weightData), 'k-');
    errorbar(time, weightData, err, 'k.');
    for i = 1:size(BadIdxs,2)
        plot(BadIdxs(i),10,'green*'); 
    end
    for i = 1:(size(xSpacer,2))
        xval = xSpacer(i);
        xline(xval);
    end
    xlim([0 numDays])
    ylim([15 36])
    yyaxis right
    ylabel('Water Beambreaks');
    ylim([0 200]); %ylim should be same for all
    regData = str2double(labjackData(index).binnedData.Regular_Water_Beambreak);
    sucData = str2double(labjackData(index).binnedData.Sucrose_Water_Beambreak);
    sucData(totalBadIdxs,:) = NaN;
    regData(totalBadIdxs,:) = NaN;
    plot(time, smooth(sucData), 'b-');
    plot(time, smooth(regData), 'r-');
end

