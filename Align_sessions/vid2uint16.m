function Vid=vid2uint16(Vid)

mi=min(cellfun(@(x) min(x,[],'all'),Vid));
rang=max(cellfun(@(x) max(x,[],'all'),Vid))-mi;

for i=1:size(Vid,2)
    temp=Vid{1,i};
    temp=(temp-mi)./rang;
    Vid{1,i}=uint16(temp*(2^16-1))+1;   % min value is 1. 0 is for nans
end