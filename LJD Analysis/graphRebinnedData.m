function graphfighandle = graphRebinnedData(rebinnedData)
%GRAPHREBINNEDDATA Summary of this function goes here
%   Makes a plot of the average beambreak/dispense values in each bin
%   period, (ex. hour 0 of ALL days, hour 2 of ALL days... hour 23 of ALL
%   days) and includes error bars
  time = 1:rebinnedData.totalBins;
  BBList = fields(rebinnedData);
  BBList(end-1:end) = [];
  fieldList = rebinnedData.fieldnames;
  %separate graph for dispenses -- for now only do beambreaks
  colorArray = ['r','b','g','c'];  % regular = red, food = blue, 
  %styleArray = ['.','--']; regular = dotted, treatment (sucrose/fatty) = dotted 
  for i = 1:size(BBList,1) %to do : name these figs according to BBID, datatype, etc. Graph everything on one graph w/different colors and legend by default 
       if (i == size(BBList,1))
           label = 'Average';
       else
           label = sprintf('BB%i',i);
       end
       figName = sprintf('%s Experimental 24-Hour Activity Plot', label);
       BBIDdata = rebinnedData.(label);
       figure('Name', figName);
       hold on 
       currMax = -1;
       for j = 1:size(fieldList, 1) - 5 %figure out better way using ismember?
           label = char(fieldList(j));
           data = [];
           errArray = [];
           if (i == size(BBList,1))
               data = BBIDdata(:,j);
               %err = std(BBIDdata(:,j)); %fix later-- this is probably wrong
               currMax = max(data);
           else
               for k = 1:size(time,2)
                    dataPoint = BBIDdata(k).averages(j);
                    err = std(BBIDdata(k).data.(label));
                    data = [data; dataPoint];
                    if max(data) > currMax; currMax = max(data); end
                    errArray = [errArray; err];
               end  
           end
           %if (j <= 2); col = 'r'; else col = 'b'; end
           %if (mod(j,2) == 0); style ='-'; else style = '--'; end
           %graphspecs = [col, style];
           plot(time, data, colorArray(j));
           %errorbar(time, data, errArray, colorArray(j)); %put back in
           %later
       end
       xlim([0 size(time,2)])
       ylim([0 currMax])
       legend('Regular Water Beambreaks', 'Sucrose Water Beambreaks','Regular Food Beambreaks','Fatty Food Beambreaks','AutoUpdate','off');
       xlabel('Hour');
       ylabel('Number of Beambreaks');
       title(figName);
       hold off
  end
end

% %SAVE GRAPHS WITHIN FUNCTION W/ PHO CODE
% end

