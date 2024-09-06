function M=bin_data_max(A,sf,binsize)
%

k=binsize*sf;
blockSize = [size(A,1),k];
sumFilterFunction = @(theBlockStructure) max(theBlockStructure.data,[],2);
M = blockproc(full(A), blockSize, sumFilterFunction);
