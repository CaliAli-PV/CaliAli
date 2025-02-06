
function out=get_BS_neuron_enhance(V,BV,opt)

if opt.

Neu=det_video(V,opt);
Neu=v2uint8(Neu);
BV=v2uint8(BV); 
out=cat(4,Neu,BV,BV);
out=permute(out,[1,2,4,3]);

end












