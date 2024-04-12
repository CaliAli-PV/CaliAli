function P=BV_gray2RGB(P)
X=uint8([]);
for i=1:size(P,2)
    Cn=P.(i)(1,:).(3){1,1}  ;
    PNR=P.(i)(1,:).(4){1,1}  ;
    C=v2uint8(mat2gray(PNR).*mat2gray(Cn).^2);
    for s=1:size(C,3)
        C(:,:,s)=adapthisteq(C(:,:,s));
    end
    Vf=v2uint8(P.(i).(2){1,1});
    for k=1:size(C,3)
        X(:,:,:,k)=imfuse(C(:,:,k),Vf(:,:,k),'Scaling','joint','ColorChannels',[1 2 0]);
    end
    P.(i).(5){1,1}=X;
    X=uint8([]);
end

end