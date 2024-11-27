function [P,T,Mask]=sessions_translate(P,opt)

if contains(opt.projections,'BV')
    ref=cell2mat(P{1,2}); % Blood vessels
else
    ref=cell2mat(P{1,3}); % Neurons
end

ref=mat2gray(ref);
[s1,s2,~] = size(ref);bound1=20;bound2=20;

options_r = NoRMCorreSetParms('d1',s1-bound1,'init_batch',1,...
    'd2',s2-bound2,'bin_width',2,'max_shift',[1000,1000,1000],...
    'iter',5,'correct_bidir',false,'shifts_method','fft','boundary','NaN');

[M,shifts,~] = normcorre_batch(ref(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:),options_r);
%% use center as reference:

C1=mean([shifts(:).shifts],2);
C2=mean([shifts(:).shifts_up],2);
for i=1:size(shifts,1)
    shifts(i).shifts=shifts(i).shifts-C1;
    shifts(i).shifts_up=shifts(i).shifts_up-C2;
end

%% Apply shifts to projections
for i=1:size(P,2)-1
temp = apply_shifts(cell2mat(P{1,i}),shifts,options_r);
[temp,Mask]=remove_borders(temp);
P{1,i}={temp};
end
P=scale_Cn(P);

for i=1:size(shifts,1)
T(i,:)=flip(squeeze(shifts(i).shifts)');
end
end

function P=scale_Cn(P)
C=v2uint8(mat2gray(P.(3){1,1}));
ref=v2uint8(P.(2){1,1});
for k=1:size(C,3)
    X(:,:,:,k)=imfuse(C(:,:,k),ref(:,:,k),'Scaling','joint','ColorChannels',[1 2 0]);
end
P.(5){1,1}=X;
end



