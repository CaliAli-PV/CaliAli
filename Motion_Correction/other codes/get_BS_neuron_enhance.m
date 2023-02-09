function out=get_BS_neuron_enhance(V)
szad=5;
tmp=single(mat2gray(V));
Ydcln = dirt_clean(tmp, szad, 1);
            Ydcln = Ydcln + tmp;
Yblur = anidenoise(Ydcln, szad,1,4,0.1429, 0.5,1);
reg = bg_remove(Yblur, szad,1); 

VF=vesselness_PV(V,1,0.5:0.5:2);
VF=v2uint8(VF);
reg=v2uint8(reg);
 
out=cat(4,reg,reg,VF);
out=permute(out,[1,2,4,3]);