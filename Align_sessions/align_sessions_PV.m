function align_sessions_PV(sf,gSig,theFiles)
% align_sessions_PV(10);
if ~exist('gSig','var')
    gSig = 2.5;
end

if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end

[filepath,name]=fileparts(theFiles{end});
out=strcat(filepath,'\',name,'_Aligned','.h5');
if ~isfile(out)
    %% load all video files
    [Vid,P1,F]=load_data(theFiles,sf,gSig);
    %%
%     P1=adjust_projections(P0);
    fprintf(1, 'Aligning video by translation ...\n');
    [Vid,P2]=apply_translations(Vid,P1);
    %%
    fprintf(1, 'Calculating non-rigid aligments...\n');
    [shifts,P3,~]=get_shifts_alignment(P2);
    P=table(P1,P2,P3,'VariableNames',{'Original','Translations','Trans + Non-Rigid'});
    P=BV_gray2RGB(P);

    %% Apply Shifts
    fprintf(1, 'Applying shifts to video...\n');
    Mr=apply_shifts_PV(Vid,shifts);   
    Mr=remove_borders(Mr,1);
    % Convert to original resolution
    if isa(Vid{1},'uint8')
        Mr=v2uint8(Mr);
    end
    %% get alignment score

    v=P.(3)(1,:).(2){1,1};
    m=P.(3)(1,:).(1){1,1}; 

    Scor=get_blood_vessel_corr_score(v);
    Loc_Scor=get_local_corr_Vf(v,m);

    fprintf(1, 'Blood-vessel similarity score: %1.3f \n',Scor);

    if Scor<0.4
    fprintf(1, 'Blood-vessel similarity score is too low! \n Results may not be accurate! \n ');
    end
    
    %% save Aligned video;
    fprintf(1, 'Saving Aligned Video...\n');
    saveash5(Mr,out);
    out_mat=strcat(filepath,'\',name,'_Aligned.mat');
    Cn=max(P3.Coor{1,1},[],3);
    PNR=max(P3.PNR{1,1},[],3);
    
    if ~isfile(out_mat)
        save(out_mat,'P','Scor','Loc_Scor','Cn','PNR','F');
    else
        save(out_mat,'P','Scor','Loc_Scor','Cn','PNR','F','-append');
    end    
    
else
    fprintf(1, 'Video file was already aligned...\n');
end
% [d1,d2,d3]=size(P.(3)(1,:).(2){1,1});
% v=reshape(P.(3)(1,:).(2){1,1},d1,d2,1,d3);
% c=reshape(P.(3)(1,:).(3){1,1},d1,d2,1,d3);
% V=cat(3,c.*0.6,v,zeros(d1,d2,1,d3));

end
%%
%%=============================================
% Functions
%%=============================================
%%

function dt=det_video(in,sf)
[d1,d2,d3]=size(in);
dt = detrend_PV(sf,reshape(in,[d1*d2,d3]));
dt=dt./GetSn(dt);
dt=reshape(dt,d1,d2,d3);

end
%%
%%=============================================
function [Vid,P,F]=load_data(theFiles,sf,gSig)
upd = textprogressbar(size(theFiles,2),'startmsg','Loading files into memory');
for i=1:size(theFiles,2)
    fullFileName = theFiles{i};
    Vid{i}=h5read(fullFileName,'/Object');
    F(i)=size(Vid{i},3);
    [~,Mask(:,:,i)]=remove_borders(Vid{i},0);
    upd(i);
end

[~,Mask]=remove_borders(double(Mask),0);

f1=max(sum(Mask,1));
f2=max(sum(Mask,2));

upd = textprogressbar(size(Vid,2)*2,'startmsg','Calculating projections');
k=0;
for i=1:size(Vid,2)
    temp=Vid{i};
    temp=reshape(temp,size(temp,1)*size(temp,2),[]);
    temp(~Mask(:),:)=[];
    temp=reshape(temp,f1,f2,[]);
    M(:,:,i)=median(temp,3);
    Vf(:,:,i)=adapthisteq(vesselness_PV(M(:,:,i),0,(0.6:0.032:0.9).*gSig),'Distribution','exponential');
    temp=det_video(temp,sf);
    k=k+1;
    upd(k);
    [~,Cn(:,:,i),pnr(:,:,i)]=get_PNR_coor_greedy_PV(temp,gSig);
    Vid{i}=temp;
    k=k+1;
    upd(k);
end
Vid=vid2uint16(Vid);
Vf=mat2gray(Vf);
M=mat2gray(M);
Cn=mat2gray(Cn);
for i=1:size(Vid,2)
        X(:,:,i)=mat2gray(max(cat(3,Vf(:,:,i),medfilt2(Cn(:,:,i))),[],3));
end

P={M,Vf,Cn,pnr,X};
P = array2table(P,'VariableNames',{'Mean','Vessel','Coor','PNR','Vess+Coor'});
end

function P=BV_gray2RGB(P)

X=uint8([]);

for i=1:size(P,2)
    C=P.(i)(1,:).(3){1,1};
    Vf=P.(i)(1,:).(2){1,1};
    for k=1:size(C,3)
        X(:,:,:,k)=imfuse(C(:,:,k),Vf(:,:,k),'Scaling','joint','ColorChannels',[1 2 0]);
    end
    P.(i)(1,:).(5){1,1}=X;
    X=uint8([]);
end

end
