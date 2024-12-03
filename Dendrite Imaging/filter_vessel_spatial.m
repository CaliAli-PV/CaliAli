function A_out=filter_vessel_spatial(A_in,nr,nc)


w = VerticalVesselness2D(reshape(full(A_in),nr,nc,[]),0.5:0.1:0.8, [1;1], 0.3,true,0);
I=w>0.02;
[d1,d2,~]=size(w);
for i=1:size(I,3)
    try
 I=mat2gray(w(:,:,i));
CC = bwconncomp(I);
[~,component_idx] = max(cellfun(@(c) numel(c), CC.PixelIdxList));
mask = false(d1,d2);
mask (CC.PixelIdxList{component_idx}) = true;
w(:,:,i)=w(:,:,i).*mask;
    catch
    end
end
A_out=reshape(w,nr*nc,[]);