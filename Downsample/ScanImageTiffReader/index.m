%% ScanImageTiffReader for Matlab
%
% This is a Matlab package for extracting data from
% <https://en.wikipedia.org/wiki/Tagged_Image_File_Format Tiff> and
% <http://bigtiff.org/ BigTiff> files recorded using
% <http://scanimage.org ScanImage>.  It is a very fast tiff reader and provides
% access to ScanImage-specific metadata.  It should read most tiff files, but as
% of now we don't support compressed or tiled data.  It is also available as a
% <https://vidriotech.gitlab.io/scanimagetiffreader-julia/ Julia>,
% <https://vidriotech.gitlab.io/scanimagetiffreader-python/ Python>,  or 
% <https://vidriotech.gitlab.io/scanimage-tiff-reader C library>.  There's also a
% <https://vidriotech.gitlab.io/scanimage-tiff-reader command line interface>.
%
% Both <http://scanimage.org ScanImage> and this reader are products of 
% <https://vidriotechnologies.com/ Vidrio Technologies>.  If you have
% questions or need support feel free to <https://gitlab.com/vidriotech/scanimagetiffreader-matlab/issues submit an issue>
% <https://vidriotechnologies.com/contact-support contact us>. 
%
%%% Downloads
% Packages includes mex files built against 64-bit Matlab 2016b (v9.1)
% and targeting Windows, Linux, and OS X. 
%
% <html>
% <table>
%   <tr><td><b>Target</b></td><td></td><td><b>Version</b></td></td>
%   <tr><td>Windows x64</td><td><a href="https://gitlab.com/api/v4/projects/8668010/jobs/artifacts/master/download?job=build_windows">Download</a></td><td>v1.3</td></tr>
%   <tr><td>OS X/Linux</td><td>Please contact support@mbfbioscience.com with your request!</td><td>v1.3</td></tr>
% </table>
% </html>
%
%%% Installation
%
% # Download the build for your operating system.
% # Unzip it.
% # Copy the |+ScanImageTiffReader| folder to a location on your Matlab path.
%
%% Examples
% Import the reader class.  A constructed reader represents an open file.
import ScanImageTiffReader.ScanImageTiffReader;
%% 
% *Read a stack*
%
% Note that Matlab's ordering of dimensions means the image might be 
% transposed from what you expect.  We leave the transpose up to you.
reader=ScanImageTiffReader('./hostpixelcorr_noavg_00001_00001.tif');
vol=reader.data();
imshow(vol(:,:,floor(size(vol,3)/2)),[]);
%% 
% *Query the api version.*  
%
% This is useful to know when you need to ask for support. 
ScanImageTiffReader.apiVersion()
%% 
% *Get some metadata!*
meta=reader.metadata();
desc=reader.descriptions();
%%
% *Per-file metadata*
disp(meta(1:1000));
%%
% *Per-frame metadata*
disp(desc{1});
%% Testing
% Tests may need to be modified to point to a file you are interested in.
% The included tests are very minimal.
%
% See |+ScanImageTiffReader/ScanImageTiffReaderTests.m|
% runtests ScanImageTiffReader
