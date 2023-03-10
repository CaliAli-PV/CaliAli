function S=separate_sessions(data,F,bin,sf)

% sf is only important when bining data.
% S=separate_sessions(neuron.S,neuron.options.F,1,1);

if ~exist('bin','var')
bin = 0;
end

if ~exist('sf','var')
sf = 1;
end

data=full(data);


if ~exist('F','var')
    [file,path] = uigetfile('*.mat');
    try
        load([path,file],'F');
    catch
        fprintf(1, 'No frame data was detected in %s...\n', file);
    end
end

c=cumsum(F);
c=c(:);
c=[[0;c(1:end-1)]+1,c];

S=cell(1,size(c,1));

for i=1:size(c,1) 
   temp=data(:,c(i,1):c(i,2));
   if (bin>0)
    temp=bin_data(temp,sf,bin);
   end
    S{i}=temp;
end

