function x = RankSumPrep(LJD, n)
%RankSumPrep Takes in LabjackData.mat, creates a few lists of
%hourly nose pokes. 
%   Alright, so this requires LabJackData.mat which is currently inside the
%   directory /data/DigitalBox/ and is created through the saving functions
%   in the function GatherCurrentLabJackData. 

%testmode
if ~exist(LJD,'file')
   LJD = '/data/DigitalBox/LabJackData.mat';
   disp('File not found')
end

%% loading and converting directory location to a workable LabJackData form
structform = load(LJD);
LJDcell = struct2cell(structform);
LabJackData = LJDcell{1};

%% Creating a RatesTable based on the compiled data
numboxes = size(LabJackData); %checking size of LabJackData

RatesTable = {};
for i = 1:numboxes(2)
    RatesTable{1,i} = HourlyBin((LabJackData(i).labjackData),n);
    RatesTable{2,i} = str2double(LabJackData(i).BBName);
end

x = RatesTable;
end