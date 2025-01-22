function [Cn,PNR]=get_PNR_Cn_dendrite(Y,CaliAli_options)
PNR=max(Y,[],3);
% Cn=gather(correlation_image_large(mat2gray(den),ones(12,1), d1,d2,[],[]));
PNR=single(regionfill(PNR,PNR>prctile(PNR,99.99,'all')));
Cn=dendrite_bg_removal(PNR,CaliAli_options).*max(PNR,[],'all');
