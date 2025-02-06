#include <cstdint>
#include <cstring>
#include <string>
#include "mex.h"
#include "tiffio.h"
#include "../src/helperfunctions.h"
#include "../src/parallelwritetiff.h"


/**
 * @brief Entry point for the MATLAB MEX function that writes image data to a TIFF file.
 *
 * This function processes input arguments from MATLAB, validates and converts file paths and image
 * data, and writes the image data to a TIFF file using parallelized I/O. The function requires at least
 * two input arguments:
 * - The first argument must be a string or character array representing the output file name.
 * - The second argument must be the image data, which should be a 2D or 3D array with all dimensions of size at least 1.
 *
 * Optionally, the third argument specifies the file writing mode (default is "w"), and the fourth argument
 * specifies the compression type (default is "lzw"). On non-Windows systems, if the file name contains a tilde (~),
 * it is expanded to the full home directory path. The function also ensures that the directory for the output file exists,
 * creating it recursively if necessary.
 *
 * The function determines the bit depth based on the data type of the image input:
 * - UINT8 maps to 8 bits
 * - UINT16 maps to 16 bits
 * - SINGLE maps to 32 bits
 * - DOUBLE maps to 64 bits
 *
 * Afterwards, it calls writeTiffParallelWrapper with the computed dimensions, file name, image data pointer, bit depth,
 * and compression type. If any error occurs during validation or the TIFF writing process, the function will report the error
 * using mexErrMsgIdAndTxt.
 *
 * @param nlhs Number of expected output arguments.
 * @param plhs Array of pointers to output mxArray structures.
 * @param nrhs Number of input arguments.
 * @param prhs Array of pointers to input mxArray structures.
 *
 * @note For 2D image data, the third dimension is set to 1.
 * @note Supported image data types are UINT8, UINT16, SINGLE, and DOUBLE.
 * @note When provided, the fourth argument must be a string (or character array) indicating the compression type.
 * @see writeTiffParallelWrapper
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    if(nrhs < 2) mexErrMsgIdAndTxt("tiff:inputError","This function requires at least 2 arguments");

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
    if(mxIsEmpty(prhs[1])) mexErrMsgIdAndTxt("tiff:inputError","All input data axes must be of at least size 1");

    std::string compression = "lzw";
    if(nrhs == 4){
        if(!mxIsClass(prhs[3], "string")){
            if(!mxIsChar(prhs[3])) mexErrMsgIdAndTxt("tiff:inputError","The fourth argument must be a string");
            compression = mxArrayToString(prhs[0]);
        }
        else{
            mxArray* mString[1];
            mxArray* mCharA[1];

            // Convert string to char array
            mString[0] = mxDuplicateArray(prhs[3]);
            mexCallMATLAB(1, mCharA, 1, mString, "char");
            compression = mxArrayToString(mCharA[0]);
        }
    }

    // Handle the tilde character in filenames on Linux/Mac
    #ifndef _WIN32
    if(strchr(fileName,'~')) fileName = expandTilde(fileName);
    #endif

    // Check if folder exists, if not then make it (recursive if needed)
    char* folderName = strdup(fileName);
    char *lastSlash = NULL;
    #ifdef _WIN32
    lastSlash = strrchr(folderName, '\\');
    #else
    lastSlash = strrchr(folderName, '/');
    #endif
    if(lastSlash){
        *lastSlash = '\0';
        FILE* f = fopen(folderName,"r");
        if(f){
            fclose(f);
        }
        else{
            mkdirRecursive(folderName);
        }
    }
    free(folderName);

    TIFFSetWarningHandler(DummyHandler);
    const char* mode;
    if(nrhs > 2){
         mode = mxArrayToString(prhs[2]);
    }
    else{
        mode = "w";
    }
    int nDims = (int) mxGetNumberOfDimensions(prhs[1]);
    if(nDims < 2 || nDims > 3) mexErrMsgIdAndTxt("tiff:inputError","Data must be 2D or 3D");
    uint64_t* dims = (uint64_t*) mxGetDimensions(prhs[1]);


    uint64_t x = dims[1], y = dims[0], z = dims[2], bits = 0, startSlice = 0;

    // For 2D images MATLAB passes in the 3rd dim as 0 so we set it to 1;
    if(!z){
        z = 1;
    }

    mxClassID mDType = mxGetClassID(prhs[1]);
    if(mDType == mxUINT8_CLASS){
        bits = 8;
    }
    else if(mDType == mxUINT16_CLASS){
        bits = 16;
    }
    else if(mDType == mxSINGLE_CLASS){
        bits = 32;
    }
    else if(mDType == mxDOUBLE_CLASS){
        bits = 64;
    }
    else{
        mexErrMsgIdAndTxt("tiff:dataTypeError","Data type not suppported");
    }

    uint64_t stripSize = 512;
    void* data = (void*)mxGetPr(prhs[1]);
    uint8_t err = writeTiffParallelWrapper(x,y,z,fileName,data,bits,startSlice,stripSize,mode,true,compression);

    if(err) mexErrMsgIdAndTxt("tiff:tiffError","An Error occured within the write function");
}
