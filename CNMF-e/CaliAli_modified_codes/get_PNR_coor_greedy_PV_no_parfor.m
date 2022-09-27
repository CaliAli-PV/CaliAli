function [cn,pnr]=get_PNR_coor_greedy_PV_no_parfor(YH,F,Sn)
%% reshape data and convert to single
YH=single(YH);
[d1,d2,~]=size(YH);
YH=reshape(YH,d1*d2,[]);

%% calculate PNR for the whole vide
Y_max = max(movmedian(YH,10,2), [], 2);
pnr = reshape(double(Y_max)./Sn, d1, d2);
% pnr = reshape(Y_max, d1, d2);
YH(bsxfun(@lt, YH, Sn*3)) = 0;



max_bin=6000;
F=F';
le=[];
for i=1:length(F)
temp=F(i);
if temp>max_bin
    n=round(temp/max_bin)+1;
   temp=floor(diff(linspace(0,temp,n)));
   temp(end)=temp(end)+(F(i)-sum(temp));
end
le=cat(2,le,temp);
end
le=[0,cumsum(le)];

cn_all=zeros(d1,d2,size(le,2)-1,'single');


for i=1:size(le,2)-1
    cn_all(:,:,i) = correlation_image(YH(:,le(i)+1:le(i+1)), 8, d1,d2);
end

cn=max(cn_all,[],3);
