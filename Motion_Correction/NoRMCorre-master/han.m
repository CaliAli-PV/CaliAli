function y = han(x,frac) %#ok<INUSD>
%% MODIFIED FOR CaliAli. The original is in the NoRMCorre repository.
%
% WHAT CHANGED. The patch mean is subtracted before the taper, and the taper is
% a true Hann window rather than a Hamming one. The original multiplied the raw
% patch by a Hamming window, which bottoms out at 0.08 rather than 0.
%
% WHY. This window exists to stop the transform seeing a discontinuity. The
% correlation is circular, so a patch's left edge sits next to its right edge,
% and that seam produces a spurious peak at zero shift -- the bias that pulls
% every estimate toward finding no motion at all. Tapering removes the seam, but
% only if the edges actually reach zero. On a patch with any offset, 8% of a
% large pedestal is still a large pedestal, so the original left most of the
% seam in place.
%
% WHAT IT IS WORTH. Measured on a simulated recording with a known 1.5 px rms
% deformation, reporting the misalignment left after non-rigid correction:
%
%                        original han    this one
%   one 3x3 level          1.141 px      0.757 px
%   two levels             1.313         0.673
%   four levels            0.770         0.550
%
% The original is also non-monotonic -- two levels worse than one and worse than
% four -- which a cascade refining its own residual should never be.
%
% WHAT IT AFFECTS. Nothing else in CaliAli. han is called only from
% normcorre_batch, at lines 214, 314-315 and 480, and every one of those sits
% inside `if use_windowing`. use_windowing is set true in exactly one place in
% the pipeline, Non_rigid_mc, so for the rigid stage and inter-session
% alignment this function never runs.
%
% FRAC, the original second argument, is ignored. It controlled how far the
% Hamming window was notionally zero-padded before truncation; a true Hann
% window needs no such parameter.
%
% Author: Pablo Vergara

sx = size(x);
x = x - mean(x(:));
y = bsxfun(@times, x, hann(sx(1))*hann(sx(2))');
if length(sx) == 3
    h3(1,1,1:sx(3)) = hann(sx(3));
    y = bsxfun(@times, y, h3);
end
end
