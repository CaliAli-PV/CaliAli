function out=get_BS_neuron_enhance(V,opt)
szad=round(opt.gSig*3);
tmp=single(mat2gray(V));
Ydcln = dirt_clean(tmp, szad, 1);
            Ydcln = Ydcln + tmp;
Yblur = anidenoise(Ydcln, szad,1,4,0.1429, 0.5,1);
reg = bg_remove(Yblur, szad,1); 

VF=vesselness_PV(V,1,linspace(opt.BVz(1),opt.BVz(2),5));
VF=v2uint8(VF);
reg=v2uint8(reg);
 
out=cat(4,reg,VF,VF);
out=permute(out,[1,2,4,3]);