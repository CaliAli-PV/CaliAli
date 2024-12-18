
function out=get_BS_neuron_enhance(V,BV,opt)


Neu=det_video(V,opt);
Neu=v2uint8(Neu);
BV=v2uint8(BV); 
out=cat(4,Neu,BV,BV);
out=permute(out,[1,2,4,3]);

end

function dt=det_video(in,opt)
gSig=opt.gSig;
    szad=gSig*2;
    dt=single(mat2gray(in));
    Ydcln = dirt_clean(dt, szad, 1);
    Ydcln = Ydcln + dt;
    Yblur = anidenoise(Ydcln, round(szad),1,4,0.1429, 0.5,1);
    dt = bg_remove(Yblur, round(szad),1);
    dt = noise_suppress(dt,opt.sf,1);
end 


