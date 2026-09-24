function sim = bm_load_simulation(dir_)
%% bm_load_simulation: Read a recording that was simulated earlier.
%
% Inputs:
%   dir_ - Folder holding the videos and the meta file.
%
% Outputs:
%   sim - Same structure bm_simulate returns.

mf = dir(fullfile(dir_,'*_meta.mat'));
if isempty(mf), error('CaliAli:benchmark:noMeta','No *_meta.mat in %s', dir_); end
[~,i] = max([mf.datenum]);
sim.meta = fullfile(mf(i).folder, mf(i).name);
sim.dir = dir_;
av = dir(fullfile(dir_,'*_ses*.avi'));
sim.files = arrayfun(@(f) fullfile(f.folder,f.name), av, 'UniformOutput', false);
end
