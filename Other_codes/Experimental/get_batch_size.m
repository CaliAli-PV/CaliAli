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
% THE LIST IS DECIDED ONCE, by the first call, and kept in neuron.P.batch_frames;
% every later call returns it. The steps of an extraction must agree on it: the
% initialization stores one median frame per batch (P.Ymean) and the temporal
% update reads it by batch number. 'auto' follows the memory that is free at the
% moment of the call, so deciding again at every step let the number of batches
% change part way through, and the temporal update then indexed past the end of
% P.Ymean. initComponents_parallel_PV clears the list, so a new initialization
% decides again.
%
% A neuron saved before the list was kept has none. Its batches are rebuilt from
% the number of medians it holds, by the rule that made them: the sessions under
% 'per_session', otherwise an equal split.
%
% Author: Pablo Vergara

dims=neuron.P.mat_data.dims;
gF=dims(3);

F = stored_batches(neuron, gF);
if ~isempty(F)
    return
end

ym = [];
try
    ym = neuron.P.Ymean;
catch
end
if isempty(ym)
    F = decide_batches(neuron, dims);
else
    F = rebuild_batches(neuron, gF, numel(ym));
end
F = F(:)';
neuron.P.batch_frames = F;
end


function F = stored_batches(neuron, gF)
%% The stored list, or [] if there is none or it does not cover this recording.
F = [];
try
    F = neuron.P.batch_frames;
catch
    return
end
if isempty(F)
    return
end
F = double(F(:)');
if ~(all(F > 0) && all(F == round(F)) && sum(F) == gF)
    fprintf(1, 'The stored batches cover %d frames but the data has %d. Deciding the batches again.\n', ...
        sum(F), gF);
    F = [];
end
end


function F = rebuild_batches(neuron, gF, n)
%% The batches an extraction saved before the list was kept was run with.
S = session_frames(neuron, gF);
mode = resolve_batch_mode(neuron.CaliAli_options.inter_session_alignment.batch_sz, 'per_session');
if strcmp(mode, 'per_session') && numel(S) == n
    F = S;
else
    F = diff(round(linspace(0, gF, n+1)));
end
end


function S = session_frames(neuron, gF)
%% Frames per session, as recorded during alignment.
S=neuron.CaliAli_options.inter_session_alignment.F;

if isempty(S)
    S=neuron.frame_range(2);
end

if sum(S) ~= gF
    fprintf(1, 'Mismatch detected: file contains %d frames, but CaliAli options specify %d frames. Data will be split into the closest matching frame count.\n', ...
        gF,sum(S));
    S = diff(floor(linspace(0, gF, numel(S) + 1)));
end
end


function F = decide_batches(neuron, dims)
%% Decide the batches from batch_sz, the free memory and the frame size.
gF=dims(3);
F = session_frames(neuron, gF);

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
end
