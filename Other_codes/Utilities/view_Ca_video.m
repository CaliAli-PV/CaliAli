function view_Ca_video()
%% view_Ca_video: Interactive visualization of calcium imaging video with playback controls.
%
% Inputs:
%   None (prompts the user to select a .mat file containing video data).
%
% Outputs:
%   None (displays the selected video interactively).
%
% Usage:
%   view_Ca_video();
%
% Description:
%   - This function allows users to browse and visualize calcium imaging 
%     videos stored in a .mat file.
%   - The user is prompted to select a .mat file containing the variable `Y`,
%     which represents the video frames.
%   - The function then loads the video and plays it interactively using 
%     the `videofig` function.
%   - `videofig` provides a figure with a horizontal scrollbar and keyboard
%     shortcuts for navigation and playback.
%   - Users can interactively adjust contrast settings using a dedicated
%     contrast button.
%
% Features:
%   - Frame-by-frame navigation using arrow keys.
%   - Jump navigation using Page Up/Page Down and Home/End keys.
%   - Play/Pause functionality with adjustable playback speed.
%   - Interactive contrast adjustment.
%   - Scrollbar for easy frame selection.
%
% Keyboard Shortcuts (via `videofig`):
%   - Enter: Play/Pause at normal speed (default: 25 fps).
%   - Backspace: Play/Pause at slower speed (5x slower).
%   - Left/Right Arrow: Move one frame backward/forward.
%   - Page Up/Page Down: Jump 30 frames backward/forward.
%   - Home/End: Jump to the first/last frame.
%
% Notes:
%   - This function suppresses warnings for a cleaner user experience.
%   - Requires `CaliAli_load` to load video data from the selected file.
%   - Utilizes `videofig` for an enhanced interactive experience.
%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025

warning off
[file,path] =uigetfile('*.mat');
in=[path,file];
V=CaliAli_load(in,'Y');
videofig(size(V,3), @(frm,c) redraw(frm,c,V));
redraw(1,[],V);