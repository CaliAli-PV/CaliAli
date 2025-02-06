function [P, CaliAli_options] = sessions_translate(P, CaliAli_options)
%% sessions_translate: Align session data by applying translation corrections.
%
% Inputs:
%   P               - Cell array containing the session projections.
%   CaliAli_options - Structure containing configuration options for alignment.
%                     Details can be found in CaliAli_demo_parameters().
%
% Outputs:
%   P               - Updated cell array with translated projections.
%   CaliAli_options - Updated structure with applied translation shifts.
%
% Usage:
%   [P, CaliAli_options] = sessions_translate(P, CaliAli_options);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Determine the reference projection (Blood vessels or Neurons) based on the configuration options
if contains(CaliAli_options.inter_session_alignment.projections, 'BV')
    ref = cell2mat(P{1,2}); % Blood vessels
else
    ref = cell2mat(P{1,3}); % Neurons
end

% Normalize the reference image for alignment
ref = mat2gray(ref);
[d1, d2, d3] = size(ref);
bound1 = 20;  % Boundary padding size in the first dimension
bound2 = 20;  % Boundary padding size in the second dimension

% If alignment is not enabled, return a mask with no shifts
if ~CaliAli_options.inter_session_alignment.do_alignment
    Mask = true(d1, d2);
    T = zeros(d3, 2); % No translation applied
    return
end

% Notify the user that alignment is starting
fprintf(1, 'Aligning video by translation ...\n');

% Set the parameters for NoRMCorre alignment
options_r = NoRMCorreSetParms('d1', d1-bound1, 'init_batch', 1, ...
    'd2', d2-bound2, 'bin_width', 2, 'max_shift', [1000, 1000, 1000], ...
    'iter', 5, 'correct_bidir', false, 'shifts_method', 'fft', 'boundary', 'NaN');

% Perform the NoRMCorre batch alignment
[M, shifts, ~] = normcorre_batch(ref(bound1/2+1:end-bound1/2, bound2/2+1:end-bound2/2, :), options_r);

% Adjust the shifts to center them around the mean shift for each session
C1 = mean([shifts(:).shifts], 2);
C2 = mean([shifts(:).shifts_up], 2);
for i = 1:size(shifts, 1)
    shifts(i).shifts = shifts(i).shifts - C1;
    shifts(i).shifts_up = shifts(i).shifts_up - C2;
end

% Apply the computed shifts to the projections in P
for i = 1:size(P, 2) - 1
    temp = apply_shifts(cell2mat(P{1, i}), shifts, options_r);
    [temp, Mask] = remove_borders(temp);  % Remove borders (optional step to improve alignment quality)
    P{1, i} = {temp};  % Update the projection with the shifted data
end

% Apply scaling to the projections
P = scale_Cn(P);

% Store the calculated shifts in the transformation matrix (T)
for i = 1:size(shifts, 1)
    T(i, :) = flip(squeeze(shifts(i).shifts)');
end

% Update the CaliAli_options structure with the applied shifts and mask
CaliAli_options.inter_session_alignment.T = T;
CaliAli_options.inter_session_alignment.T_Mask = Mask;

end

function P = scale_Cn(P)
% SCALE_Cn Scales the projections to a uint8 format with joint scaling for comparison.
%   This function takes the projections and scales them to a uint8 format while preserving relative intensities.
%   The resulting projections are fused for visual comparison.
%
%   Input:
%       P - The projections data.
%
%   Output:
%       P - The updated projections with scaled and fused visual comparison data.

% Convert the reference projection (Neurons or BV) to uint8 format
C = v2uint8(mat2gray(P.(3){1, 1}));
ref = v2uint8(P.(2){1, 1});

% Fuse the projections and the reference using joint scaling and color channels
for k = 1:size(C, 3)
    X(:,:,:,k) = imfuse(C(:,:,k), ref(:,:,k), 'Scaling', 'joint', 'ColorChannels', [1 2 0]);
end

% Store the fused projections in the fifth field of P for visualization
P.(5){1, 1} = X;
end
