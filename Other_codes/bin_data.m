function M=bin_data(A,sf,binsize)
%

k=binsize*sf;
blockSize = [1,k];
meanFilterFunction = @(theBlockStructure) sum(theBlockStructure.data(:));
M = blockproc(full(A), blockSize, meanFilterFunction);
