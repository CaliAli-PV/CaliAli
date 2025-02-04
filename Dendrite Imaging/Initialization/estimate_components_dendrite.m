function [A,C_raw]=estimate_components_dendrite(Y_box,comp_mask,sz,f)

A=cell(1,size(Y_box,2));
C_raw=zeros(size(Y_box,2),f);

parfor k=1:size(Y_box,2) % this is parfor
        if ~isempty(Y_box{k})
            [ai, ci_raw, ~] = extract_ac_dendrite(Y_box{k},comp_mask{k},sz{k});
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

function [ai, ci, ind_success, sn] = extract_ac_dendrite(Y, I, sz)
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

%% --- Signal Extraction --- 

[ai, ci] = extract_signals(Y,I,nr,nc);


%% --- Post-processing ---
[ai, ind_success, sn,ci] = post_process_signals(ai, ci, min_pixels);

end

%% --- Sub-functions ---

function [ai, ci] = extract_signals(Y, I,nr,nc)
    ci = mean(Y(I(:),:));
    y_bg = mean(Y(~I(:), :), 1); 
    T = length(ci);
    X = [ones(T,1), y_bg', ci'];
    temp = (X'*X)\(X'*Y');
    ai = max(0, temp(3,:)');
    ai = reshape(ai, nr, nc);
    ai(~I)=0;
end

function [ai, ind_success, sn,ci] = post_process_signals(ai, ci,min_pixels)
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

