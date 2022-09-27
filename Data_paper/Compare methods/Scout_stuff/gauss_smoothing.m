function outData = gauss_smoothing(inData, sigma)
% function outData = gauss_smoothing(inData, sigma)
%
% Performs gaussian smoothing
%
% INPUT ARGUMENTS
% inData            - Data to smooth
% sigma             - Sigma of the spatial Gaussian kernel to apply, kernel size
%                     will be computed as sigma*5
%
% OPTIONAL INPUT ARGUMENTS
% N/A
%
% OUTPUT ARGUMENTS
% outData           - Smoothed data

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

global USE_CUDA
if ~isempty(USE_CUDA) && USE_CUDA && ndims(inData) == 3
    useCUDA = true;
else 
    useCUDA = false;
end

if (sigma)
    if useCUDA
        outData = CUDA_gauss_smoothing3d(inData, sigma);
    else
        dims = length(size(inData));
        
        % Choose a proper filter kernel size
        sz = round(sigma*5);
        
        % Ensure odd sized filter
        sz = sz+(1-mod(sz,2));
        
        % Create a filter
        krn = gauss_spatial(sz, sigma);
        
        % Perform value convolution
        outData = imfilter(inData, krn, 'replicate');
        
        if(dims == 3)
            outData = imfilter(outData, krn', 'replicate');
            outData = imfilter(outData, permute(krn, [3 2 1]), 'replicate');
        elseif(dims == 2)
            outData = imfilter(outData, krn', 'replicate');
        elseif (dims == 1)
            
        else
            error('Unsupported number of dimensions');
        end
    end
else
    outData = inData;
end