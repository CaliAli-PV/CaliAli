function outData = create_multi_scale_representation(inData, numberOfScales)
% CREATE_MULTI_SCALE_REPRESENTATION Use this function to create a multi scale represenation of indata.
%
% function outData = create_multi_scale_representation(inData, numberOfScales)
%
% INPUT ARGUMENTS
% inData                - In data to create a multi scale representation for,
%                         i.e. smoothing data with an increasing sigma of the 
%                         Gaussian kernel.
% numberOfScales        - Number of scales to create. Original is always
%                         included.
%
% OPTIONAL INPUT ARGUMENTS
% N/A
%
% OUTPUT ARGUMENTS
% outData               - Multi scale representation of the in data as a cell
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

dims = ndims(inData);

outData = cell(numberOfScales,1);

for scale = 1 : numberOfScales
    switch dims
        case 2
            N = 2^(2*scale) + 1;
            g = gaussian_app(N, 1, 0.15*(N-1));
            g = g / sum(g);
            c = imfilter(imfilter(ones(size(inData)), g), g');
            outData{scale} = imfilter(imfilter(inData,g),g') ./ c;
        case 3
            N = 2^(2*scale - 1) + 1;
            g = gaussian_app(N, 1, 0.15*(N-1));
            g = g / sum(g);
            c = imfilter(imfilter(ones(size(inData)), g), g');
            outData{scale} = imfilter(imfilter(imfilter(inData,g),g'),permute(g,[3 1 2])) ./ c;
    end
    
end
