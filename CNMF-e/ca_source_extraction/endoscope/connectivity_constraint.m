function img = connectivity_constraint(img, thr, sz, ind_max)
% remove small nonzero pixels
if ~exist('thr', 'var') || isempty(thr)
    thr = 0.01;  %% 
end
if ~exist('sz', 'var')||isemtpy(sz)
    sz = 5; 
end
if ~exist('ind_max', 'var')||isemtpy(ctr)
    [~, ind_max] = max(img(:));  
end 


temp = full(img>max(img(:))*thr);
l = bwlabel(temp);   % remove disconnected components
% [~, ind_max] = max(ai_open(:));

img(l(:)~=l(ind_max)) = 0;