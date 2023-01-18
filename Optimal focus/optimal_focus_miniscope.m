function optimal_focus_miniscope()


F_ref = uipickfiles('REFilter','\.avi$','Prompt','Choose reference video','NumFiles',1);
F_focus = uipickfiles('REFilter','\.avi$','Prompt','Choose focus mini videos IN ASCENDING ORDER!!!');

M_ref=get_reference_frame(F_ref);
M=get_focus_sample(F_focus );

%% get VB of different focus
for i=1:size(M,3)
    Vf(:,:,i)=adapthisteq(vesselness_PV(M(:,:,i),0,(0.6:0.032:0.9).*2.5),'Distribution','exponential');
end

%% get reference VB
Vf_ref=adapthisteq(vesselness_PV(M_ref,0,(0.6:0.032:0.9).*2.5),'Distribution','exponential');

[out,C_out]=translate_BV(Vf_ref,Vf);

figure;
montage(out);
figure;
bar(C_out)
[mp,I]=max(C_out);
if mp<0.45
fprintf(1, 'WARNING!!:Maximum BV correlation of %1.3f is too low!! Alignmnet will not be possible\n',mp);
else
fprintf(1, 'Maximum BV correlation (%1.3f) is suitable to track neurons!\n',mp);
end

fprintf(1, 'Optimal focus is #%1.0f!!\n',I);

[filepath,name,ext]=fileparts(F_focus{1, 1});
t=datetime;
t.Format='yyMMdd_HHmmss';
t=char(t);

save([filepath,'\Focus_',t,'.mat'],'F_focus','F_ref','out','C_out');

end



function [q,C_out]=translate_BV(Vf_ref,Vf);

[s1,s2,~] = size(Vf);

[Vft,Vf_reft]=equalize_size(Vf_ref,Vf);

options_r = NoRMCorreSetParms('d1',s1,'init_batch',1,...
    'd2',s2,'max_shift',[1000,1000,1000],...
    'iter',5,'correct_bidir',false,'shifts_method','fft','boundary','NaN','upd_template',false);

[~,T,~] = normcorre_batch(Vft,options_r,Vf_reft);


for i=1:size(Vf,3)
    Vf_out(:,:,i)=imtranslate(Vf(:,:,i),flip(squeeze(T(1).shifts)'),'OutputView','full');
end

[Vf_out,~]=equalize_size(Vf_ref,Vf_out);

opt = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
 t1=mat2gray(Vf_ref);
for i=progress(1:size(Vf_out,3))
  [~,temp,~]=MR_Log_demon(repmat(Vf_ref,[1,1,3]),repmat(Vf_out(:,:,i),[1,1,3]),opt);
  temp=mat2gray(temp(:,:,1));
  out(:,:,i)=temp;
  C_out(i)=corr(t1(:)-mean(t1,'all'),temp(:)-mean(temp,'all'));
end

for i=1:11
    q(:,:,:,i)=cat(3,out(:,:,i),Vf_ref,zeros(size(Vf_out(:,:,i))));
end


end

function [Vf,Vf_ref]=equalize_size(Vf_ref,Vf)
temp=remove_borders(catpad(3,Vf_ref,Vf));
Vf_ref=temp(:,:,1);
Vf=temp(:,:,2:end);
end



function M=get_reference_frame(theFiles)

if ~exist('ds_f','var')
    ds_f = 2;
end
fullFileName = theFiles{1};
fprintf(1, 'Now reading %s\n', fullFileName);
temp=load_avi(fullFileName,100); % load only 100

for i=progress(1:size(temp,3))
    V(:,:,i)=imresize(temp(:,:,i),1/ds_f,'bilinear');
end

[V,~]=motion_correct_PV(V+1); %% Rigid MC
Mr=interpolate_dropped_frames(V);
Mr=remove_borders(Mr,0);
M=mean(v2uint8(Mr),3);
end



function M=get_focus_sample(theFiles)
if ~exist('ds_f','var')
    ds_f = 2;
end


for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    temp=load_avi(fullFileName);
    t=[];
    t=uint8(t);
    for i=progress(1:size(temp,3))
        t(:,:,i)=imresize(temp(:,:,i),1/ds_f,'bilinear');
    end

    [V,~]=motion_correct_PV(t+1); %% Rigid MC
    Mr=interpolate_dropped_frames(V);
    M(:,:,k)=mean(Mr,3);
end
    M=v2uint8(remove_borders(M,0));
end

















