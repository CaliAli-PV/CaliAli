function krn = gauss_spatial(sz,sigma)
% GAUSS_SPATIAL Creates a Gaussian averaging kernel in the spatial domain
%
% krn = gauss_spatial(sz,sigma)
%
% INPUT ARGUMENTS
% sz            - Size of desired kernel
% sigma         - Sigma of desired kernel
% 
% OPTIONAL INPUT ARGUMENTS
% N/A
%
% OUTPUT ARGUMENTS
% krn           - Gaussian filter kernel

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

halfSize = (sz - 1) / 2;
sigma2 = 2 * sigma*sigma;
krn = zeros(sz,1);
for k = 1 : sz
    u = k - halfSize - 1;
    krn(k) = exp(-u^2 / sigma2);
end
krn = krn/sum(krn);

end