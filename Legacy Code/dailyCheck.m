%Function that gives easy ability to quickly visaulize behavioral box data
%Deniz Kirca June 2021
function dailyCheck(LJD, clean)
%if ~exist('bbIDs','var')
%    bbIDs = {'01', '02','03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16'};
%end
%if ~exist('datapath','var')
%    datapath = '/home/kirca/FakeData/BB'; %%testing purposes only
%end
%if ~exist('LJD','var')
%    LJD = '/home/kirca/FakeData/LabJackData.mat'; %%testing purposes only
%end
%if ~exist('n','var')
%    n = 72;
%end
if ~exist('clean','var')
    clean = true;
end
%structform = load(LJD);
%for i = 1:size(structform')
%    structform(i).labjackData(1:(length(structform(i).labjackData)-72):
%I am an idiot    
%RatesTable = RankSumPrep(LJD,n);
%tableSize = size(LJD.BinnedDataNoLabels{1,1});
%numVariables = tableSize(2);
f1 = figure('Name','Beambreak Events');
f2 = figure('Name','Dispense Events');
%ha = tight_subplot(4,4,[.01 .03],[.1 .01],[.01 .01]);
x = size(LJD);
for i = 1:x(2)
    %axes(ha(i)); 
    for j = 1:4
        figure(f1);
        subplot(4,4,i);
        str = sprintf('BB%i',i);
        hold off
        hold on
        data = LJD(i).BinnedDataNoLabels(:,j);
%       top = max(temp);
%       data = smooth(temp ./ top);
        if clean == true
        data = smooth(data);
        end
        dataSize = size(data);
        n = dataSize(1);
        time = linspace(1,n,n);
    if (j == 1)
        plot(time,data,'m-')
    end
    if (j == 2)
        plot(time,data,'b-')
    end
    if (j == 3)
        plot(time,data,'r-')
    end
    if (j == 4)
        plot(time,data,'g-')
    end
    xlabel('Time');
    ylabel('Hourly Nose Pokes');
    title(str)
    end
    for j = 5:8
        figure(f2);
        subplot(4,4,i);
        str = sprintf('BB%i',i);
        hold off
        hold on
        data = LJD(i).BinnedDataNoLabels(:,j);
%       top = max(temp);
%       data = smooth(temp ./ top);
        if clean == true
        data = smooth(data);
        end
        dataSize = size(data);
        n = dataSize(1);
        time = linspace(1,n,n);
    if (j == 5)
        plot(time,data,'m-')
    end
    if (j == 6)
        plot(time,data,'b-')
    end
    if (j == 7)
        plot(time,data,'r-')
    end
    if (j == 8)
        plot(time,data,'g-')
    end
    xlabel('Time');
    ylabel('Hourly Nose Pokes');
    title(str)
    end
    %legend('Water Beambreak 1','Water Beambreak 2','Food Beambreak 1','Food Beambreak 2','Water Dispense 1','Water Dispense 2','Food Dispense 1','Food Dispense 2')
    end
    %set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
end