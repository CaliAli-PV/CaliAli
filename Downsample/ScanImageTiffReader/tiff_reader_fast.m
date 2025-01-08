function out=tiff_reader_fast(fullFileName)
os = computer;
if strcmp(os, 'PCWIN64') || strcmp(os, 'PCWIN32') % Check for Windows (64-bit or 32-bit)
    out=ScanImageTiffReader(char(fullFileName));  %
    out=out.data();
else
    out=parallelReadTiff(fullFileName);
end
