function S2=align_shapes_scout_pv(S1,S2)
%% Scale components
S1.a=S1.a./max(S1.a,[],1);
S1.a=reshape(S1.a,S1.d(1),S1.d(2),[]);

S2.a=S2.a./max(S2.a,[],1);
S2.a=reshape(S2.a,S2.d(1),S2.d(2),[]);

temp=catpad(3,S1.a,S2.a);
S2.a=temp(:,:,size(S1.a,3)+1:end);
S2.a(isnan(S2.a))=0;
%% Align by translation
X=cat(3,mat2gray(max(S1.a,[],3)),mat2gray(max(S2.a,[],3)));

[s1,s2,~] = size(X);bound1=s1/10;bound2=s2/10;

options_r = NoRMCorreSetParms('d1',s1-bound1,'init_batch',1,...
    'd2',s2-bound2,'bin_width',2,'max_shift',[500,500,500],...
    'iter',1,'correct_bidir',false,'shifts_method','fft','boundary','NaN');
X=X(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:);
[temp,shifts,~] = normcorre_batch(X,options_r,X(:,:,1));

for i=1:size(shifts,1)
T(i,:)=flip(squeeze(shifts(i).shifts)');
end

S2.a=imtranslate(S2.a,T(2,:)); 
X=cat(3,mat2gray(max(S1.a,[],3)),mat2gray(max(S2.a,[],3)));

%% non rigid_alignment
opt = struct('niter',300, 'sigma_fluid',2,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0,'stop_criterium',0.002);

[Mp,D]=register(v2uint8(X(:,:,1)),v2uint8(X(:,:,2)),opt);
S2.Al=cat(3,v2uint8(X(:,:,1)),Mp,v2uint8(X(:,:,2)));
% implay();
S2.a=reshape(apply_shifts_in({S2.a},D),S1.d(1)*S1.d(2),[]);
S2.a(isnan(S2.a))=0;

end


function out=apply_shifts_in(Vid,shifts);
for k=1:size(Vid,2)
    temp_v=Vid{1,k};
    temp_s=shifts(:,:,:,k);
    parfor i=1:size(temp_v,3)
        temp_v(:,:,i)=imwarp(temp_v(:,:,i),temp_s,'FillValues',0);
    end   
    Vid{1,k}=temp_v;
end
out=cat(3,Vid{:});

end
