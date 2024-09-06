function out=get_matched_projection(in)
ref=in(:,:,round(size(in,3)/2));

for i=1:size(in,3)
    J = localHistMatch(mat2gray(ref), mat2gray(in(:,:,i)), [100,100], [50,50],0.001);
    A=mat2gray(in(:,:,i));
    k=mat2gray(imgaussfilt(medfilt2(mat2gray(histeq(A.*J)).*mat2gray(ref),[4,4])));
    out(:,:,:,i)=cat(3,max(cat(3,A,k),[],3),max(cat(3,J,k),[],3),J*0);
end


