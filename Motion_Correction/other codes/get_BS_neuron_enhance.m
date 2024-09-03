
function out=get_BS_neuron_enhance(V,VF,opt)


Neu=det_video(V,opt.sf,opt.n_enhanced  ,opt.gSig);

VF=vesselness_PV(V,1,linspace(opt.BVz(1),opt.BVz(2),5));
VF=v2uint8(VF);
Neu=v2uint8(Neu);
 
out=cat(4,Neu,VF,VF);
out=permute(out,[1,2,4,3]);

end

function dt=det_video(in,sf,neuron_enhance,gSig)
[d1,d2,d3]=size(in);
dt = detrend_PV(sf/10,reshape(in,[d1*d2,d3]))*50;
dt=dt+single(randn(size(dt))); %This is to ensure that we dont divide by 0. could happen if defective pixels were not fixed before
dt=dt./GetSn(dt);
dt=reshape(dt,d1,d2,d3);
if neuron_enhance==1
    szad=gSig*2;
    dt=single(mat2gray(dt));
    Ydcln = dirt_clean(dt, szad, 1);
    Ydcln = Ydcln + dt;
    Yblur = anidenoise(Ydcln, round(szad),1,4,0.1429, 0.5,1);
    dt = bg_remove(Yblur, round(szad),1);
end 

end

