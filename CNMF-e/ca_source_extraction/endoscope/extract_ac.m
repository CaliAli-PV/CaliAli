function [ai, ci, ind_success, sn] = extract_ac(HY, Y, ind_ctr, sz, spatial_constraints)
%% given a patch of raw & high-pass filtered calcium imaging data, extract
% spatial and temporal component of one neuron (ai, ci). if succeed, then
% return an indicator ind_succes with value 1; otherwise, 0.
%% inputs:
%       HY:     d X T matrix, filtered patch data
%       Y:      d X T matrix, raw data
%       ind_ctr:        scalar, location of the center
%       sz:         2 X 1 vector, size of the patch
%       spatial_constraints: cell
%% Author: Pengcheng Zhou, Carnegie Mellon University.

%% parameters
nr = sz(1);
nc = sz(2);
min_corr = 0.2; %
min_pixels = 5;

%% find pixels highly correlated with the center
% HY(HY<0) = 0;       % remove some negative signals from nearby neurons
y0 = HY(ind_ctr, :);
tmp_corr = reshape(corr(y0', HY'), nr, nc);
tmp_corr(tmp_corr<0)=0;
I=mat2gray(tmp_corr)>min_corr;
I=get_central_blob(I,nr,nc,ind_ctr);
data = HY(I, :);

%% estimate ci with the mean or rank-1 NMF
ci = mean(data, 1);

if norm(ci)==0  % avoid empty results
    ai=[];
    ind_success=false;
    return;
end

%% extract spatial component
% estiamte the background level using the boundary
y_bg = median(Y(~I, :), 1); %
% y_bg = median(Y(~Ix, :), 1); 

%%%%%%%%%%%%%%%%%%%  WHAT A PITY %%%%%%%%%%%%%%%%%%%%%%
%it's such a pity that this algorithm was abandoned because I found a
%simpler algorithm to solve the problem. For a really long time, I'm proud
%of this idea of removing the background with sorting and differencing.
% tic;
% % sort the data, take the differencing and estiamte ai
% thr_noise = 5;      % threshold the nonzero pixels to remove noise
% [~, ind_sort] = sort(y_bg, 'ascend');   % order frames to make sure the background levels are close within nearby frames
% dY = diff(Y(:, ind_sort), 2, 2);    % take the second order differential to remove the background contributions
% [~, snY] = estimate_baseline_noise(dY(:));  % estimate the noise level in dY
% dci = diff(ci(ind_sort), 2);
% dci(dci>- thr_noise * sn) = 0;
% ai = max(0, dY*dci'/(dci*dci'));  % use regression to estimate spatial component
%%%%%%%%%%%%%%%%%%%% SIMPLER IS BETTER %%%%%%%%%%%%%%%%%%%%%%%%%%

%% estimate ai
T = length(ci);
X = [ones(T,1), y_bg', ci'];
temp = (X'*X)\(X'*Y');
ai = max(0, temp(3,:)');

% if spatial_constraints.circular
%  ai = circular_constraints(reshape(ai, nr, nc)); % assume neuron shapes are spatially convex
% end

if spatial_constraints.connected
    ai = connectivity_constraint(reshape(ai, nr, nc));
end
ai = ai(:);

% %% threshold the spatial shape and remove outliers
% % remove outliers
% temp =  full(ai>quantile(ai(:), 0.5));
% l = bwlabel(reshape(temp, nr, nc), 4);
% temp(l~=l(ind_ctr)) = false;
% ai(~temp(:)) = 0;
if sum(ai(:)>0) < min_pixels %the ROI is too small
    ind_success=false;
    return;
end

% refine ci given ai
% ind_nonzero = (ai>0);
% ai_mask = mean(ai(ind_nonzero))*ind_nonzero;
% ci0 = (ai-ai_mask)'*ai\((ai-ai_mask)'*Y);
% plot(ci, 'r');
% pause;

% we use two methods for estimating the noise level
[b, sn] = estimate_baseline_noise(ci);
psd_sn = GetSn(ci);
if sn>psd_sn
    sn =psd_sn;
    [ci, ~] = remove_baseline(ci, sn);
else
    ci = ci - b;
end
% ind_neg = (ci<-4*sn);
% ci(ind_neg) = rand(sum(ind_neg), 1)*sn;

% normalize the result
% ci = ci / sn;
% ai = ai * sn;
% % return results
if norm(ai)==0
    ind_success= false;
else
    ind_success=true;
end

end

function out=get_central_blob(I,nr,nc,ind_ctr)

% Give each blob a unique ID number (a label).
labeledImage = bwlabel(I);
% Get centroids.
measurements = regionprops(labeledImage, 'Centroid');
centroids = [measurements.Centroid];
xCentroids = centroids(1:2:end);
yCentroids = centroids(2:2:end);
% Find distances to middle of image
[rc,cc] = ind2sub([nr,nc],ind_ctr);

distances = sqrt((cc-xCentroids).^2 + (rc-yCentroids).^2);
% Find the min distance
[~, indexOfMin] = min(distances);
% Extract binary image of only the closest blob
centralBlob = labeledImage == indexOfMin;

se = strel('disk',3);
out = imdilate(centralBlob,se);
end

