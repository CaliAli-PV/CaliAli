function bm_setup_paths(args)
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
