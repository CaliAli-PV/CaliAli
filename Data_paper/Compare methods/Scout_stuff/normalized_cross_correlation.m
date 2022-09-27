function [ncc] = normalized_cross_correlation(image1,image2)
% NORMALIZED_CROSS_CORRELATION Computes the normalized cross correlation between two images
%
% function [ncc] = normalized_cross_correlation(image1,image2)
%
% INPUT ARGUMENTS
% image1        - Image 1
% image2        - Image 2
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
% sad           - Computed normalized cross correlation

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

ncc = 1/(numel(image1(:)) - 1)*...
      sum((image1(:)-mean(image1(:))).*...
      (image2(:)-mean(image2(:))))/...
      std(image1(:))/std(image2(:));
