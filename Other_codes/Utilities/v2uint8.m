function out=v2uint8(in,thr)

bytesPersingle= 4; % Double precision uses 8 bytes per element
requiredMemory = numel(in) * bytesPersingle; % Memory needed for double array

[~, sys] = memory; % Get system memory information
availableMemory = sys.PhysicalMemory.Available; % Available physical memory

if requiredMemory <= availableMemory
    in=single(in);
    if exist('thr','var')
        in(in<thr(1))=thr(1);
        in(in>thr(2))=thr(2);
    end

    in=(in-min(in,[],'all'))./range(in,'all');
    out=uint8(in*2^8);

else
    x=round(linspace(0,size(in,3),round(size(in,3)./10000)+1));
    for i=1:numel(x)-1
        temp=single(in(:,:,x(i)+1:x(i+1)));
        if exist('thr','var')
            in(in<thr(1))=thr(1);
            in(in>thr(2))=thr(2);
        end

        temp=(temp-min(temp,[],'all'))./range(temp,'all');
        out{i}=uint8(temp*2^8);
    end

    out=cat(3,out{:});
end