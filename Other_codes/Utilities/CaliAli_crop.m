function CaliAli_crop(backup_options)
% CaliAli_crop  Interactively crop imaging data across multiple sessions.
%
% Usage:
%   CaliAli_crop(backup_options)
%
% Notes:
%   - Cropping must be applied **before detrending, calculating projections,
%     or aligning videos**, because cropping changes frame dimensions and
%     invalidates previously computed results.
%   - Each .mat file must contain a variable Y (d1 x d2 x d3).
%   - If CaliAli_options is missing, backup_options will be used instead.

if ~exist('backup_options','var')
    backup_options = [];
end

% Let user select .mat input files
input_files = uipickfiles('FilterSpec', '*.mat');

% Collect median frames from each file
M = cell(1,length(input_files));
for i = progress(1:length(input_files),'Title','Extracting median frames...')
    m = matfile(input_files{i},'Writable',true);

    try
        % Try to load CaliAli options
        opt = m.CaliAli_options;
    catch
        % If not found, fall back to provided backup_options
        if ~isempty(backup_options)
            opt = backup_options;
            fprintf('File %s does not contain a CaliAli_options structure.\n', input_files{i})
            fprintf('The provided options will be saved to the file.\n')
            m.CaliAli_options = opt;  % save into file
        else
            fprintf('File %s does not contain a CaliAli_options structure.\n', input_files{i})
            fprintf('Use CaliAli_crop(CaliAli_options) with a valid CaliAli_Structure to replace it.\n')
            return
        end
    end

    % Extract the median z-slice from Y for visualization
    [d1,d2,d3] = size(m.Y);
    M{i} = double(m.Y(:,:,round(d3/2)));
end

% Align and pad frames to create average projection
P = catpad_centered(3,M{:});
Mask_all = 1-isnan(P);

% Launch interactive cropping app on normalized image
app = crop_app(mat2gray(P));
app.done = 0;
while app.done == 0  % wait until user finishes cropping
    pause(0.05);
end
ver = app.ver;
delete(app);

% Create binary mask from selected region
G = Mask_all(:,:,1)*0;
G(ver(1,2):ver(2,2), ver(2,1):ver(3,1)) = 1;

% Apply cropping mask to all input files
for i = progress(1:length(input_files),'Title','Cropping...')
    [d1,d2] = size(M{i});
    mask = reshape(G(Mask_all(:,:,i)==1), d1, d2);
    apply_crop_on_disk_in(input_files{i}, mask)
end

end


function apply_crop_on_disk_in(mat_path, Mask)
% apply_crop_on_disk_in  Crop borders of Y in a .mat file using a mask.
%
% mat_path : path to .mat file containing variable Y
% Mask     : logical mask specifying region to keep
%
% This function:
%   - Loads CaliAli_options.motion_correction.Mask and batch size
%   - Computes bounding box of Mask
%   - Copies cropped Y to a temporary file in chunks
%   - Replaces original .mat file with cropped version
%

varname = 'Y';

% Load options (must contain motion_correction info)
opts = load(mat_path,'CaliAli_options');
if ~isfield(opts,'CaliAli_options') || ...
   ~isfield(opts.CaliAli_options,'motion_correction') || ...
   ~isfield(opts.CaliAli_options.motion_correction,'Mask') || ...
   ~isfield(opts.CaliAli_options.motion_correction,'batch_sz')
    error('CaliAli_options.motion_correction.Mask or batch_sz not found.');
end

chunk = opts.CaliAli_options.motion_correction.batch_sz;

% Open video on disk
m  = matfile(mat_path,'Writable',true);
sz = size(m,varname);   % [d1 d2 d3]
d1 = sz(1); d2 = sz(2); d3 = sz(3);

if chunk == 0
    chunk = d3;
end

% Validate mask size
if any(size(Mask) ~= [d1 d2])
    error('Mask must be [%d %d].', d1, d2);
end

% Bounding box of mask
[r,c] = find(Mask);
if isempty(r), error('Empty mask.'); end
r1 = min(r); r2 = max(r);
c1 = min(c); c2 = max(c);

% Prepare temporary output file
[pth,nam,ext] = fileparts(mat_path);
tmp = fullfile(pth,[nam '_tmp' ext]);
mt  = matfile(tmp,'Writable',true);

% Preallocate output variable
probe = m.(varname)(1,1,1);
Y1 = m.(varname)(r1:r2, c1:c2, 1);
mt.(varname)(size(Y1,1), size(Y1,2), d3) = cast(0,class(probe));

% Stream copy in chunks (avoid loading full video)
for t1 = 1:chunk:d3
    t2 = min(t1+chunk-1, d3);
    Yblk = m.(varname)(r1:r2, c1:c2, t1:t2);
    mt.(varname)(:,:,t1:t2) = cast(Yblk,class(probe));
end

% Copy CaliAli_options metadata into new file
save(tmp,'-append','-struct','opts');

% Replace original with cropped version
bak = fullfile(pth,[nam '_bak' ext]);
movefile(mat_path,bak,'f');
movefile(tmp,mat_path,'f');
delete(bak);

end