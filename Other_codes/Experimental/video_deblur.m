function V=video_deblur(V)
V=mat2gray(V);
INITPSF = ones(4,'single');
taperedImage = edgetaper(mat2gray(V(:,:,1)),INITPSF);
[temp,P] = deconvblind(taperedImage,INITPSF,20,.1);
parfor i=1:size(V,3)
taperedImage = edgetaper(V(:,:,i),P);
V(:,:,i) = deconvlucy(taperedImage,P);
end
V=v2uint16(V);
