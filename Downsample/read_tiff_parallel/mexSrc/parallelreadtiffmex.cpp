#include <cstdint>
#include <cstring>
#include "mex.h"
#include "tiffio.h"
#include "../src/helperfunctions.h"
#include "../src/parallelreadtiff.h"


/**
 * @brief MATLAB MEX entry point for reading TIFF image files.
 *
 * This function serves as the interface between MATLAB and the TIFF file reading routines.
 * It validates inputs, extracts the filename from the first input argument, opens the TIFF file,
 * and reads the image data into a MATLAB numeric array compatible with different bit depths (8, 16, 32, or 64 bits).
 * The function supports both standard TIFF files and ImageJ formatted files. For files with a single input argument,
 * the number of image slices (z-dimension) is determined by calling getImageSizeZ. When two input arguments are provided,
 * the second argument specifies a slice range [start, end], and the function verifies that this range is within bounds.
 *
 * The function performs the following operations:
 * - Validates that the number of input arguments is either 1 or 2.
 * - Checks that the first argument is either a MATLAB string or a character array, converting it to a C-style string.
 * - On non-Windows systems, expands the tilde character in the filename if present.
 * - Opens the TIFF file using TIFFOpen, retrieves image width (x) and height (y) using TIFFGetField, and extracts
 *   the bits per sample (bit depth) and rows per strip.
 * - Determines the number of image slices (z):
 *   - If only one argument is provided, calls getImageSizeZ to get the slice count.
 *   - If a second argument is provided, interprets it as a range, validates that it contains exactly two elements,
 *     and calculates the starting slice and the total number of slices.
 * - Checks for ImageJ compatibility and adjusts the slice count if the file conforms to ImageJ specifications.
 * - Allocates the MATLAB output array using mxCreateNumericArray based on the determined dimensions and bit depth.
 * - Reads the TIFF image data using one of the following functions:
 *   - readTiffParallelImageJ for ImageJ formatted data,
 *   - readTiffParallel2D for 2D images,
 *   - readTiffParallel for 3D images.
 * - Reports errors via mexErrMsgIdAndTxt if any of the validation checks fail or if an error occurs during reading.
 *
 * @param nlhs Number of expected output mxArray pointers.
 * @param plhs Array of pointers to the output mxArray; the first element is set to the numeric array containing the image data.
 * @param nrhs Number of input mxArray pointers, which must be either 1 or 2.
 * @param prhs Array of pointers to the input mxArray; the first element must be the filename (string or char array),
 *             while the optional second element, if provided, specifies a two-element range for slice selection.
 *
 * @exception Throws an error if:
 *             - The number of input arguments is not 1 or 2.
 *             - The first argument is neither a string nor a character array.
 *             - The TIFF file cannot be opened.
 *             - The provided slice range does not consist of exactly two elements or is out of bounds.
 *             - An unsupported bit depth is encountered.
 *             - An error is encountered during the image read operation.
 *
 * @see TIFFOpen
 * @see mxCreateNumericArray
 * @see getImageSizeZ
 * @see readTiffParallelImageJ
 * @see readTiffParallel2D
 * @see readTiffParallel
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    if(nrhs < 1 || nrhs > 2) mexErrMsgIdAndTxt("tiff:inputError","This function takes one or two arguments only");
    // Check if the fileName is a char array or matlab style
    char* fileName = NULL;
    if(!mxIsClass(prhs[0], "string")){
        if(!mxIsChar(prhs[0])) mexErrMsgIdAndTxt("tiff:inputError","The first argument must be a string");
        fileName = mxArrayToString(prhs[0]);
    }
    else{ 
        mxArray* mString[1];
        mxArray* mCharA[1];

        // Convert string to char array
        mString[0] = mxDuplicateArray(prhs[0]);
        mexCallMATLAB(1, mCharA, 1, mString, "char");
        fileName = mxArrayToString(mCharA[0]);
    }

    // Handle the tilde character in filenames on Linux/Mac
    #ifndef _WIN32
    if(strchr(fileName,'~')) fileName = expandTilde(fileName);
    #endif

    uint8_t flipXY = 1;
    //uint8_t flipXY = 0;


    //if(nrhs > 2){
    //    flipXY = (uint8_t)*(mxGetPr(prhs[2]));
    //}


    TIFFSetWarningHandler(DummyHandler);
    TIFF* tif = TIFFOpen(fileName, "r");
    if(!tif) mexErrMsgIdAndTxt("tiff:inputError","File \"%s\" cannot be opened",fileName);

    uint64_t x = 1,y = 1,z = 1,bits = 1, startSlice = 0;
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &x);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &y);

    if(nrhs == 1){
        z = getImageSizeZ(fileName);
    }
    else{
        if(mxGetN(prhs[1]) != 2){
            mexErrMsgIdAndTxt("tiff:inputError","Input range is not 2");
        }
        else{
            startSlice = (uint64_t)*(mxGetPr(prhs[1]))-1;
            z = (uint64_t)*((mxGetPr(prhs[1])+1))-startSlice;
            if (!TIFFSetDirectory(tif,startSlice+z-1) || !TIFFSetDirectory(tif,startSlice)){
                mexErrMsgIdAndTxt("tiff:rangeOutOfBound","Range is out of bounds");
            }
        }
    }

    TIFFGetField(tif, TIFFTAG_BITSPERSAMPLE, &bits);
    uint64_t stripSize = 1;
    TIFFGetField(tif, TIFFTAG_ROWSPERSTRIP, &stripSize);
    TIFFClose(tif);

    uint8_t imageJIm = 0;
    if(isImageJIm(fileName)){
        imageJIm = 1;
        uint64_t tempZ = imageJImGetZ(fileName);
        if(tempZ) z = tempZ;
    }

    uint64_t dim[3];
    dim[0] = y;
    dim[1] = x;
    dim[2] = z;



    // Case for ImageJ
    uint8_t err = 0;
    if(imageJIm){
        if(bits == 8){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxUINT8_CLASS, mxREAL);
            uint8_t* tiff = (uint8_t*)mxGetPr(plhs[0]);
            err = readTiffParallelImageJ(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 16){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxUINT16_CLASS, mxREAL);
            uint16_t* tiff = (uint16_t*)mxGetPr(plhs[0]);
            err = readTiffParallelImageJ(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 32){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxSINGLE_CLASS, mxREAL);
            float* tiff = (float*)mxGetPr(plhs[0]);
            err = readTiffParallelImageJ(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 64){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxDOUBLE_CLASS, mxREAL);
            double* tiff = (double*)mxGetPr(plhs[0]);
            err = readTiffParallelImageJ(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else{
            mexErrMsgIdAndTxt("tiff:dataTypeError","Data type not suppported");
        }
    }
    // Case for 2D
    else if(z <= 1){
        if(bits == 8){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxUINT8_CLASS, mxREAL);
            uint8_t* tiff = (uint8_t*)mxGetPr(plhs[0]);
            err = readTiffParallel2D(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 16){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxUINT16_CLASS, mxREAL);
            uint16_t* tiff = (uint16_t*)mxGetPr(plhs[0]);
            err = readTiffParallel2D(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 32){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxSINGLE_CLASS, mxREAL);
            float* tiff = (float*)mxGetPr(plhs[0]);
            err = readTiffParallel2D(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 64){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxDOUBLE_CLASS, mxREAL);
            double* tiff = (double*)mxGetPr(plhs[0]);
            err = readTiffParallel2D(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else{
            mexErrMsgIdAndTxt("tiff:dataTypeError","Data type not suppported");
        }
    }
    // Case for 3D
    else{
        if(bits == 8){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxUINT8_CLASS, mxREAL);
            uint8_t* tiff = (uint8_t*)mxGetPr(plhs[0]);
            err = readTiffParallel(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 16){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxUINT16_CLASS, mxREAL);
            uint16_t* tiff = (uint16_t*)mxGetPr(plhs[0]);
            err = readTiffParallel(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 32){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxSINGLE_CLASS, mxREAL);
            float* tiff = (float*)mxGetPr(plhs[0]);
            err = readTiffParallel(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else if(bits == 64){
            plhs[0] = mxCreateNumericArray(3,(mwSize*)dim,mxDOUBLE_CLASS, mxREAL);
            double* tiff = (double*)mxGetPr(plhs[0]);
            err = readTiffParallel(x,y,z,fileName, (void*)tiff, bits, startSlice, stripSize, flipXY);
        }
        else{
            mexErrMsgIdAndTxt("tiff:dataTypeError","Data type not suppported");
        }
    }
    if(err) mexErrMsgIdAndTxt("tiff:tiffError","An Error occured within the read function");
}