function bm_setup_paths(args)
%% bm_setup_paths: Put the repository under test on the path, and nothing else.
%
% Clears the path and rebuilds it from the repository, the simulator and the two
% helper folders, in that order, so nothing can shadow the code being measured.
%
% Inputs:
%   args - From bm_args, supplying repo, simulator and metrics.
%
% Outputs:
%   None.
%
% Notes:
%   - The helper folders are added by name. Adding their parent would sweep in the
%   worktree of main that the A/B comparison checks out, and every function would
%   then come from main instead of from the branch under test.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

repo = args.repo; simulator = args.simulator; metrics = args.metrics;
%% Put the repo under test on the path, and nothing that could shadow it.
%
% This used to add genpath(fileparts(metrics)), the whole scratch tree the
% benchmark writes into. The worktree of main that the A/B comparison checks out
% lives in that tree, so on the SECOND run every function came from main
% instead of from the branch under test -- addpath prepends, so the later
% addpath wins. The unit checks failed with main's error messages while
% reporting on this branch. Add the two helper folders by name instead.
restoredefaultpath;
addpath(genpath(repo));
if isfolder(simulator), addpath(genpath(simulator)); end
if isfolder(metrics),   addpath(metrics); end
harness = fullfile(fileparts(metrics), 'harness');
if isfolder(harness),   addpath(harness); end
% The repo under test must win over anything added above it.
addpath(genpath(repo));
warning('off','MATLAB:rmpath:DirNotFound');
end
