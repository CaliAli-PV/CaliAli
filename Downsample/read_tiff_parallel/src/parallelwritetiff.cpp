#include <cstdint>
#include <cmath>
#include <cstring>
#include <omp.h>
#include <chrono>
#include <thread>
#include <future>
#include "tiffio.h"
#include "lzwencode.h"
#include "helperfunctions.h"

/**
 * @brief Writes TIFF image data to a file in single-threaded mode.
 *
 * This function writes TIFF image data to the specified file using the libtiff API.
 * It supports both writing ("w") and appending ("a") modes. The function sets various TIFF
 * fields such as image width, height, bits per sample, rows per strip, and compression type.
 * The compression is set to LZW if the provided compression string is not "none", otherwise
 * no compression is applied. The image data is written in strips, where each strip's length
 * is computed based on the stripSize and the image dimensions. One TIFF directory is written
 * per image slice starting from the provided startSlice index.
 *
 * @param x           Image width in pixels.
 * @param y           Image height in pixels.
 * @param z           Total number of image slices to write.
 * @param fileName    Path to the TIFF file.
 * @param tiff        Pointer to the image data to write.
 * @param tiffOld     Unused pointer reserved for alternate image data (e.g., for transposition).
 * @param bits        Bits per sample (e.g., 8, 16, 32). If bits >= 32, the sample format is set to IEEE floating point.
 * @param startSlice  Starting slice index from which to begin writing.
 * @param stripSize   Number of rows per strip.
 * @param mode        File mode indicator: "w" for write mode, "a" for append mode.
 * @param transpose   Flag indicating whether the image data should be transposed (currently not used in the implementation).
 * @param compression Compression type as a string; if not "none", LZW compression is applied.
 *
 * @return 0 on success, or 1 if an error occurs (e.g., file cannot be opened or an unsupported mode is provided).
 *
 * @note The function prints error messages to stdout if file operations fail.
 *
 * @warning The 'transpose' parameter is currently not utilized, and 'tiffOld' remains unused in this implementation.
 */
uint8_t writeTiffSingle(const uint64_t x, const uint64_t y, const uint64_t z, const char* fileName, const void* tiff, const void* tiffOld, const uint64_t bits, const uint64_t startSlice, const uint64_t stripSize, const char* mode, const bool transpose, const std::string &compression){
    TIFF* tif = NULL;
    if(!strcmp(mode,"w")){
        tif = TIFFOpen(fileName, "w8");
        if(!tif){
            printf("Error: File \"%s\" cannot be opened",fileName);
			return 1;
        }
    }
    else if(!strcmp(mode,"a")){
        tif = TIFFOpen(fileName, "a8");
        if(!tif){
            printf("Error: File \"%s\" cannot be opened",fileName);
			return 1;
        }
    }
    else{
        printf("Error: mode \"%s\" is not supported. Use w or a for mode type", mode);
        return 1;
    }

    uint64_t len = 0;
    int compressionType = COMPRESSION_NONE;
    if(compression != "none"){
        compressionType = COMPRESSION_LZW;
    }
    for(uint64_t dir = startSlice; dir < z; dir++){
        if(dir>=z+startSlice) break;
        TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, x);
        TIFFSetField(tif, TIFFTAG_IMAGELENGTH, y);
        TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE, bits);
        TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, stripSize);
        TIFFSetField(tif, TIFFTAG_COMPRESSION, compressionType);
        TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, 1);
        TIFFSetField(tif, TIFFTAG_PLANARCONFIG, 1);
        TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, 1);

        if(bits >= 32){
            TIFFSetField(tif, TIFFTAG_SAMPLEFORMAT, SAMPLEFORMAT_IEEEFP);
        }

        for (int64_t i = 0; i*stripSize < y; i++)
        {   
                if (stripSize*(i+1) > y){
                    len = (y-(stripSize*i))*x*(bits/8);
                }
                else{
                    len = stripSize*x*(bits/8);
                }
                TIFFWriteEncodedStrip(tif, i, (uint8_t*)tiff+((((i*stripSize)*x)+((dir-startSlice)*(x*y)))*(bits/8)), len);
                //if(transpose) TIFFWriteEncodedStrip(tif, i, (uint8_t*)tiff+((((i*stripSize)*x)+((dir-startSlice)*(x*y)))*(bits/8)), len);
                //else TIFFWriteEncodedStrip(tif,i,(uint8_t*)tiffOld+((((i*stripSize)*x)+((dir-startSlice)*(x*y)))*(bits/8)), len);
                //TIFFWriteRawStrip(tif,i,(uint8_t*)tiff+((((i*stripSize)*x)+((dir-startSlice)*(x*y)))*(bits/8)), len);
        }
        TIFFWriteDirectory(tif);
    }
    TIFFClose(tif);
    return 0;
}

