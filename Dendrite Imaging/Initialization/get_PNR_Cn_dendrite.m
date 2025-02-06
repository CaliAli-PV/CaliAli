function [Cn,PNR]=get_PNR_Cn_dendrite(Y,CaliAli_options,mask)

[d1,d2,d3]=size(Y);
if ~exist('mask','var')
    mask=ones(d1,d2);
end


PNR=max(Y,[],3);
% Cn=gather(correlation_image_large(mat2gray(den),ones(12,1), d1,d2,[],[]));
PNR=single(regionfill(PNR,PNR>prctile(PNR,99.99,'all')));
Cn=dendrite_bg_removal(PNR,CaliAli_options).*max(PNR,[],'all');

PNR(~mask)=0;
Cn(~mask)=0;

