function debugCaliAli(neuron)
% debugCaliAli  Collects CaliAli debug info and emails it to the maintainer.
% Only input: neuron
%
% Notes:
% - Uses get_batch_size from the path.
% - Attempts to read loop variable `i` from the caller (if it exists).
% - Emails the log to CaliAli.contact@gmail.com via sendmail (must be configured).

recipient = 'CaliAli.contact@gmail.com';
debugLog = {};

log = @(fmt,varargin) assignin('caller','__tmp__',1); %#ok<ASGLU> % dummy to keep editor quiet
append = @(s) assignin('caller','debugLog',[debugLog; {s}]); %#ok<NASGU>

fprintf('\n=== DEBUG INFO START ===\n');

% 1) inter_session_alignment.F
try
    val = neuron.CaliAli_options.inter_session_alignment.F;
    msg = sprintf('neuron.CaliAli_options.inter_session_alignment.F:\n%s', mat2str(val));
    disp(msg); debugLog = [debugLog; {msg}];
catch ME
    msg = sprintf('Error reading neuron.CaliAli_options.inter_session_alignment.F:\n%s', ME.message);
    fprintf('%s\n', msg); debugLog = [debugLog; {msg}];
end

% 2) neuron.frame_range(2)
try
    val = neuron.frame_range(2);
    msg = sprintf('neuron.frame_range(2): %d', val);
    disp(msg); debugLog = [debugLog; {msg}];
catch ME
    msg = sprintf('Error reading neuron.frame_range(2):\n%s', ME.message);
    fprintf('%s\n', msg); debugLog = [debugLog; {msg}];
end

% 3) get_batch_size(neuron) and fn / loop bounds
F = [];
try
    F = get_batch_size(neuron);
    msg = sprintf('Output of get_batch_size(neuron):\n%s', mat2str(F));
    disp(msg); debugLog = [debugLog; {msg}];
catch ME
    msg = sprintf('Error running get_batch_size(neuron):\n%s', ME.message);
    fprintf('%s\n', msg); debugLog = [debugLog; {msg}];
end

fn = [];
try
    if ~isempty(F)
        fn = [0, cumsum(F)];
        loopUpper = size(fn,2) - 1;           % as used in your for-loop
        msg1 = sprintf('fn = [0 cumsum(F)]:\n%s', mat2str(fn));
        msg2 = sprintf('Loop bounds expression: 1:size(fn,2)-1  --> Evaluates to: 1:%d', loopUpper);
        disp(msg1); debugLog = [debugLog; {msg1}];
        disp(msg2); debugLog = [debugLog; {msg2}];
    else
        msg = 'fn not computed because F is empty.';
        disp(msg); debugLog = [debugLog; {msg}];
    end
catch ME
    msg = sprintf('Error computing fn / loop bounds:\n%s', ME.message);
    fprintf('%s\n', msg); debugLog = [debugLog; {msg}];
end

% 4) Current loop index i (from caller workspace, if present)
try
    i_val = evalin('caller','i');
    msg = sprintf('Current loop variable i (from caller): %s', mat2str(i_val));
    disp(msg); debugLog = [debugLog; {msg}];
catch ME
    msg = sprintf('Loop variable i not found in caller (or error reading it):\n%s', ME.message);
    fprintf('%s\n', msg); debugLog = [debugLog; {msg}];
end

% 5) h5info on out_aligned_sessions
in = [];
try
    outFile = neuron.CaliAli_options.inter_session_alignment.out_aligned_sessions;
    msg = sprintf('HDF5 path (out_aligned_sessions): %s', outFile);
    disp(msg); debugLog = [debugLog; {msg}];

    in = h5info(outFile);
    disp('h5info structure (top-level fields):'); disp(in);
    debugLog = [debugLog; {'h5info structure printed to console'}];
catch ME
    msg = sprintf('Error running h5info:\n%s', ME.message);
    fprintf('%s\n', msg); debugLog = [debugLog; {msg}];
end

% 6) video_dimension = in.Datasets.Dataspace.Size
try
    % If multiple datasets exist, print all sizes
    if ~isempty(in) && isfield(in,'Datasets') && ~isempty(in.Datasets)
        for k = 1:numel(in.Datasets)
            try
                sz = in.Datasets(k).Dataspace.Size;
                dmsg = sprintf('Dataset #%d name: %s | Size: %s', k, in.Datasets(k).Name, mat2str(sz));
                disp(dmsg); debugLog = [debugLog; {dmsg}];
            catch MEk
                dmsg = sprintf('Error reading size for dataset #%d:\n%s', k, MEk.message);
                fprintf('%s\n', dmsg); debugLog = [debugLog; {dmsg}];
            end
        end
    else
        msg = 'No datasets found in HDF5 info or h5info failed.';
        disp(msg); debugLog = [debugLog; {msg}];
    end
catch ME
    msg = sprintf('Error extracting video_dimension:\n%s', ME.message);
    fprintf('%s\n', msg); debugLog = [debugLog; {msg}];
end
try
   i_val = str2double(mat2str(evalin('caller','i')));
   fprintf('Requested frame size by [fn(i)+1,fn(i+1)] is [%d %d]\n', fn(i_val)+1,fn(i_val+1)); 
catch

end



fprintf('=== DEBUG INFO END ===\n\n');

% Email the log

fprintf('CaliAli encountered an unexpected error. Please send the output of this message to CaliAli.contact@gmail.com.\n')