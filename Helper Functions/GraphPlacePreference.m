function placePrefGraph = GraphPlacePreference(data,rightData,leftData, BadIdxs, p)
%GRAPHPLACEPREFERENCE Summary of this function goes here
%   Detailed explanation goes here
%TO DO: GRAPH BAD DAYS
    if strcmp(data.BBName,'AVG')
        str = 'Average Place Preference -- Binned into switch periods';
    else 
        str = sprintf('BB%g Place Preference -- Binned into switch periods',str2double(data.BBName));
    end
    placePrefGraph = figure('Name', str);
    dataSize = size(rightData);
    if ~strcmp(data.BBName,'AVG') %%average data is already cleaned
        rightData(BadIdxs,:) = 0;
        leftData(BadIdxs,:) = 0;
    end
    if strcmp(data.BBName,'AVG')
        n = dataSize(2);
    else
        n = dataSize(1);
    end
    time = linspace(1,n,n);
    xSpacer = 0.5:3:size(rightData);
    hold on
    title(str)
    xlabel('Day');
    ylabel('Water Consumption (mL)');
    plot(time, smooth(rightData), 'b-');
    plot(time, smooth(leftData), 'r-');
    plot(time, rightData, 'b*');
    plot(time, leftData, 'r*');
    for i = 1:size(BadIdxs,1)
    plot(BadIdxs(i),0,'black*'); 
    end
    legend('Position 1 Data', 'Position 2 Data','AutoUpdate','off');
    for i = 1:(size(xSpacer,2))
        xval = xSpacer(i);
        xline(xval);
    end
    if p <= 0.05
    text(.6 * max([rightData; leftData]), .6 * max([rightData; leftData]), ['* p = ' num2str(p)])
    else
    text(.6 * max([rightData; leftData]), .6 * max([rightData; leftData]), ['p = ' num2str(p)])
    end
    hold off
end

