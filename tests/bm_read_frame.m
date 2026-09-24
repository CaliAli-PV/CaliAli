function F = bm_read_frame(f, idx)
%% bm_read_frame: Read one frame from a .mat recording.
%
% Inputs:
%   f, idx - File and frame index.
%
% Outputs:
%   F - The frame.

if iscell(f), f = f{1}; end
m = matfile(char(f));
F = m.Y(:,:,idx);
end
