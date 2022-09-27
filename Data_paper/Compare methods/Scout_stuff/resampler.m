function output = resampler(input, outputSize, varargin)
% RESAMPLER Resamples the data to the specified data size.
%
% function output = resampler(input, outputSize)
%
% Use this function to resample input to outputSize. Note that smoothing of
% the data will be performed to avoid aliasing when subsamppling.
%
% INPUT ARGUMENTS
% input                 - Data to resample
% outputSize            - Size after resampling
%
% OPTIONAL INPUT ARGUMENTS
% 'interpolation'       - Interpolation to use 'nearest'/'linear'/'cubic'
%                         ('linear')
% 'relativeValues'      - Scale samples according to resampling factor
%                         true/false (false)
% OUTPUT ARGUMENTS
% output                - Resampled data

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

%% Default values

interpolation = 'linear';
relativeValues = false;

% Overwrites default parameters
for k=1:2:length(varargin)
    eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end

%% Check input data

% Check if input is cell based or not
if(iscell(input))
    numberOfCells = length(input);
    dims = length(size(input{1}));
    inputSize = size(input{1});
else
    numberOfCells = 0;
    dims = length(size(input));
    inputSize = size(input);
end

if(sum(outputSize <= 4))
    disp('Image size is too small for this resampling factor. No resampling.')
    output = input;
    return
end

%% Check if using CUDA and in that case run resampling on the GPU
global USE_CUDA;

if ~isempty(USE_CUDA) && USE_CUDA && dims == 3
    if numberOfCells == 0
        output = CUDA_resampling3d(input, outputSize, interpolation, relativeValues);
    else 
        output = cell(numberOfCells,1);
        for n = 1 : numberOfCells
            output{n} = CUDA_resampling3d(input{n}, outputSize, interpolation, relativeValues);
        end
    end
    return;
end

%%
resamplingFactor = inputSize./outputSize;

if sum(resamplingFactor) == dims
    output = input;
end

sigma = resamplingFactor*.4;
filterSize = round(sigma * 5);
filterSize = filterSize + (1-mod(filterSize,2));

filterX = gauss_spatial(filterSize(2), sigma(2));
filterY = gauss_spatial(filterSize(1), sigma(1));
filterX = filterX'/sum(filterX);
filterY = filterY/sum(filterY);

if (dims == 3)
    filterZ = gauss_spatial(filterSize(3), sigma(3));
    
    if (~numberOfCells)
        output = input;
        clear input
        if (resamplingFactor(1) > 1 && ~strcmp('nearest',interpolation))
            output = imfilter(output, filterY, 'replicate','same','conv');
        end
        if (resamplingFactor(2) > 1 && ~strcmp('nearest',interpolation))
            output = imfilter(output, filterX, 'replicate','same','conv');
        end
        if (resamplingFactor(3) > 1 && ~strcmp('nearest',interpolation))
            output = imfilter(output, permute(filterZ, [3 2 1]), 'replicate','same','conv');
        end
        
        [X, Y, Z] = meshgrid(linspace(1,inputSize(2),outputSize(2)),linspace(1,inputSize(1),outputSize(1)),linspace(1,inputSize(3),outputSize(3)));
        output = ba_interp3(output,X,Y,Z,interpolation);
        
        if relativeValues
            output = output / mean(resamplingFactor);
        end
    else
        for n = 1:numberOfCells
            output{n} = input{n};
            input{n} = [];
            if (resamplingFactor(1) > 1 && ~strcmp('nearest',interpolation))
                output{n} = imfilter(output{n}, filterY, 'replicate','same','conv');
            end
            if (resamplingFactor(2) > 1 && ~strcmp('nearest',interpolation))
                output{n} = imfilter(output{n}, filterX, 'replicate','same','conv');
            end
            if (resamplingFactor(3) > 1 && ~strcmp('nearest',interpolation))
                output{n} = imfilter(output{n}, permute(filterZ, [3 2 1]), 'replicate','same','conv');
            end
            
            [X, Y, Z] = meshgrid(linspace(1,inputSize(2),outputSize(2)),linspace(1,inputSize(1),outputSize(1)),linspace(1,inputSize(3),outputSize(3)));
            output{n} = ba_interp3(output{n},X,Y,Z,interpolation);
            
            if(relativeValues)
                output{n} = output{n} / mean(resamplingFactor);
            end
        end
    end
    
elseif(dims == 2)
    [inX,inY] = meshgrid(linspace(0, 1, inputSize(2)), linspace(0,1,inputSize(1)));
    [outX,outY] = meshgrid(linspace(0,1,outputSize(2)), linspace(0,1,outputSize(1)));
    
    if (~numberOfCells)
        output = input;
        clear input;
        if (resamplingFactor(1) > 1 && ~strcmp('nearest',interpolation))
            output = imfilter(output, filterY, 'replicate','same','conv');
        end
        if (resamplingFactor(2) > 1 && ~strcmp('nearest',interpolation))
            output = imfilter(output, filterX, 'replicate', 'same','conv');
        end
        
        output = interp2(inX, inY, output, outX, outY, interpolation);
        
        if(relativeValues)
            output = output / mean(resamplingFactor);
        end
    else
        for n = 1:numberOfCells
            output{n} = input{n};
            input{n} = [];
            if (resamplingFactor(1) > 1 && ~strcmp('nearest',interpolation))
                output{n} = imfilter(output{n}, filterY, 'replicate', 'same','conv');
            end
            if (resamplingFactor(2) > 1 && ~strcmp('nearest',interpolation)) 
                output{n} = imfilter(output{n}, filterX, 'replicate', 'same','conv');
            end
            
            output{n} = interp2(inX, inY, output{n}, outX, outY, interpolation);
            
            if(relativeValues)
                output{n} = output{n} / mean(resamplingFactor);
            end
        end
    end
else
    error('Number of dimensions must be 2 or 3');
end

