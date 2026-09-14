function CaliAli_options = CaliAli_downsample_batch(CaliAli_options)
%% CaliAli_downsample_batch: Deprecated name for CaliAli_downsample.
%
% There were once two downsamplers: CaliAli_downsample, which loaded a whole
% recording and cast it to uint8, and CaliAli_downsample_batch, which read in
% chunks and preserved the source datatype. The first clipped uint16 and
% floating-point recordings -- everything above 254 became 255 -- so it has been
% removed and the batch implementation now IS CaliAli_downsample. It handles the
% non-batched case too, so nothing is lost.
%
% This shim exists so that scripts written against the old name keep working.
% It forwards, and warns once per session.
%
% Author: Pablo Vergara

persistent warned
if isempty(warned)
    warning('CaliAli:DownsampleBatchRenamed', ...
        ['CaliAli_downsample_batch has been renamed to CaliAli_downsample. ' ...
         'The old CaliAli_downsample, which cast recordings to uint8 and clipped ' ...
         'anything above 254, has been removed. Update your scripts to call ' ...
         'CaliAli_downsample; this shim will be dropped in a future release.']);
    warned = true;
end

if nargin < 1
    CaliAli_options = CaliAli_downsample();
else
    CaliAli_options = CaliAli_downsample(CaliAli_options);
end
end
