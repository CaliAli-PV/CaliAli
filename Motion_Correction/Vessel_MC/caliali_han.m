function y = caliali_han(x)
%% caliali_han: Taper a whole frame before its transform, so the seam does not show.
%
% Used by normcorre_batch, with windowing on (non-rigid correction only), for the
% whole-frame shift that centres the search of every patch. The PATCHES keep
% NoRMCorre's own han. Two changes from han: the mean is subtracted first, and
% the taper is a true Hann window rather than a Hamming one.
%
% WHY IT EXISTS. The correlation NoRMCorre maximises is circular, so the left
% edge sits next to the right edge and that seam produces a spurious peak at
% zero shift -- the bias that pulls every estimate toward finding no motion. A
% taper removes the seam only if the edges actually reach zero. Hamming bottoms
% out at 0.08, so on an image carrying any offset most of the seam survived.
%
% NOT ON THE PATCHES. It was written for them, and measured better there before
% the non-rigid correction registered a high-passed reference and cut its moving
% borders between levels. With those, motion left after correction (px, levels
% 1 / 2 / 3; rigid alone leaves 0.134, 0.432 and 0.826):
%
%                       han on the patches     caliali_han on the patches
%   no deformation      0.134 / 0.144 / 0.159   0.223 / 0.297 / 0.333
%   1.5 px deformation  0.319 / 0.262 / 0.243   0.279 / 0.314 / 0.347
%   3 px deformation    0.603 / 0.454 / 0.386   0.418 / 0.344 / 0.363
%
% On the patches it made a still recording worse than rigid correction alone,
% and every added level worse again. With han, non-rigid correction never did
% worse than rigid alone and each level helped, which is what the advice to
% raise non_rigid_levels assumes.
%
% WHY IT IS NOT CALLED han. It could have replaced the vendored file, and did at
% first. But a user with their own NoRMCorre installation would then have two
% files of the same name on the path, and which one won would depend on the
% order the folders were added -- CaliAli would work or not depending on
% something neither it nor the user was thinking about. Under its own name there
% is no contest to win: CaliAli's motion correction calls this, a separate
% NoRMCorre installation keeps its own han untouched, and neither can shadow the
% other.
%
% Inputs:
%   x - The patch, two or three dimensional.
%
% Outputs:
%   y - The patch, centred and tapered.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

sx = size(x);
x = x - mean(x(:));
y = bsxfun(@times, x, hann(sx(1))*hann(sx(2))');
if length(sx) == 3
    h3(1,1,1:sx(3)) = hann(sx(3));
    y = bsxfun(@times, y, h3);
end
end
