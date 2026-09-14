function w = patch_overlap_default(patch_dims, fraction)
%% patch_overlap_default: Patch padding, as a fraction of the patch.
%
% A patch OWNS patch_dims pixels and READS patch_dims + 2*w_overlap. Expressing
% the padding as a fraction keeps that ratio fixed when the patch size changes;
% a pixel count does not. At the default 0.5 the read window is twice the patch
% on each axis, so every pixel falls inside four windows and no patch owns most
% of any neuron.
%
% This replaces two unrelated fallbacks that were reached whenever w_overlap was
% not supplied: ring_radius, which describes the neurons rather than the patch
% geometry, and a bare 10 pixels, which describes nothing at all. Both could
% produce a read window several times the patch, or smaller than one neuron,
% depending on settings that had no business deciding it.
%
% Inputs:
%   patch_dims - [rows cols] the patch owns. Defaults to [64 64].
%   fraction   - padding as a fraction of the smaller side. Defaults to 0.5,
%                the same value CNMFE_parameters uses, which reproduces the
%                historical 32 px for the historical 64x64 patch.
%
% Author: Pablo Vergara

if nargin < 1 || isempty(patch_dims), patch_dims = [64, 64]; end
if nargin < 2 || isempty(fraction),   fraction   = 0.5;      end
w = round(fraction * min(patch_dims));
end
