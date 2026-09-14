function [C_raw, C, S] = initialize_traces_from_footprints(neuron, F)
%% initialize_traces_from_footprints: First traces for carried footprints, the way initialization does it.
%
% Initialization estimates a trace as the average of the FILTERED data over the
% pixels belonging to the neuron, with no background model (extract_ac.m:
% ci = mean(HY(I,:),1), where I is a binary mask of correlated pixels). When
% footprints are carried from an earlier extraction there is no need for that
% mask: A is the same thing measured, and graded rather than binary, so the
% average is weighted by A. The denominator is sum(A.^2), not sum(A): that is
% the least-squares projection of the data onto the footprint, so that A*C_raw
% reconstructs the data rather than overshooting it. A is not normalised to a
% peak of 1 -- entries reach 8.8 in a real extraction -- so dividing by sum(A)
% gives a trace on the scale of the data which is then multiplied back by A,
% making the reconstruction 1.6 times the data's standard deviation. That
% matters because the background fit removes A*C before fitting.
%
%     C_raw = (A' * HY) ./ sum(A.^2,1)'
%
% HY is built exactly as initialization builds it: spatially filtered with the
% point-spread kernel (skipped when the data was neuron-enhanced), then the
% median over time subtracted WITHIN EACH SESSION. Sessions are handled one at
% a time, which also keeps the data loaded at one session rather than the whole
% recording.
%
% This replaces copying the previous extraction's traces and leaving the new
% frames at zero. Zeros are not neutral: the background fit removes A*C from
% the data before fitting, so a session whose traces are zero has its neural
% activity left in, and the ring model absorbs it.
%
% Inputs:
%   neuron - Sources2D object with A set and data mapped
%   F      - frames per session; defaults to the alignment's record
%
% Outputs:
%   C_raw  - K x T weighted averages
%   C      - K x T deconvolved traces
%   S      - K x T spikes
%
% Author: Pablo Vergara

d1 = neuron.options.d1;
d2 = neuron.options.d2;
gSig = neuron.options.gSig;
gSiz = gSig * 4;

if ~exist('F', 'var') || isempty(F)
    F = neuron.CaliAli_options.inter_session_alignment.F;
end
F = F(:)';
T = sum(F);

A = full(neuron.A);
K = size(A, 2);
w = sum(A.^2, 1)';
w(w <= 0) = 1;          % a footprint with no mass gets a zero trace, not a NaN

% Same kernel as greedyROI_endoscope_PV, and none when the data was enhanced.
ne = neuron.CaliAli_options.preprocessing.neuron_enhance;
if ne == 0 && gSig > 0
    if neuron.options.center_psf
        psf = fspecial('gaussian', ceil(gSig*4+1), gSig);
        ind_nonzero = (psf(:) >= max(psf(:,1)));
        psf = psf - mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
    else
        psf = fspecial('gaussian', round(gSiz), gSig);
    end
else
    psf = [];
end

C_raw = zeros(K, T, 'single');
t0 = 0;
for i = 1:numel(F)
    idx = (t0 + 1):(t0 + F(i));
    Y = neuron.load_patch_data([], [idx(1), idx(end)]);
    if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end
    Y(isnan(Y)) = 0;
    Y = single(Y);
    if isempty(psf)
        HY = Y;
    else
        HY = imfilter(reshape(Y, d1, d2, []), psf, 'replicate');
        HY = reshape(HY, d1*d2, []);
    end
    HY = bsxfun(@minus, HY, median(HY, 2));   % per session, as at initialization
    C_raw(:, idx) = (A' * HY) ./ w;
    t0 = t0 + F(i);                           % accumulate; see note in the header
end

C_raw = double(C_raw);
if nargout > 1
    [C, S] = deconv_PV(C_raw, neuron.options.deconv_options);
end
end
