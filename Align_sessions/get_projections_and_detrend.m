function [Vid,p,R,opt]=get_projections_and_detrend(Vid,opt)
S = class(Vid);
if ~isempty(opt.Mask)
    Vid=cut_borders(Vid,opt.Mask);
else
    [Vid,opt.Mask]=remove_borders(Vid,0);
end
M=median(Vid,3);
Vf=get_Vf_vignetting_fixed(M,opt);
Vid=det_video(Vid,opt.sf,opt.n_enhanced,opt.gSig);
[~,Cn,PNR]=get_PNR_coor_greedy_PV(Vid,opt.gSig,[],[],opt.n_enhanced);
R=range(Vid,'all');
if strcmp(S,'uint8')
    Vid=v2uint8(Vid);
else
    Vid=v2uint16(Vid);
end
X=imfuse(mat2gray(Cn),Vf,'Scaling','joint','ColorChannels',[1 2 0]);
p={mat2gray(M),Vf,Cn,PNR,X};
p = array2table(p,'VariableNames',{'Mean','BloodVessels','Neurons','PNR','BV+Neurons'});
end

function  Vid=cut_borders(Vid,Mask)
f1=max(sum(Mask,1));
f2=max(sum(Mask,2));
Vid=reshape(Vid,size(Vid,1)*size(Vid,2),[]);
Vid(~Mask(:),:)=[];
Vid=reshape(Vid,f1,f2,[]);
end

function dt=det_video(in,sf,neuron_enhance,gSig)
[d1,d2,d3]=size(in);
dt = detrend_PV(sf/10,reshape(in,[d1*d2,d3]))*50;
dt=dt+single(randn(size(dt)));
dt=dt./GetSn(dt);
dt=reshape(dt,d1,d2,d3);
if neuron_enhance==1
    szad=gSig*2;
    dt=single(mat2gray(dt));
    Ydcln = dirt_clean(dt, szad, 1);
    Ydcln = Ydcln + dt;
    Yblur = anidenoise(Ydcln, round(szad),1,4,0.1429, 0.5,1);
    dt = bg_remove(Yblur, round(szad),1);
    dt=single(reshape(dt,[d1*d2,d3]));
    dt=dt./GetSn(dt);
    dt(isnan(dt))=0;
    dt(isinf(dt))=0;
    dt=reshape(dt,[d1,d2,d3]);
end 

for i=1:size(dt,3)
    dt(:,:,i) = medfilt2(dt(:,:,i));
end

% dt=video_threshold_CaliAli(dt,gSig);

end