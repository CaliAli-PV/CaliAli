function tiff_spliter(name)

% read tiff stack. Optional truncate to first T timesteps 

info = imfinfo(name);
T=numel(info);
d1 = info(1).Height;
d2 = info(1).Width;
x=round(linspace(0,T,round(T/6000)));


maxDigits = ceil(log10(numel(x) + 1)); 
formatSpec = sprintf('%%0%dd', maxDigits); 

strNumbers = strings(1, numel(x));  % Pre-allocate a string array

for i = 1:numel(x)
    strNumbers(i) = sprintf(formatSpec, i-1); 
end

for i=progress(1:numel(x)-1)
split(name,x(i)+1,x(i+1),info,strNumbers(i),d1,d2)
end

end

function split(name,t1,t2,info,id,d1,d2)

x=t1:t2;
Y = zeros(d1,d2,numel(x),'uint8');
for i = progress(1:numel(x))
    Y(:,:,i) = imread(name, x(i), 'Info',info);
end
out = extractBefore(name, ".");
out=[char(out),'_',char(id),'.mat'];
save(string(out),'Y','-v7.3', '-nocompression');
end