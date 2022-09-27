function out=v2uint8(in,thr)
if ~exist('thr','var')
    thr=[0 1];
end

in=double(in); 
in=(in-min(in,[],'all'))./range(in,'all');

in(in<thr(1))=thr(1);
in=((in-min(in,[],'all'))./range(in,'all'))*thr(2);
out=uint8(in*2^8);