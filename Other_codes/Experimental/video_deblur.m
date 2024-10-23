function V=video_deblur(V)
V=double(V);
INITPSF = ones(4,'single');
taperedImage = edgetaper(double(V(:,:,1)),INITPSF);
[~,P] = deconvblind(taperedImage,INITPSF,15,.01);
parfor i=1:size(V,3)
taperedImage = edgetaper(V(:,:,i),P);
V(:,:,i) = deconvlucy(taperedImage,P);
end
V=v2uint16(V);
