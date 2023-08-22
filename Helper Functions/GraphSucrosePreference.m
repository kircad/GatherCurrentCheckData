function sucrosePrefGraph = GraphSucrosePreference(GSD, BBIds, numDays, BadIdxs, WaterBadIdxs, p, i)
%GRAPHSUCROSEPREFERENCE Summary of this function goes here
%   Detailed explanation goes here
    sucroseData = GSD(i).BinnedDataNoLabels(:,1);
    regularData = GSD(i).BinnedDataNoLabels(:,2);
    str = sprintf('BB%g Sucrose Preference -- Binned into switch periods',str2double(GSD(i).BBName));
    time = linspace(1,numDays,numDays);
    if i == size(GSD,2)
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
    regularData(totalBadIdxs,:) = NaN;
    errSuc(totalBadIdxs) = 0;
    errReg(totalBadIdxs) = 0;
    xSpacer = 0.5:3:size(sucroseData);
    hold on
    title(str)
    xlabel('Day');
    ylabel('Water Consumption (mL)');
    plot(time, smooth(sucroseData), 'b-');
    plot(time, smooth(regularData), 'r-');
    errorbar(time, sucroseData, errSuc, 'b.');
    errorbar(time, regularData, errReg, 'r.');
    for i = 1:size(totalBadIdxs,2)
        plot(totalBadIdxs(i),0,'green*'); 
    end
    legend('Sucrose Data', 'Regular Data','AutoUpdate','off');
    for i = 1:(size(xSpacer,2))
        xval = xSpacer(i);
        xline(xval);
    end
    if p <= 0.05
    text(.6 * max([sucroseData; regularData]), .6 * max([sucroseData; regularData]), ['* p = ' num2str(p)])
    else
    text(.6 * max([sucroseData; regularData]), .6 * max([sucroseData; regularData]), ['p = ' num2str(p)])
    end
    xlim([0 numDays])
    ylim([0 10])
    hold off
end

