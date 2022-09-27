function [m,index]=argmin_2d(A);
%% fill in aligned neurons matrix based on neurons in consecutive recordings
% input:
%  A: matrix
% output:
%  m: minimal value of matrix
%  index: index of minimal value
%% Author: Kevin Johnston, University of California, Irvine.

[m,I]=min(reshape(A,1,[]));
[a,b]=ind2sub([size(A,1),size(A,2)],I);
index=[a,b];