/**
 * @brief Writes image data to a TIFF file in a separate thread.
 *
 * This function processes and writes TIFF directories (slices) to the specified file,
 * handling both uncompressed and LZW compressed data. For each slice from @p startSlice to @p z,
 * it sets TIFF fields (including image dimensions, bits per sample, and compression) and writes image strips.
 * In the compressed case (when @p compression is not "none"), the function waits until the corresponding
 * compressed size is non-zero before writing each strip and frees the allocated memory for that strip after use.
 * For uncompressed data, the raw image data is written strip by strip, with the length of the last strip
 * adjusted if necessary.
 *
 * The TIFF file is opened in either write ("w") or append ("a") mode based on the @p mode parameter.
 * On error (e.g., unsupported mode or failure to open the file), the function prints an error message and returns 1.
 *
 * @param x             Image width in pixels.
 * @param y             Image height in pixels.
 * @param z             Total number of image slices (directories).
 * @param fileName      Path to the TIFF file.
 * @param tiff          Pointer to the raw image data buffer.
 * @param bits          Number of bits per sample (e.g., 8, 16, 32, or 64).
 * @param startSlice    Slice index from which to start writing TIFF directories.
 * @param stripSize     Number of rows per strip.
 * @param mode          File mode: "w" to write and "a" to append.
 * @param stripsPerDir  Number of strips per TIFF directory.
 * @param comprA        Reference to an array of pointers holding compressed strip data for each directory.
 * @param cSizes        Array containing the size (in bytes) of each compressed strip.
 * @param compression   Compression type; if not "none", LZW compression is used.
 *
 * @return              Returns 0 upon success, or 1 if an error occurs (e.g., file cannot be opened or mode is invalid).
 *
 * @note Memory allocated for compressed data (both @p comprA and @p cSizes) is freed within this function.
 * @note When writing compressed strips, the function actively waits (with a microsecond sleep) until the
 *       compressed size for the strip is available.
 */
uint8_t writeTiffThread(const uint64_t x, const uint64_t y, const uint64_t z, const char* fileName, const void* tiff, const uint64_t bits, const uint64_t startSlice, const uint64_t stripSize, const char* mode, const uint64_t stripsPerDir, uint8_t** &comprA, uint64_t* cSizes, const std::string &compression){
    TIFF* tif = NULL;
    if(!strcmp(mode,"w")){
        tif = TIFFOpen(fileName, "w8");
        if(!tif){
            printf("Error: File \"%s\" cannot be opened",fileName);
            return 1;
        }
    }
    else if(!strcmp(mode,"a")){
        tif = TIFFOpen(fileName, "a8");
        if(!tif){
            printf("Error: File \"%s\" cannot be opened",fileName);
            return 1;
        }
    }
    else{
        printf("Error: mode \"%s\" is not supported. Use w or a for mode type", mode);
        return 1;
    }

    uint64_t len = 0;
    int compressionType = COMPRESSION_NONE;
    bool compress = false;
    if(compression != "none"){
        compress = true;
        compressionType = COMPRESSION_LZW;
    }
    for(uint64_t dir = startSlice; dir < z; dir++){
        TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, x);
        TIFFSetField(tif, TIFFTAG_IMAGELENGTH, y);
        TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE, bits);
        TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, stripSize);
        TIFFSetField(tif, TIFFTAG_COMPRESSION, compressionType);
        TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, 1);
        TIFFSetField(tif, TIFFTAG_PLANARCONFIG, 1);
        TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, 1);

        if(bits >= 32){
            TIFFSetField(tif, TIFFTAG_SAMPLEFORMAT, SAMPLEFORMAT_IEEEFP);
        }

        for (int64_t i = 0; i*stripSize < y; i++)
        {
            if(compress){
                while(!cSizes[i+(dir*stripsPerDir)]){
                    std::this_thread::sleep_for(std::chrono::microseconds(1));
                }
                TIFFWriteRawStrip(tif,i,comprA[i+(dir*stripsPerDir)], cSizes[i+(dir*stripsPerDir)]);
                free(comprA[i+(dir*stripsPerDir)]);
            }
            else{
                if (stripSize*(i+1) > y){
                    len = (y-(stripSize*i))*x*(bits/8);
                }
                else{
                    len = stripSize*x*(bits/8);
                }
                TIFFWriteRawStrip(tif,i,(uint8_t*)tiff+((((i*stripSize)*x)+((dir-startSlice)*(x*y)))*(bits/8)), len);
            }
        }
        TIFFWriteDirectory(tif);
    }
	free(comprA);
	free(cSizes);
    TIFFClose(tif);
    return 0;
}

