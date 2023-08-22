function weightGraph = GraphWeights(GSD, BBIds, numDays, BadIdxs, i)
    ymin = 15;
    ymax = 36;
    weightData = GSD(i).weight;
    str = sprintf('BB%g Daily Weights',str2double(GSD(i).BBName));
    time = linspace(1,numDays,numDays);
    if i == size(GSD,2)
        str = 'Average Daily Weights-- CorticosteronexKetamine';
        for i = 1:size(BBIds,2)
            fullWeightData(:, i) = GSD(i).weight;
        end
        for j = 1:size(fullWeightData,1)
            err(j) = std(fullWeightData(j,:));
        end
    else
        err = (zeros(size(time,2,1)) + 0.2)';
    end
    weightGraph = figure('Name', str);
    weightData(BadIdxs) = NaN;
    err(BadIdxs) = 0;
    xSpacer = 0.5:3:size(weightData);
    hold on
    title(str)
    xlabel('Day');
    ylabel('Weight (g)');
    plot(time, smooth(weightData), 'r-');
    errorbar(time, weightData, err, 'r.');
    for i = 1:size(BadIdxs,2)
        plot(BadIdxs(i),ymin,'green*'); 
    end
    legend('Weight (g)','AutoUpdate','off');
    for i = 1:(size(xSpacer,2))
        xval = xSpacer(i);
        xline(xval);
    end
    xline(14, '-', {'Ketamine', 'Injection'});
    %if p <= 0.05
    %text(.6 * max([weightData]), .6 * max([weightData]), ['* p = ' num2str(p)])
    %else
    %text(.6 * max([weightData; weightData]), .6 * max([weightData; weightData]), ['p = ' num2str(p)])
    %end
    xlim([0 numDays])
    ylim([ymin ymax])
    hold off
end

