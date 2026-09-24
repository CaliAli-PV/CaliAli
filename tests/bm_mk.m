function s = bm_mk(id,name,opts,checks,mc,sim)
%% bm_mk: Build one scenario entry.
%
% Inputs:
%   id, name - Identifier and description.
%   opts     - Option overrides, as name/value pairs.
%   checks   - Names of the checks this scenario enables.
%   mc       - true, false, or 'external' for motion correction.
%   sim      - Which simulated recording to use. Defaults to the shared one.
%
% Outputs:
%   s - One scenario entry.

if nargin < 6 || isempty(sim), sim = 'default'; end
s = struct('id',id,'name',name,'opts',{opts},'checks',{checks},'mc',mc,'sim',sim);
end
