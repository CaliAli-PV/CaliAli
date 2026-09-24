function sim = bm_simulate(dir_, args, nonrigid_std)
%% bm_simulate: Simulate one recording with known neurons, traces and motion.
%
% Produces the data every scenario runs on. What was put into it is recorded in
% the meta file, so what comes out can be scored against it.
%
% Inputs:
%   dir_         - Where to write the recording.
%   args         - From bm_args, supplying the session and frame counts.
%   nonrigid_std - Deformation amplitude in pixels. Zero leaves the motion
%                  purely translational.
%
% Outputs:
%   sim - Structure with the file list and the path to the ground truth.
%
% Notes:
%   - Each session is given a different motion amplitude. Equal amplitudes make
%   every session crop to almost the same size, which never exercises the case
%   where sessions reach alignment at genuinely different sizes.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

if nargin < 3 || isempty(nonrigid_std), nonrigid_std = 0; end
%% One recording, default neuron settings, with motion.
%
% session_motion_std must be non-zero: it is what makes translation happen, and
% therefore what the valid-region mask is for. Note that setting it to zero also
% makes the simulator append _mc to the filenames.
%
% A DIFFERENT AMPLITUDE PER SESSION. Motion correction crops each session to the
% region that stayed valid through its own shaking, so the amount of shaking
% decides how much is cropped. Give every session the same amplitude and they
% come out within a pixel or two of each other, which never tests the case where
% sessions reach alignment at genuinely different sizes and off centre -- the
% case scenario E exists for. These three span a factor of four.
if ~isfolder(dir_), mkdir(dir_); end
here = pwd; c = onCleanup(@() cd(here)); %#ok<NASGU>
motion = repmat([2 5 8], 1, ceil(args.sessions/3));
files = Simulate_Ca_video('outpath', dir_, 'ses', args.sessions, 'F', args.frames, ...
    'seed', 20260915, 'save_GT', false, 'save_mat', true, 'save_avi', 1, ...
    'session_motion_std', motion(1:args.sessions), ...
    'session_nonrigid_std', nonrigid_std, 'translation_misalignment', 1);
cd(here);
sim = bm_load_simulation(dir_);
sim.files = files;
end
