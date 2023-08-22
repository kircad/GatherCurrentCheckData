function z = HourlyBin(ConcatData)
%HOURLYBIN This function takes in a box's concatenated data and converts it
%into a list that is expressed in pokes per hour
%   Literally what I just fucking said. But ConcatData is just a table
%   variable of the concatenated data


time0 = table2array(ConcatData(1,1)); % Stores initial tim

modtable = zeros(size(ConcatData(:,1))); % modtable will store hour discretizations

for i = 1:size(ConcatData(:,1))
   modtable(i) = mod((table2array(ConcatData(i,1)) - time0),3600) / 3600; % creates 0-1 markers. 0 means reset hours
end 

for i = 1:(size(ConcatData(:,1)) - 1) %this for loop goes through and marks every hour with a 1
   if modtable(i) > modtable(i + 1)
       modtable(i) = 1; 
   else 
       modtable(i) = 0;
   end
end

modtable(end) = [];

%RatesChart = zeros(sum(modtable),sum(size(ConcatData(1,:))) - 1);
%creating the actual rates chart now
RatesChart = double.empty;
RatesChartBig = double.empty;
marker = 1;
dimx = size(ConcatData(1,:)) - 3; % gets the horizontal size of the LJD. Minus 3 because last cols are metadata
for j = 2:dimx(2)
    for i = 1:size(modtable)
        if modtable(i) == 1
            RatesChart = [RatesChart; sum(table2array(ConcatData(marker:i,j)))];
            marker = i;
        end
    end
    RatesChartBig = [RatesChartBig RatesChart];
    RatesChart = [];
end

%z = num2cell(RatesChartBig);
z = RatesChartBig;
end

