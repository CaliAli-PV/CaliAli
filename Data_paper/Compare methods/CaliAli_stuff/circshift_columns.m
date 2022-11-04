function [B D] = circshift_columns(A, D)
%CIRCSHIFT_COLUMNS Circularly shift each column by a different amount
%
%   B = CIRCSHIFT_COLUMNS(A, SHIFT_VECTOR) circularly shifts the columns in A
%   by the values specified in the vector D. Negative elements of D shift columns up 
%   and positive values shift columns down.
%
%   B = CIRCSHIFT_COLUMNS(A) generates random shift values bound
%   between 0 and the number of rows in A.  
%
%   [B D] = CIRCSHIFT_COLUMNS(...) returns the vector of shift values
%
%   Example:
%       A = [ 1 1 1; 2 2 2; 3 3 3; 4 4 4];
%       B = circshift_columns(A, [0 1 -2]);
%       B =  1     4     3
%            2     1     4
%            3     2     1
%            4     3     2
%
%   see also circshift
% Copyright (c)2012, Stuart P. Layton <stuart.layton@gmail.com>
% http://stuartlayton.com
%
% Revision history:
%   2012/06/31 - Initial Release
%   2012/08/20 - Fixed spelling errors in documentation
% Error out if now matrix is provided
if nargin < 1
    error('circshift_columns:noInputs', 'No input arguments provided');
end
%get the dimensions of A
[nRow nCol] = size(A);
%if a shift vector isn't provided create one
%assuming that shift magnitudes are uniformly distributed between 0
%and the number of rows in A -1
if nargin == 1
    D = randi([0, nRow-1], [1, nCol]);
end
% is D a vector of length equal to the number of columns in A
if ~isvector(D) || numel(D) ~= nCol
    error('circshift_columns:invalidArgument', 'D must be a vector equal in length to the number of columns in A');
end
% the shifting math cannot support values less than 0 or greater than nRow
% if the extremes of D are out of bounds then use modulus to correct them
if min(D) < 0 || max(D) >= nRow;
    D = mod(D, nRow);
end
%Create destination matrix
B = nan(size(A));
%get the number of rows in A
% for each column in B
for i = 1:nCol
    % calculate the indices of the shifted column
    if D(i) == 0
        B(:,i) = A(:,i);
        continue;
    end
    idx = [nRow - D(i) + 1 : nRow,  1 : nRow - D(i) ];
    B(:, i) = A(idx, i);
end
end