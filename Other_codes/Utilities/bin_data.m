function M=bin_data(A,sf,binsize)
%

k=binsize*sf;
blockSize = [size(A,1),k];
sumFilterFunction = @(theBlockStructure) sum(theBlockStructure.data,2);
M = blockproc(full(A), blockSize, sumFilterFunction);
