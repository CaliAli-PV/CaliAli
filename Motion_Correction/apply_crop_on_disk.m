function apply_crop_on_disk(mat_path, varname)
% Crop borders on disk using mask and batch size stored in CaliAli_options.motion_correction
%
% mat_path : path to .mat file with Y
% varname  : name of the variable (default 'Y')

if nargin < 2 || isempty(varname), varname = 'Y'; end

% Load options (Mask and batch size)
opts = load(mat_path,'CaliAli_options');
if ~isfield(opts,'CaliAli_options') || ...
   ~isfield(opts.CaliAli_options,'motion_correction') || ...
   ~isfield(opts.CaliAli_options.motion_correction,'Mask') || ...
   ~isfield(opts.CaliAli_options.motion_correction,'batch_sz')
    error('CaliAli_options.motion_correction.Mask or batch_sz not found.');
end

Mask    = opts.CaliAli_options.motion_correction.Mask;
chunk   = opts.CaliAli_options.motion_correction.batch_sz;


% Open video for streaming
m  = matfile(mat_path,'Writable',true);
sz = size(m,varname);   % [d1 d2 d3]
d1 = sz(1); d2 = sz(2); d3 = sz(3);

if chunk==0
    chunk=d3;
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

% Prepare temporary file
[pth,nam,ext] = fileparts(mat_path);
tmp = fullfile(pth,[nam '_tmp' ext]);
mt  = matfile(tmp,'Writable',true);

probe = m.(varname)(1,1,1);

% Preallocate output variable
Y1 = m.(varname)(r1:r2, c1:c2, 1);
mt.(varname)(size(Y1,1), size(Y1,2), d3) = cast(0,class(probe));

% Stream copy in chunks
for t1 = 1:chunk:d3
    t2 = min(t1+chunk-1, d3);
    Yblk = m.(varname)(r1:r2, c1:c2, t1:t2);
    mt.(varname)(:,:,t1:t2) = cast(Yblk,class(probe));
end

% Copy CaliAli_options into the new file too
save(tmp,'-append','-struct','opts');

% Replace original atomically
bak = fullfile(pth,[nam '_bak' ext]);
movefile(mat_path,bak,'f');
movefile(tmp,mat_path,'f');
delete(bak);

end