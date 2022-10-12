function out=v2uint8(in,thr)

in=double(in); 
if exist('thr','var')
in(in<thr(1))=thr(1);
in(in>thr(2))=thr(2);
end

in=(in-min(in,[],'all'))./range(in,'all');
out=uint8(in*2^8);