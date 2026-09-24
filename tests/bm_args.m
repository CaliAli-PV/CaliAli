function args = bm_args(varargin)
%% bm_args: Parse the benchmark options and prepare the output folder.
%
% Every option the benchmark accepts is declared here with its default, so this
% is the one place to look for what can be set and what it does.
%
% Inputs:
%   varargin - Name/value pairs.
%
% Outputs:
%   args - Structure with every option resolved, including the repository root
%             and the output folder, both created if not given.
%
% Notes:
%   - repo defaults to the parent of this folder. It must not reach higher: the
%   path setup runs genpath on it, and a wider root puts neighbouring checkouts
%   on the path where they shadow the code under test.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

p = inputParser;
p.addParameter('out_dir', '');
p.addParameter('scenarios', {});
p.addParameter('repo', '');
p.addParameter('compare_main', true);
p.addParameter('sim_dir', '');
p.addParameter('frames', 500);
p.addParameter('sessions', 3);
p.addParameter('simulator', '/mnt/nasferatus/CaliAli/simulator/Simulate_Ca_Imaging_video_1.22/Simulate_Ca_Imaging_video');
p.addParameter('metrics', '/mnt/nasferatus/CaliAli/benchmark/metrics');
p.addParameter('unit_only', false);   % the checks that need no data, then stop
p.addParameter('nonrigid_std', 3);    % deformation for the non-rigid scenarios, px
p.parse(varargin{:});
args = p.Results;

if isempty(args.repo)
    % This file lives in tests/, so the repo is one level up. Two levels up is
    % the directory that HOLDS the repo, and genpath of that pulls in every
    % other checkout sitting beside it -- which is how a stale copy of the
    % simulator came to shadow the real one and the benchmark spent a run
    % testing code from a different repository.
    args.repo = fileparts(fileparts(mfilename('fullpath')));
end
if isempty(args.out_dir)
    args.out_dir = fullfile(tempdir, ['CaliAli_benchmark_' datestr(now,'yymmdd_HHMMSS')]); %#ok<TNOW1,DATST>
end
if ~isfolder(args.out_dir), mkdir(args.out_dir); end
end
