function out=tiff_reader_fast(fullFileName)

out=ScanImageTiffReader(char(fullFileName));  %
out=out.data();