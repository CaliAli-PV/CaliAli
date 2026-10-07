function cnmf=estimate_PNR_Coor_Thr(param_in, seed_mask)
% Opens the threshold window (estimate_Corr_PNR) for one file and returns the
% file's CNMF-E settings with the values chosen there.
%
% param_in  - {file, min_pnr, min_corr, gSig}: the values the window opens with.
% seed_mask - (optional) seed mask to start from, e.g. one already drawn in this
%             session. If omitted, the mask saved in the file is used.
%
% Closing the window without pressing Ok! keeps the values it was opened with.

CaliAli_options=CaliAli_load(param_in{1, 1},'CaliAli_options');
cnmf=CaliAli_options.cnmf;
if nargin > 1
    cnmf.seed_mask=seed_mask;
end

opened_with_mask=cnmf.seed_mask;

m=CaliAli_options.inter_session_alignment;
if isempty(cnmf.seed_mask)
    cnmf.seed_mask=ones(size(m.Cn));
end

app=estimate_Corr_PNR(m.Cn,m.PNR,param_in{1, 4},param_in{1, 3},param_in{1, 2},logical(cnmf.seed_mask));
app.done=0;
while isvalid(app) && app.done == 0  % polling
    pause(0.05);
end
if ~isvalid(app)
    % Window closed without Ok!: nothing changes.
    cnmf.seed_mask=opened_with_mask;
    cnmf.min_pnr=param_in{1, 2};
    cnmf.min_corr=param_in{1, 3};
    cnmf.gSig=param_in{1, 4};
    return
end
cnmf.seed_mask=app.mask;
cnmf.Cn=app.cn;
cnmf.PNR=app.pnr;
cnmf.ind=app.tmp_ind;
cnmf.min_pnr=app.PNRSpinner.Value;
cnmf.min_corr=app.corrSpinner.Value;% get the values set in the parameter window
cnmf.gSig=app.gSigSpinner.Value;
delete(app);
