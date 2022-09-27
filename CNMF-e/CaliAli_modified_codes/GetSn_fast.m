function fsn=GetSn_fast(data,win,rep,d1,d2)

x=round(linspace(1,size(data,2),rep+1));
s=[];
for i=1:length(x)-1
    temp=data(:,x(i):x(i)+win);
    s=[s,temp];
end


sn = GetSn(s);

fsn = medfilt2(reshape(sn,d1,d2), [5 5],'symmetric');
fsn=fsn(:);
end
