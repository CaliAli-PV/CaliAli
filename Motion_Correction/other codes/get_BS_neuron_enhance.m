function out=get_BS_neuron_enhance(V,VF,opt)
szad=round(opt.gSig);
tmp=single(mat2gray(V));
Ydcln = dirt_clean(tmp, szad, 1);
            Ydcln = Ydcln + tmp;

Yblur = anidenoise(Ydcln, szad,opt.use_parallel,4,0.1429, 0.5,1);
reg = bg_remove(Yblur, szad,1); 

VF=v2uint8(VF);
reg=v2uint8(reg);
 
out=cat(4,reg,reg,VF);
out=permute(out,[1,2,4,3]);