/**
 * @brief Writes TIFF data to a file using parallel processing.
 *
 * This function writes TIFF image data by dividing the image into strips and compressing each strip 
 * using LZW encoding if a compression type other than "none" is specified. It leverages multi-threading 
 * through OpenMP to compress the image strips concurrently and uses an asynchronous thread (writeTiffThread) 
 * to handle the actual file writing. If only one worker thread is available, the function falls back to the 
 * single-threaded writeTiffSingle operation.
 *
 * The image is partitioned into strips where the number of strips per directory is determined by 
 * ceiling(y/stripSize), and the total number of strips is calculated as stripsPerDir multiplied by z (number of slices).
 * Memory for storing compressed data and corresponding sizes is allocated and passed to the worker thread.
 *
 * @param x            The image width in pixels.
 * @param y            The image height in pixels.
 * @param z            The number of image slices (depth).
 * @param fileName     The output file name.
 * @param tiff         Pointer to the TIFF data buffer to be written.
 * @param tiffOld      Pointer to previous TIFF data for reference.
 * @param bits         The number of bits per sample.
 * @param startSlice   The starting slice index from which to begin writing.
 * @param stripSize    The height of each strip within the image.
 * @param mode         The file mode, such as "w" for write or "a" for append.
 * @param transpose    Indicates if the image data should be transposed prior to writing.
 * @param compression  The compression type to be applied (e.g., "lzw"); use "none" to disable compression.
 *
 * @return An 8-bit status code where 0 indicates success and non-zero indicates failure.
 */
uint8_t writeTiffParallel(const uint64_t x, const uint64_t y, const uint64_t z, const char* fileName, const void* tiff, const void* tiffOld, const uint64_t bits, const uint64_t startSlice, const uint64_t stripSize, const char* mode, const bool transpose, const std::string &compression){
    int32_t numWorkers = omp_get_max_threads();
    
    if(numWorkers == 1){
        return writeTiffSingle(x, y, z, fileName, tiff, tiffOld, bits, startSlice, stripSize, mode, transpose, compression);
    }
    
    uint64_t stripsPerDir = (uint64_t)ceil((double)y/(double)stripSize);
    uint64_t totalStrips = stripsPerDir*z;
    uint64_t extraBytes = 2000;
    uint8_t** comprA = NULL;
    uint64_t* cSizes = (uint64_t*)calloc(totalStrips, sizeof(uint64_t));

    std::future<uint8_t> writerThreadResult = std::async(std::launch::async, writeTiffThread, x, y, z, fileName, tiff, bits, startSlice, stripSize, mode, stripsPerDir, std::ref(comprA), cSizes, std::ref(compression));
    if(compression != "none"){
        comprA = (uint8_t**)malloc(totalStrips*sizeof(uint8_t*));

        #pragma omp parallel for
        for(uint64_t dir = startSlice; dir < z; dir++){
            uint64_t len = 0;
            for (uint64_t i = 0; i*stripSize < y; i++)
            {
                comprA[i+(dir*stripsPerDir)] = (uint8_t*)malloc((((x*stripSize)*(bits/8))+(extraBytes*(bits/8)))*2+1);
                if (stripSize*(i+1) > y){
                    len = (y-(stripSize*i))*x*(bits/8);
                }
                else{
                    len = stripSize*x*(bits/8);
                }

                if(dir == z-1 && len == (y-(stripSize*i))*x*(bits/8)){
                    uint8_t* cArrL = (uint8_t*)malloc(len+(extraBytes*(bits/8)));
                    memcpy(cArrL,(uint8_t*)tiff+((((i*stripSize)*x)+((dir-startSlice)*(x*y)))*(bits/8)),len);
                    cSizes[i+(dir*stripsPerDir)] = lzwEncode(cArrL,comprA[i+(dir*stripsPerDir)],len+(extraBytes*(bits/8)));
                    free(cArrL);
                    continue;
                }
                cSizes[i+(dir*stripsPerDir)] = lzwEncode((uint8_t*)tiff+((((i*stripSize)*x)+((dir-startSlice)*(x*y)))*(bits/8)),comprA[i+(dir*stripsPerDir)],len+(extraBytes*(bits/8)));
            }
        }
    }
    return writerThreadResult.get();
}

