function outData = normgauss_smoothing(inData, cert, sigma)
% NORMGAUSS_SMOOTHING Performs normalized gaussian smoothing
%
% function outData = normgauss_smoothing(inData, cert, sigma)
%
% INPUT ARGUMENTS
% inData            - Data to smooth
% cert              - Certainty matrix corresponding to inData
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
    cert = cert+eps;
    
    if useCUDA
        outData = CUDA_normalized_gauss_smoothing3d(inData, cert, sigma);
        return
    else
        dims = length(size(inData));
        
        % Choose a proper filter kernel size
        sz = round(sigma*5);
        
        % Ensure odd sized filter
        sz = sz+(1-mod(sz,2));
        
        % Create a filter
        krn = gauss_spatial(sz, sigma);
        
        if(dims == 3)
            % Perform value convolution
            inData = imfilter(inData.*cert, krn, 'replicate');
            inData = imfilter(inData, krn', 'replicate');
            inData = imfilter(inData, permute(krn, [3 2 1]), 'replicate');
            
            % Perform certainty convolution
            cert = imfilter(cert, krn, 'replicate');
            cert = imfilter(cert, krn', 'replicate');
            cert = imfilter(cert, permute(krn, [3 2 1]), 'replicate');
        elseif(dims == 2)
            % Perform value convolution
            inData = imfilter(inData.*cert, krn, 'replicate');
            inData = imfilter(inData, krn', 'replicate');
            
            % Perform certainty convolution
            cert = imfilter(cert, krn, 'replicate');
            cert = imfilter(cert, krn', 'replicate');
        elseif (dims == 1)
            % Perform value convolution
            inData = imfilter(inData.*cert, krn, 'replicate');
            
            % Perform certainty convolution
            cert = imfilter(cert, krn, 'replicate');
        else
            error('Unsupported number of dimensions');
        end
        
        % Deal with zero certainty voxels
        z = find(cert==0);
        cert(z) = 1;
        inData(z) = 0;
        
        % Compute result
        outData = inData./cert;
    end
else
    outData = inData;
end