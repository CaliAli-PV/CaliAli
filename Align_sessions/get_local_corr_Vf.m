function mc=get_local_corr_Vf(Vf,M)

[d1,d2,d3]=size(Vf);
M=mean(M,3);
b=nchoosek(1:d3,2);

for i=1:size(b,1)
    im1=Vf(:,:,b(i,1));
    im2=Vf(:,:,b(i,2));
    im1=im1+randn(d1,d2)/1000;
    im2=im2+randn(d1,d2)/1000;
    im1 = imhistmatch(im1,max(cat(3,im1,im2),[],3));
    im2 = imhistmatch(im2,max(cat(3,im1,im2),[],3));
    sz=25;
    [~,out]=ssim(im1,im2,'Exponents',[0 0 1],'Radius',sz,'RegularizationConstants',[0,0,0]);
    S(:,b(i,1),b(i,2))=out(:);
end

parfor i=1:size(S,1)
    v=squeeze(S(i,:,:));
    v=[v;zeros(1,size(v,2))];
    v=v+v'+eye(size(v,1));
    mc(i)=get_min_conn(v);
end
mc=reshape(mc,[d1,d2]);

m=mean(M,2)*mean(M,1);
m=sqrt(m./max(m,[],'all'));
mc=m.*mc;


end



function out=get_min_conn(v)
d2=size(v,2);
t=linspace(0.1,1,100);
for i=1:100
    G = graph(v>t(i));
    A= conncomp(G);
    s(i)=length(find(histc(A(:), min(A(:)):max(A(:)))==1) + min(A(:))-1);
    if s(i)>0
        break
    end
end
out=t(i);
end

