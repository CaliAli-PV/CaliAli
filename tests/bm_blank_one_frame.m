function files = bm_blank_one_frame(files)
%% Make frame 10 of the first video a dropped frame, as a camera would.
v = VideoReader(files{1}); %#ok<TNMLP>
F = read(v, [1 Inf]);
F(:,:,:,10) = 0;
w = VideoWriter(files{1}, 'Uncompressed AVI'); w.FrameRate = v.FrameRate;
open(w); for k = 1:size(F,4), writeVideo(w, F(:,:,:,k)); end; close(w);
end


%% ========================================================================
%  A/B against main
%  ========================================================================
