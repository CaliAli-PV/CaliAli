function Check_initialization_parameters(CaliAli_options)
%CHECK_INITIALIZATION_PARAMETERS
%   Checks CaliAli_options for required initialization data
%   and prints a color-coded summary of neuron initialization status.

% --- Safeguard: Verify required fields ---

if ~isfield(CaliAli_options, 'inter_session_alignment') || ...
        ~isfield(CaliAli_options.inter_session_alignment, 'Cn')  || isempty(CaliAli_options.inter_session_alignment.Cn) || ...
        ~isfield(CaliAli_options.inter_session_alignment, 'PNR') || isempty(CaliAli_options.inter_session_alignment.PNR)
    the_file = uipickfiles('num',1,'FilterSpec', '*.mat','Prompt','Choose target .mat file');
    try
        CaliAli_options=CaliAli_load(the_file{1},'CaliAli_options');
    catch
        cprintf('*red','Chosen file is not a valid CaliAli .mat file.\n');
    end
end


if ~isfield(CaliAli_options, 'inter_session_alignment') || ...
        ~isfield(CaliAli_options.inter_session_alignment, 'Cn')  || isempty(CaliAli_options.inter_session_alignment.Cn) || ...
        ~isfield(CaliAli_options.inter_session_alignment, 'PNR') || isempty(CaliAli_options.inter_session_alignment.PNR)
    cprintf('*red', ['Missing required fields (Cn or PNR) in CaliAli_options.inter_session_alignment.\n' ...
        'Please load a CaliAli_options structure from a ''_det'' or ''Aligned'' .mat file.\n']);
    msg = 'Error: Missing required fields.';
    return;
end

% --- Compute candidate seed points ---
v_max = CaliAli_get_local_maxima(CaliAli_options);

Cn  = CaliAli_options.inter_session_alignment.Cn;
PNR = CaliAli_options.inter_session_alignment.PNR;
ind = (v_max == Cn .* PNR);

% Ensure seed mask exists
if ~isfield(CaliAli_options, 'cnmf') || ...
        ~isfield(CaliAli_options.cnmf, 'seed_mask') || isempty(CaliAli_options.cnmf.seed_mask)
    CaliAli_options.cnmf.seed_mask = ones(size(Cn));
end

Cn_ind  = ind & (Cn  >= CaliAli_options.cnmf.min_corr & CaliAli_options.cnmf.seed_mask);
PNR_ind = ind & (PNR >= CaliAli_options.cnmf.min_pnr  & CaliAli_options.cnmf.seed_mask);

seed = Cn_ind & PNR_ind;
I = sum(seed, 'all');
[d1,d2]=size(Cn);
[y,x]=ind2sub([d1,d2],find(seed));
imagesc(Cn);
hold on;scatter(x,y,'.r');title('Is this correct?');hold off;

% --- Print color-coded summary ---
cprintf('*magenta', 'The number of neurons to be initialized is ');
cprintf('*red', '%d.\n', I);
cprintf('magenta', 'This is the maximum number of neurons that can be extracted.\n');
cprintf('blue', 'If this number does not seem correct, run:\n');
cprintf('_comment', 'CaliAli_set_initialization_parameters(CaliAli_options);\n');

end