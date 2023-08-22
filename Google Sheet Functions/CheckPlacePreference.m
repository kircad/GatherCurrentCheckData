function [pos1DataClean, pos2DataClean, p] = CheckPlacePreference(data, binningtime, AnalysisOutputPath, BadIdxs, mode, dispenserLUT, MakeGraphs)
%CheckPlacePreference determines the presence of place preference in data
%   Graphs food and water data with respect to beam placement in LUT, not
%   fatty/regular or sucrose/regular
%SHOULD IMPORT FULL DATA TABLE
%find row for this BB
%if strcmp(binningtime,'daily')
%    switchtime = ((cell2mat(dispenserLUT(ThisBBRow,21))) * 86400000);
%end
    %ADD MORE BINS
    format short g;
if ~exist('alphaLevel','var')
    alphaLevel = 0.05;
end
%% Add Mode 1 -- takes LJD as input? May be unnecessary now with R code
if mode == 2 %takes GSD as input
    k = 1;
    pos1Data = [];
    pos2Data = [];
    while k <= size(data.BinnedDataNoLabels,1)
        if (strcmp(data.positions(k,1), 'Position 2 (closer to diffuser)'))
            currPos1 = data.BinnedDataNoLabels(k,2); 
            currPos2 = data.BinnedDataNoLabels(k,1);
        else
            currPos1 = data.BinnedDataNoLabels(k,1); 
            currPos2 = data.BinnedDataNoLabels(k,2); 
        end
        if strcmp(data.positions(k,3), 'Yes')
            temp = currPos2;
            currPos1 = currPos2;
            currPos1 = temp;
        end
        pos1Data = [pos1Data; currPos1];
        pos2Data = [pos2Data; currPos2];
        k = k + 1;
    end
    pos1DataClean = pos1Data;
    pos2DataClean = pos2Data;
    pos1DataClean(BadIdxs,:) = [];
    pos2DataClean(BadIdxs,:) = [];
    p = ranksum(pos1DataClean,pos2DataClean);
    pos1Avg = mean(pos1DataClean);
    pos2Avg = mean(pos2DataClean);
    %CALCULATE AVERAGE PLACE PREF + CHECK
    sprintf('BBID : %s\n',data.BBName)
    sprintf('Position 1 Average Consumption: %g ml \n  Position 2 Average Consumption: %g ml',pos1Avg,pos2Avg)
    if p <= alphaLevel
        sprintf('Comparison is SIGNIFICANT. p = %f\n', p)
    else 
        sprintf('Comparison is NOT SIGNIFICANT. p = %f\n', p)
    end
    if MakeGraphs
    placePrefGraph = GraphPlacePreference(data,pos1Data,pos2Data, BadIdxs, p); %TO DO: FIGURE OUT HOW TO GRAPH BAD IDXS
    figSavePath = fullfile(AnalysisOutputPath, 'figures');
    savefigsasindir(figSavePath,placePrefGraph,'fig');
    savefigsasindir(figSavePath,placePrefGraph,'png');
    end
end
%MAKE SURE IT WORKS FOR ALL DATA THEN ANALYZE
end