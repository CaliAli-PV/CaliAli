function A_out=filter_vessel_spatial(A_in,CaliAli_options)
[d1,d2,~]=size(A_in);
w=dendrite_bg_removal(A_in,CaliAli_options);
A_out=reshape(A_in.*(w>0.01),d1*d2,[]);
