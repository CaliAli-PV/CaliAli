function [A,C_raw]=estimate_components_dendrite(Y_box,center,sz,f,CaliAli_options)

A=cell(1,size(Y_box,2));
C_raw=zeros(size(Y_box,2),f);
BVsz=CaliAli_options.preprocessing.dendrite_size;
BVtheta=CaliAli_options.preprocessing.dendrite_theta;
parfor k=1:size(Y_box,2)
        if ~isempty(Y_box{k})
            [ai, ci_raw, ~] = extract_ac_dendrite(Y_box{k}, center{k},sz{k},BVsz,BVtheta);
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

function [ai, ci, ind_success, sn] = extract_ac_dendrite(Y,ind_ctr, sz,BVsz,BVtheta)

%% parameters
nr = sz(1);
nc = sz(2);
min_pixels = 5;

%% find pixels highly correlated with the center
% HY(HY<0) = 0;       % remove some negative signals from nearby neurons
M=bin_data_max(Y,1,50);
% M=M(:,1:2:end);
y0 = M(ind_ctr, :);
w=M/y0;
w = mat2gray(VerticalVesselness2D(reshape(w,nr,nc),BVsz, [1;1], min([BVtheta,90]),true,0));
I=w>0.02;
I(ind_ctr)=1;
CC = bwconncomp(I);
component_idx = find(cellfun(@(c) ismember(ind_ctr, c), CC.PixelIdxList));
I = false(size(I));
I(CC.PixelIdxList{component_idx}) = true;

data = Y(I, :);

%% estimate ci with the mean or rank-1 NMF
ci = mean(data, 1);

if norm(ci)==0  % avoid empty results
    ai=[];
    ind_success=false;
    return;
end

%% extract spatial component
% estiamte the background level using the boundary
y_bg = mean(Y(~I, :), 1); %
%% estimate ai
T = length(ci);
X = [ones(T,1), y_bg', ci'];
temp = (X'*X)\(X'*Y');
ai = max(0, temp(3,:)');


ai=reshape(ai, nr, nc).*I;
ai = ai(:);

if sum(ai(:)>0) < min_pixels %the ROI is too small
    ind_success=false;
    return;
end

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
if isnan(sum(ai,'all'))
fummy=1
end

end


