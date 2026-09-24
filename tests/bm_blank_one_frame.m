function files = bm_blank_one_frame(files)
%% bm_blank_one_frame: Blank one frame, as a dropped frame would be.
%
% Inputs:
%   files - The input videos.
%
% Outputs:
%   files - The same list, one video modified.

v = VideoReader(files{1}); %#ok<TNMLP>
F = read(v, [1 Inf]);
F(:,:,:,10) = 0;
w = VideoWriter(files{1}, 'Uncompressed AVI'); w.FrameRate = v.FrameRate;
open(w); for k = 1:size(F,4), writeVideo(w, F(:,:,:,k)); end; close(w);
end


%% ========================================================================
%  A/B against main
%  ========================================================================
