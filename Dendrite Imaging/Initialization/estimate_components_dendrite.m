function [A,C_raw]=estimate_components_dendrite(Y_box,center,sz,f,CaliAli_options,Cn)

A=cell(1,size(Y_box,2));
C_raw=zeros(size(Y_box,2),f);
BVsz=CaliAli_options.preprocessing.dendrite_size;
BVtheta=CaliAli_options.preprocessing.dendrite_theta;
parfor k=1:size(Y_box,2)
        if ~isempty(Y_box{k})
            [ai, ci_raw, ~] = extract_ac_dendrite(Y_box{k}, center{k},sz{k},BVsz,BVtheta,Cn{k});
            if ~isnan(sum(ci_raw))
                A{k}=ai;
                C_raw(k,:)=ci_raw;
            else
                A{k}=[];
            end
        else
            A{k}=[];
        end
end
end

function [ai, ci, ind_success, sn] = extract_ac_dendrite(Y, ind_ctr, sz, BVsz, BVtheta, Cn)
%EXTRACT_AC_DENDRITE Extracts dendritic signals from calcium imaging data.
%   [ai, ci, ind_success, sn] = EXTRACT_AC_DENDRITE(Y, ind_ctr, sz, BVsz, BVtheta, Cn)
%   extracts the spatial component (ai) and temporal component (ci) of 
%   dendritic signals from calcium imaging data (Y) given the center index 
%   (ind_ctr), image size (sz), blood vessel size (BVsz), blood vessel 
%   orientation (BVtheta), and correlation image (Cn).

%% --- Parameters ---
nr = sz(1);
nc = sz(2);
min_pixels = 5;

%% --- Vesselness Filtering and Region Extraction ---
I = extract_region(Cn, ind_ctr, BVsz, BVtheta);

%% --- Signal Extraction --- 
for iter = 1:2 % Repeat the following steps twice
    [ai, ci] = extract_signals(Y,ind_ctr, I,nr,nc);
    if norm(ci) == 0  % Avoid empty results
        ai = [];
        ind_success = false;
        return;
    end
        I = extract_region(ai, ind_ctr, BVsz, BVtheta);
end

%% --- Post-processing ---
[ai, ind_success, sn] = post_process_signals(ai, ci, min_pixels);

end

%% --- Sub-functions ---
function I = extract_region(data, ind_ctr, BVsz, BVtheta)
    w = mat2gray(VerticalVesselness2D(data, BVsz, [1;1], min([BVtheta,90]), true, 0));
    w = medfilt2(w, [25,1]);
    I = mat2gray(w) > 0;
    I = find_closest_region_boundary(I, ind_ctr);
end

function [ai, ci] = extract_signals(Y,ind_ct, I,nr,nc)
    ci = Y(ind_ct,:);
    y_bg = mean(Y(~I, :), 1); 
    T = length(ci);
    X = [ones(T,1), y_bg', ci'];
    temp = (X'*X)\(X'*Y');
    ai = max(0, temp(3,:)');
    ai = reshape(ai, nr, nc);
    ai(~I)=0;
end

function [ai, ind_success, sn] = post_process_signals(ai, ci,min_pixels)
    ai = ai(:);
    if sum(ai(:) > 0) < min_pixels 
        ind_success = false;
        return;
    end

    [b, sn] = estimate_baseline_noise(ci);
    psd_sn = GetSn(ci);
    if sn > psd_sn
        sn = psd_sn;
        [ci, ~] = remove_baseline(ci, sn);
    else
        ci = ci - b;
    end

    if norm(ai) == 0
        ind_success = false;
    else
        ind_success = true;
    end
end

function [closest_region, region_index] = find_closest_region_boundary(img, n)
%FIND_CLOSEST_REGION_BOUNDARY Finds the region with boundary closest to a coordinate.
%   [closest_region, region_index] = FIND_CLOSEST_REGION_BOUNDARY(img, n) 
%   takes a binary image 'img' and a linear index 'n' as input. It returns 
%   the region (binary image) whose boundary is closest to the pixel 
%   at linear index 'n'. It also returns the index of the region.

% Find connected components
CC = bwconncomp(img);

% Calculate distances from each pixel in each region to the given linear index
[row_n, col_n] = ind2sub(size(img), n);
min_distances = zeros(CC.NumObjects, 1);

for i = 1:CC.NumObjects
    [rows, cols] = ind2sub(size(img), CC.PixelIdxList{i});  % Get row, col for each region
    distances_to_n = vecnorm([cols, rows] - [col_n, row_n], 2, 2);  % Calculate distances for this region
    min_distances(i) = min(distances_to_n); 
end

% Find the region with the minimum distance to its boundary
[~, region_index] = min(min_distances);

% Create a binary image containing only the closest region
closest_region = false(size(img));
closest_region(CC.PixelIdxList{region_index}) = true;

end
