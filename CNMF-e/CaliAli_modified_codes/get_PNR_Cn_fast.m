function [Cn,PNR]=get_PNR_Cn_fast(Y)
PNR=max(Y,[],3);
% Cn=gather(correlation_image_large(mat2gray(den),ones(12,1), d1,d2,[],[]));
PNR=single(50*mat2gray(regionfill(PNR,PNR>prctile(PNR,99.99,'all'))));
Cn = mat2gray(locallapfilt(v2uint16(PNR),0.3,0.2));
Cn=mat2gray(adjust_correlation_image(Cn));
end
