function GSD = RemoveBadDays(GSD, upperBound, BadIdxs, WaterBadIdxs, usingPresetBadIdxs)
%REMOVEBADDAYS Removes NaN and out-of-range values from data 
%   Detailed explanation goes here
if ~exist('upperBound','var')
    upperBound = 10;
end
if ~usingPresetBadIdxs %%Checks for out of range water values
    for i = 1:(size(GSD,2) - 1)
        for j = 1:2
        data = GSD(i).BinnedDataNoLabels(:,j);
        outOfRange = find((data  < 0) | (data > upperBound));
        NaNID = find(isnan(data));
        WaterBadIdxs = [WaterBadIdxs; outOfRange; NaNID];
        end
    end
    WaterBadIdxs = unique(WaterBadIdxs);
end
BadIdxs = unique(sort(BadIdxs));
WaterBadIdxs = unique(sort(WaterBadIdxs));
    for k = 1:(size(GSD,2))
        GSD(k).BinnedDataNoLabelsClean = GSD(k).BinnedDataNoLabels;
        GSD(k).weightClean = GSD(k).weight; %removes ONLY BadIdxs for weights
        totalBadIdxs = unique(sort([BadIdxs, WaterBadIdxs])); %%TO FIX: waterbadidxs needs to be flipped if using preset... kinda dumb
        GSD(k).BinnedDataNoLabelsClean(totalBadIdxs,:) = []; %removes universal badidxs AND water badidxs for water data
        GSD(k).weightClean(BadIdxs) = []; %removes universal badidxs
        % keeps dates, positions the same because we still know that info
    end
    GSDSize = size(GSD,2);
    GSD(GSDSize).BadIdxs = BadIdxs;
    GSD(GSDSize).WaterBadIdxs = WaterBadIdxs;
end

