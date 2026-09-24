function s = bm_mk(id,name,opts,checks,mc,sim)
%% SIM names which simulated recording the scenario runs on. Almost everything
% uses the default one; the non-rigid scenarios need a recording that actually
% deforms, which the default deliberately does not.
if nargin < 6 || isempty(sim), sim = 'default'; end
s = struct('id',id,'name',name,'opts',{opts},'checks',{checks},'mc',mc,'sim',sim);
end
