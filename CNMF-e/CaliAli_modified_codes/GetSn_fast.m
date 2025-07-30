function sn=GetSn_fast(data,win,d1,d2)


rep=min([round(size(data,2)/win),10]);

x=round(linspace(1,size(data,2),rep+1));
ix=zeros(1,size(data,2));
ix(x(1:end-1))=1;
ix=movmax(ix,[win-1,0]);
data=data(:,ix==1);

sn = GetSn(data);
sn = reshape(sn,d1,d2);
sn = medfilt2(sn,[5,5],'symmetric');
sn = sn(:);
end