/**
 * @brief Writes a TIFF file in parallel with optional transposition of image data.
 *
 * When the transpose flag is enabled, this function allocates memory to create a transposed
 * version of the input image data. Depending on the bit depth (supported values: 8, 16, 32, or 64),
 * the transposition is performed using nested loops that are parallelized with OpenMP when multiple threads are available.
 * In the case of an unsupported bit depth, the allocated memory is freed and the function returns an error code.
 *
 * If transposition is not requested, the function delegates the TIFF writing task directly to writeTiffParallel.
 * After processing, any memory allocated for transposition is freed before the function returns.
 *
 * @param x           Image width in pixels.
 * @param y           Image height in pixels.
 * @param z           Number of image slices.
 * @param fileName    C-string specifying the output TIFF file name.
 * @param data        Pointer to the original image data in row-major order.
 * @param bits        Bit depth per sample; only 8, 16, 32, or 64 are supported.
 * @param startSlice  Index offset for the starting slice in the image data.
 * @param stripSize   Strip size used for writing the TIFF file.
 * @param mode        C-string indicating the file open mode (e.g., "w" for write, "a" for append).
 * @param transpose   Boolean flag indicating whether to transpose the image data before writing.
 * @param compression String specifying the compression type (e.g., "none", "lzw").
 *
 * @return uint8_t    A status code: 0 indicates success, while a non-zero value indicates an error,
 *                    such as an unsupported bit depth.
 */
uint8_t writeTiffParallelWrapper(const uint64_t x, const uint64_t y, const uint64_t z, const char* fileName, const void* data, const uint64_t bits, const uint64_t startSlice, const uint64_t stripSize, const char* mode, const bool transpose, const std::string &compression){
    int32_t numWorkers = omp_get_max_threads();
    void* tiff = nullptr;

    if(transpose){
        tiff = (void*)malloc(x*y*z*(bits/8));
        // Only use omp if there is more than one thread
        if(numWorkers > 1){
            if(bits == 8){
                #pragma omp parallel for collapse(3)
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((uint8_t*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((uint8_t*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }
            }
            else if(bits == 16){
                #pragma omp parallel for collapse(3)
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((uint16_t*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((uint16_t*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }        
            }
            else if(bits == 32){
                #pragma omp parallel for collapse(3)
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((float*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((float*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }        
            }
            else if(bits == 64){
                #pragma omp parallel for collapse(3)
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((double*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((double*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }        
            }
            else{
                free(tiff);
                return 1;
            }
        }
        else{
            if(bits == 8){
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((uint8_t*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((uint8_t*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }
            }
            else if(bits == 16){
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((uint16_t*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((uint16_t*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }        
            }
            else if(bits == 32){
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((float*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((float*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }        
            }
            else if(bits == 64){
                for(uint64_t dir = 0; dir < z; dir++){
                    for(uint64_t j = 0; j < y; j++){
                        for(uint64_t i = 0; i < x; i++){
                            ((double*)tiff)[i+(j*x)+((dir-startSlice)*(x*y))] = ((double*)data)[j+(i*y)+((dir-startSlice)*(x*y))];
                        }
                    }
                }        
            }
            else{
                free(tiff);
                return 1;
            }
        }
    }
    else{
        return writeTiffParallel(x, y, z, fileName, data, data, bits, startSlice, stripSize, mode, transpose, compression);
    }
    
    uint8_t ret = writeTiffParallel(x, y, z, fileName, tiff, data, bits, startSlice, stripSize, mode, transpose, compression);
    free(tiff);
    return ret;
}

/**
 * @brief Prepares the output directory and initiates parallel TIFF writing.
 *
 * This function checks if the directory for the specified file exists and creates it recursively if needed.
 * It then sets the TIFF warning handler, adjusts the writing mode (defaulting to "w" if not provided),
 * and ensures that the z-dimension is at least 1 (useful for 2D images where MATLAB may pass z as 0). Finally,
 * the function calls writeTiffParallelWrapper with a fixed strip size of 512 to perform the parallel TIFF writing
 * using the given compression type.
 *
 * @param fileName Full path to the output TIFF file.
 * @param tiffOld Pointer to the original TIFF data.
 * @param bits Number of bits per sample in the TIFF image.
 * @param mode File access mode ("w" for write or "a" for append). Defaults to "w" if a null pointer is provided.
 * @param x Width of the image in pixels.
 * @param y Height of the image in pixels.
 * @param z Number of image slices; set to 1 if 0 is provided (to handle 2D images).
 * @param startSlice Index of the starting slice in a multi-slice image.
 * @param flipXY Flag indicating whether to transpose the image (swap X and Y dimensions).
 * @param compression Compression type to be used when writing the TIFF file (e.g., "none", "lzw").
 */
void writeTiffParallelHelper(const char* fileName, const void* tiffOld, uint64_t bits, const char* mode, uint64_t x, uint64_t y, uint64_t z, uint64_t startSlice, uint8_t flipXY, const std::string &compression)
{
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

	if(!mode) mode = "w";

	// For 2D images MATLAB passes in the 3rd dim as 0 so we set it to 1;
	if(!z){
		z = 1;
	}

	uint64_t stripSize = 512;

    writeTiffParallelWrapper(x, y, z, fileName, tiffOld, bits, startSlice, stripSize, mode, flipXY, compression);
}
