function out=tiff_reader_fast(fullFileName)
os = computer;
if strcmp(os, 'PCWIN64') || strcmp(os, 'PCWIN32') % Check for Windows (64-bit or 32-bit)
    out=ScanImageTiffReader(char(fullFileName));  %
    out=v2uint8(out.data());
    out=permute(out,[2,1,3]);
else
    out=parallelReadTiff(fullFileName);
end
