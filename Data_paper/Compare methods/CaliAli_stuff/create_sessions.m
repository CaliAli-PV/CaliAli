function session=create_sessions(saveme,in)

if ~exist('in','var')
    [file,path] = uigetfile('*.mat','open .mat with cnmf-e results');
    load([path,file],'neuron');
else
    load(in,'neuron');
end

if ~exist('saveme','var')
 saveme=0;  
end

N=size(neuron.A,2);
M=size(neuron.Cn,1);
K=size(neuron.Cn,2);
session=zeros([M,K,N]);

% [~,~,~,~,mask]=get_contoursPV(neuron,0.6);
for i=1:N
    A=neuron.A(:, i);
    A=A./max(A,[],1);
    t=reshape(A,M,K);
    t=full(t);
    %  t=t.*mask(:,:,i);
    session(:,:,i)=t;
end
session = permute(session,[3 1 2]);
% newStr = reverse(neuron.file);
% newStr = string(extractBetween(newStr,".","\"));
% newStr = reverse(newStr);

if saveme==1
path2=path+"Footprints.mat";
save(path2,"session")
end



