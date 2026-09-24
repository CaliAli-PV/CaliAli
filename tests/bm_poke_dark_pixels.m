function dark = bm_poke_dark_pixels(files)
%% bm_poke_dark_pixels: Kill a few sensor pixels in the raw recording.
%
% Inputs:
%   files - The input videos.
%
% Outputs:
%   dark - Where each pixel was killed.

dark = struct('file', {}, 'rc', {});
for i = 1:numel(files)
    v = VideoReader(files{i}); %#ok<TNMLP>
    F = read(v, [1 Inf]);
    rc = [round(size(F,1)*[0.3 0.5 0.7])', round(size(F,2)*[0.4 0.5 0.6])'];
    for k = 1:size(rc,1)
        F(rc(k,1), rc(k,2), :, :) = 0;
    end
    w = VideoWriter(files{i}, 'Uncompressed AVI'); w.FrameRate = v.FrameRate;
    open(w); for t = 1:size(F,4), writeVideo(w, F(:,:,:,t)); end; close(w);
    dark(end+1) = struct('file', files{i}, 'rc', rc); %#ok<AGROW>
end
end
