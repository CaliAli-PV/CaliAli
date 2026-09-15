function [cls, declared] = resolve_stage_class(stage_opt, input_file)
%% resolve_stage_class: What datatype should this stage write?
%
% THE RULE. The module that preallocates a file is the module that writes it,
% and both ask this function, so the two can never disagree. They did once: the
% output file was preallocated in the class of its INPUT while the stage cast
% its result to a hardcoded uint16, and a v7.3 partial write of a mismatched
% class fails outright rather than converting.
%
% Each writing stage may declare output_class in its own substructure
% (downsampling, motion_correction, inter_session_alignment). Left EMPTY, which
% is the default, the stage keeps whatever class it was given, so the type
% chosen at downsampling flows through the pipeline untouched and nobody has to
% think about it. Set it on one stage and it changes from there onward.
%
% WHY A STAGE MIGHT WANT ITS OWN. Motion correction only translates pixels, so
% it preserves the range it is handed and uint8 is enough if the recording was
% uint8. Detrending CREATES values outside the source range -- background
% removal adds an offset before clipping -- so it needs headroom regardless of
% what the source was.
%
% Only unsigned integer classes are allowed. The pipeline clips against integer
% maxima, calls v2uint8 and v2uint16, and subtracts integers from the data in
% CNMF-e; floating point has never worked through those, so it is rejected here
% rather than failing somewhere less obvious.
%
% Inputs:
%   stage_opt  - the module's own option substructure
%   input_file - the file this stage reads, used when no class is declared
%
% Outputs:
%   cls      - the class to preallocate and cast to
%   declared - true when the stage asked for it, false when inherited
%
% Author: Pablo Vergara

allowed = {'uint8','uint16','uint32'};
cls = ''; declared = false;

if isstruct(stage_opt) && isfield(stage_opt,'output_class') && ~isempty(stage_opt.output_class)
    cls = lower(char(stage_opt.output_class));
    if ~ismember(cls, allowed)
        error('CaliAli:StageClass:unsupported', ...
            ['output_class "%s" is not supported. Use one of: %s. The pipeline ' ...
             'clips against integer maxima and subtracts integers from the data ' ...
             'during extraction, so floating point does not survive it.'], ...
            cls, strjoin(allowed, ', '));
    end
    declared = true;
    return
end

% Nothing declared: keep what this stage was handed.
if nargin > 1 && ~isempty(input_file)
    cls = data_class_of(input_file);
end
if isempty(cls)
    cls = 'uint16';   % nothing to inherit from, so the pipeline default
end
end


function cls = data_class_of(f)
%% The class Y is stored in, from the file's metadata alone.
cls = '';
try
    if iscell(f), f = f{1}; end
    w = whos(matfile(char(f)), 'Y');
    if ~isempty(w) && ~isempty(w.class)
        cls = w.class;
    end
catch
    % unreadable or not a .mat: the caller falls back
end
end
