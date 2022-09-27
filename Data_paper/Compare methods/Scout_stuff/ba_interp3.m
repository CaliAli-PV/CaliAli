function Z = ba_interp3(F, X, Y, Z, method)
% Fast nearest, bi-linear and bi-cubic interpolation for image data
%
% Usage:
% ------
%     Z = ba_interp3(F, X, Y, Z, [method])
%
% where method is one off nearest, linear, or cubic.
%
% F    is a WxHxD Image.
% X, Y, Z are I_1 x ... x I_n matrices with the x, y and z coordinates to
%      interpolate.
%
% Notes:
% ------
% This method handles the border by repeating the closest values to the point accessed. 
% This is different from matlabs border handling.
%
% Licence:
% --------
% GPL
% (c) 2008 Brian Amberg
% http://www.brian-amberg.de/

folder = fileparts(mfilename('fullpath'));
currentFolder = pwd;
cd(folder)

disp('It appears as if ba_interp3.cpp has not been compiled.')
if ~exist('ba_interp3.cpp','file')
    answer = input('ba_interp3.cpp is not available. Download? [y]/[n] ','s');
    if strcmpi(answer,'y') || strcmpi(answer,'yes')
        urlwrite(...
            'https://raw.githubusercontent.com/fordanic/matlab-utilities/master/external/ba_interp3.cpp',...
            'ba_interp3.cpp');
    end
end
disp('Attempting to compile ba_interp3.cpp')
try
    mex -O ba_interp3.cpp
catch
    disp('Compilation of ba_interp3.cpp failed.')
    disp('Make sure that a compiler has been set using mex setup.')
end
cd(currentFolder)

Z = ba_interp3(F, X, Y, Z, method);