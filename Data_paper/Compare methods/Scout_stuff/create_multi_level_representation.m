function outData = create_multi_level_representation(inData, numberOfScales)
% CREATE_MULTI_LEVEL_REPRESENTATION Use this function to create a multi level represenation of indata.
%
% function outData = create_multi_level_representation(inData, numberOfScales)
%
% INPUT ARGUMENTS
% inData                - In data to create a multi level representation for,
%                         i.e. resampling data with a factor of two and
%                         filtering with a Gaussian kernel before resampling to
%                         avoid aliasing.
% numberOfScales        - Number of levels to create. Original is always
%                         included.
%
% OPTIONAL INPUT ARGUMENTS
% N/A
%
% OUTPUT ARGUMENTS
% outData               - Multi level representation of the in data as a cell
%                         object. First cell corresponds to original scale.

% Copyright (c) 2012 Daniel Forsberg
% danne.forsberg@outlook.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

outData = cell(numberOfScales,1);
outData{1} = inData;

for scale = 2 : numberOfScales
    targetSize = round(size(outData{scale - 1})/2);
    outData{scale} = resampler(outData{scale - 1}, targetSize);
end
