function T=get_stored_projections(opt)
T=table;
for k=1:size(opt.theFiles,2)
    fullFileName = opt.theFiles{k};
    [filepath,name]=fileparts(fullFileName);
    in=strcat(filepath,'\',name,'_det','.mat');
    temp=load(in);
    temp=check_video_sizes(opt,temp,fullFileName);
    T=cat_table(T,temp.P);
end
T=scale_Cn(T);
end
%%=======================================
function T=cat_table(T,P)
if isempty(T)
    T=P;
else
    for i=1:size(P,2)
        T.(i){1,1}=cat(ndims(P.(i){1,1})+1,T.(i){1,1},P.(i){1,1});
    end
end
end
%%=======================================
function P=scale_Cn(P)
C=mat2gray(P.(3){1,1});
Vf=mat2gray(P.(2){1,1});
for k=1:size(C,3)
    X(:,:,:,k)=imfuse(C(:,:,k),Vf(:,:,k),'Scaling','joint','ColorChannels',[1 2 0]);
end
P.(5){1,1}=X;
end