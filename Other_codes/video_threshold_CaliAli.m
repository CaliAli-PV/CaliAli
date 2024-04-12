function D=video_threshold_CaliAli(D,gSig)
[d1,d2,~]=size(D);
D=double(reshape(D,d1*d2,[]));
thr=prctile(D,(1-(gSig*9)^2/(d1*d2))*100,1);
D=D-thr;
D(D<0)=0;
D=D+randn(size(D))*0.2;
D=medfilt2(D,[1,3]);
D=D-median(D,2);
D=D./GetSn(D);
D=reshape(D,d1,d2,[]);
end