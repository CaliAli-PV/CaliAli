function CaliAli_save(target, varargin)
% CaliAli_save: Save or append variables to a MAT-file.
% target:
%   - string filename (original behavior)
%   - cell {filename, session_id, start_frame, end_frame, output_filename} (batch)
% varargin:
%   - positional vars (names via inputname when available), OR
%   - name, value, name, value ... (preferred when names would be lost)

% ---- build data struct from varargin
data = struct();
if isNameValue(varargin)
    for k = 1:2:numel(varargin)
        varName = varargin{k};
        data.(varName) = varargin{k+1};
    end
else
    for i = 1:numel(varargin)
        varName = inputname(i + 1);
        if isempty(varName), varName = ['var' num2str(i)]; end
        data.(varName) = varargin{i};
    end
end

% ---- batch mode
if iscell(target)
    batch_info = target;
    % {filename, session_id, start_frame, end_frame, output_filename}
    start_frame     = batch_info{3};
    end_frame       = batch_info{4};
    output_filename = batch_info{5};
    m = matfile(output_filename, 'Writable', true);

    fn = fieldnames(data);
    for i = 1:numel(fn)
        field = fn{i};
        if strcmp(field, 'Y')
            m.Y(:, :, start_frame:end_frame) = data.(field);
            fprintf('Saved batch frames %d-%d to %s\n', start_frame, end_frame, output_filename);
        else
            % recurse using NAME–VALUE so the name is preserved
            CaliAli_save(output_filename, field, data.(field));
        end
    end
    return;
end

% ---- original (non-batch) behavior
filename = target;
if exist(filename, 'file')
    save(filename, '-nocompression', '-struct', 'data', '-append');
else
    save(filename, '-v7.3', '-nocompression', '-struct', 'data');
end
end

function tf = isNameValue(args)
tf = ~isempty(args) && mod(numel(args),2)==0;
if tf
    names = args(1:2:end);
    tf = all(cellfun(@(x) (ischar(x) || (isstring(x)&&isscalar(x))), names));
end
end