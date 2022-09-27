function [P,T,Mask]=sessions_translate(P)
Vf=cell2mat(P{1,2});
Vf=mat2gray(Vf);
[s1,s2,~] = size(Vf);bound1=s1/5;bound2=s2/5;

options_r = NoRMCorreSetParms('d1',s1-bound1,'init_batch',1,...
    'd2',s2-bound2,'bin_width',2,'max_shift',[1000,1000,1000],...
    'iter',5,'correct_bidir',false,'shifts_method','fft','boundary','NaN');

[~,shifts,~] = normcorre_batch(Vf(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:),options_r);

%% Apply shifts to projections
for i=1:size(P,2)
temp = apply_shifts(cell2mat(P{1,i}),shifts,options_r);
[temp,Mask]=remove_borders(temp);
P{1,i}={temp};
end

for i=1:size(shifts,1)
T(i,:)=flip(squeeze(shifts(i).shifts)');
end



