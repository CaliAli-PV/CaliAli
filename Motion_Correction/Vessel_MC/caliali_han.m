function y = caliali_han(x)
%% caliali_han: Taper a patch before its transform, so the seam does not show.
%
% Replaces NoRMCorre's han for the calls CaliAli makes. Two changes: the patch
% mean is subtracted first, and the taper is a true Hann window rather than a
% Hamming one.
%
% WHY IT MATTERS. The correlation NoRMCorre maximises is circular, so a patch's
% left edge sits next to its right edge and that seam produces a spurious peak
% at zero shift -- the bias that pulls every estimate toward finding no motion.
% A taper removes the seam, but only if the edges actually reach zero. Hamming
% bottoms out at 0.08, so on a patch carrying any offset most of the seam
% survived. Subtracting the mean first is what lets the taper finish the job.
%
% Measured on a simulation with a known 1.5 px rms deformation, reporting the
% misalignment left behind:
%
%                        NoRMCorre's han    this one
%   one 3x3 level            1.141 px        0.757 px
%   two levels               1.313           0.673
%   four levels              0.770           0.550
%
% NoRMCorre's version is also non-monotonic in the number of levels, which a
% cascade refining its own residual should never be.
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
