function R = highpass_reference(Y, sigma)
%% highpass_reference: The image non-rigid registration is estimated on.
%
% A Gaussian high pass, and not the blood-vessel map the rigid stage uses. Two
% measured reasons.
%
% ITS AUTOCORRELATION IS NARROW. NoRMCorre maximises a cross-correlation, and
% the width of the image's own autocorrelation sets how far that maximum sits
% from the truth: a true 1.5 px shift comes back as 1.42 px when the
% autocorrelation is 2 px wide and as 0.34 px when it is 8 px wide. Measured on
% this pipeline's own data, a high pass has an autocorrelation half-width under
% one pixel, while the vessel map and the neuron projection both sit at six.
% That is most of the difference between recovering a deformation and barely
% moving.
%
% IT COVERS THE FRAME. Vessels are a sparse branching network, so a patch may
% contain none at all and then registers noise. A high pass keeps structure
% everywhere there is texture.
%
% The vessel map remains the right reference for the RIGID stage, where one
% shift is estimated for the whole frame: a wide autocorrelation gives a broad,
% unambiguous peak that finds a large displacement, which is exactly what is
% wanted there and exactly what a sharp peak is bad at.
%
% Inputs:
%   Y     - the video, any numeric class
%   sigma - everything slower than this is removed, in pixels
%
% Outputs:
%   R - single precision, same size
%
% Author: Pablo Vergara

if nargin < 2 || isempty(sigma), sigma = 6; end
R = zeros(size(Y), 'single');
for k = 1:size(Y,3)
    f = single(Y(:,:,k));
    R(:,:,k) = f - imgaussfilt(f, sigma);
end
end
