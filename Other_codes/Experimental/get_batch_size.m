function F=get_batch_size(neuron)
%% get_batch_size: Frame count of each batch used by the extraction steps.
%
% This is the one place where 'per_session' and 'all_frames' are not the same
% thing. By this point the sessions have been concatenated into a single
% recording, so a batch can either follow the session boundaries or ignore them:
%
%   'per_session'  F stays as the per-session frame counts recorded during
%                  alignment, so no batch ever straddles two sessions
%   'all_frames'   one batch holding the whole concatenated recording
%   'auto'         batches sized from the free memory and the frame size
%   <number>       batches of that many frames
%
% A legacy 0 means 'per_session' here, which is what it has always meant in this
% function, so saved option structs keep behaving the way they did.
%
% Author: Pablo Vergara

F=neuron.CaliAli_options.inter_session_alignment.F;

if isempty(F)
    F=neuron.frame_range(2);
end

dims=neuron.P.mat_data.dims;
gF=dims(3);

bz = neuron.CaliAli_options.inter_session_alignment.batch_sz;
mode = resolve_batch_mode(bz, 'per_session');

switch mode
    case 'per_session'
        % Leave F alone: the batches are the sessions.
    case 'all_frames'
        F = gF;
    otherwise   % 'auto' or a fixed number of frames
        chunk = compute_auto_batch_size(bz,[],[dims(1),dims(2)]);
        chunk = round(chunk*0.5); %to account for overlaping patches and other variables

        if chunk>0
            if gF<chunk
                fprintf(1, 'The defined batch size (%d) is larger than the number of frames in the video (%d). Processing the entire video in a single batch.\n', ...
                    chunk,gF);
                chunk=gF;
            end

            F=diff( round(linspace(0,gF,round(gF/chunk)+1)  )  );
        end
end

%% Sanity check
if sum(F) ~= gF
    fprintf(1, 'Mismatch detected: file contains %d frames, but CaliAli options specify %d frames. Data will be split into the closest matching frame count.\n', ...
        gF,sum(F));
    F = diff(floor(linspace(0, gF, numel(F) + 1)));
end


end
