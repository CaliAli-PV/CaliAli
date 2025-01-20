function out = tiff_to_hdf5_split(fullFileName, frames, out_path)
% Splits a multi-frame TIFF image into individual HDF5 files.
%
% Inputs:
%   fullFileName: Path to the input TIFF file (string).
%   frames: Desired number of frames per output file (scalar). This determines
%           how many frames from the original TIFF are contained in each
%           output HDF5 file.
%   out_path: (Optional) Path to the output directory (string). If not
%             provided, the current working directory is used.
%
% Outputs:
%   None (saves HDF5 files to disk). The function does return the last processed data in out variable.
%
% Example:
%   split_tiff('my_image.tif', 20, 'output_folder'); % Each output file will contain 20 frames.
%   split_tiff('my_image.tif', 10); % Each output file will contain 10 frames, saves to current directory

  % Check if the output path is provided, if not, use the current directory.
  if ~exist('out_path', 'var')
    out_path = pwd;
    disp('Output path not provided, using current directory.');
  end

  % Read the TIFF image using ScanImageTiffReader (adjust if using different reader)
  out = ScanImageTiffReader(char(fullFileName));

  % Convert data to uint8 format (adjust data type if needed)
  out = v2uint8(out.data());

  % Reorder dimensions to have frames as the first dimension (adjust if order is different)
  out = permute(out, [2 1 3]);

  % Calculate frame indices based on desired number of frames
  x = round(linspace(0, size(out, 3), round(size(out, 3) / frames) + 1));

  % Generate a sequence of numbers for naming output files
  numbers = 1:length(x);

  % Handle empty input (no frames)
  if isempty(numbers)
    strArray = {};
    return;
  end

  % Calculate the maximum number of digits needed for file names
  maxDigits = max(ceil(log10(abs(numbers(numbers ~= 0)) + 1)));
  if isempty(maxDigits)
    maxDigits = 1;  % Handle case where all numbers are zero
  end

  % Create a format string for consistent file naming
  formatString = sprintf('%%0%dd', maxDigits);

  % Create a cell array of formatted file names
  strArray = arrayfun(@(x) sprintf(formatString, x), numbers, 'UniformOutput', false);

  % Handle matrix input (if numbers becomes a matrix)
  if size(numbers, 2) > 1
    strArray = reshape(strArray, size(numbers));
  end

  % Loop through each frame and save them as individual h5 files
  for i =progress(1:length(numbers) - 1)
    fileName = fullfile(out_path, ['v', strArray{i}, '.h5']);
    saveash5(out(:, :, x(i) + 1:x(i + 1)), fileName, '/Object');
  end
end