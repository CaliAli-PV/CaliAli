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
d=size(neuron.Cn);

session=zeros([d(1),d(2),N]);

% [~,~,~,~,mask]=get_contoursPV(neuron,0.6);
for i=1:N
    A=full(neuron.A(:, i));
    A=smooth_a(A,d);
    A=A./max(A);
    t=reshape(A,d);
    %  t=t.*mask(:,:,i);
    session(:,:,i)=t;
end
session = permute(session,[3 1 2]);


if saveme==1
path2=path+"Footprints.mat";
save(path2,"session")
end

end

function  a=smooth_a(a,d)
h = fspecial('disk',3.5);
for i=1:size(a,2)
    t=mat2gray(reshape(a(:,i),d));
    t(t<0.5)=0;
    im=imfilter(t,h,'replicate');
    a(:,i)=im(:);
end
end



