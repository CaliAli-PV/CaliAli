#include <cstdint>
#include <cstring>
#include <sys/stat.h>
#include <string>
// For std::replace
#ifdef _WIN32
#include <algorithm>
#endif
#include "tiffio.h"
#include "helperfunctions.h"
// Handle the tilde character in filenames on Linux/Mac
#ifndef _WIN32
#include <wordexp.h>
char* expandTilde(char* path) {
    wordexp_t expPath;
    wordexp(path, &expPath, 0);
    return expPath.we_wordv[0];
}
#endif

bool folderExists(const std::string &folderName){
    struct stat info;

    if(stat(folderName.c_str(), &info) != 0)
        return false;
    else if(info.st_mode & S_IFDIR)
        return true;
    else
        return false;
}

// Recursively make a directory
void mkdirRecursive(const char *dir) {
    if(folderExists(dir)) return;

    std::string dirPath(dir);
    if(!dirPath.size()) return;

    // Convert all \\ to / if on Windows
    #ifdef _WIN32
    std::replace(dirPath.begin(), dirPath.end(), '\\', '/');
    #endif

    // If there is a slash at the end, remove it
    if(dirPath.back() == '/') dirPath.pop_back();
    
    for(size_t i = 0; i < dirPath.size(); i++){
        if(dirPath[i] == '/'){
            dirPath[i] = '\0';

            #ifdef _WIN32
            mkdir(dirPath.c_str());
            #else
            mkdir(dirPath.c_str(), 0777);
            #endif

            dirPath[i] = '/';
        }
    }

    #ifdef _WIN32
    mkdir(dirPath.c_str());
    #else
    mkdir(dirPath.c_str(), 0777);
    #endif
}

void DummyHandler(const char* module, const char* fmt, va_list ap)
{
    // ignore errors and warnings
}

/**
 * @brief Checks if a TIFF file is an ImageJ image.
 *
 * This function opens the TIFF file specified by @p fileName and determines whether it
 * is formatted as an ImageJ image. The check is performed by examining the file’s image
 * description (retrieved via the TIFFTAG_IMAGEDESCRIPTION field) for the substring "ImageJ".
 * If found, it retrieves the image dimensions using getImageSize and verifies that the Z-dimension
 * (assumed to be stored at index 2) is not greater than 1 when a secondary directory exists.
 * Finally, the function confirms that the compression type (retrieved from TIFFTAG_COMPRESSION)
 * is uncompressed (value 1). If all these conditions are met, the image is considered a valid
 * ImageJ image.
 *
 * Note: The method for checking if the file is an ImageJ image is subject to improvement in future revisions.
 * Memory allocated for image dimensions is freed within this function.
 *
 * @param fileName A null-terminated string representing the path to the TIFF file.
 * @return Returns 1 if the file is identified as a valid ImageJ image; otherwise, returns 0.
 *
 * @see getImageSize
 * @see TIFFOpen()
 * @see TIFFGetField()
 * @see TIFFSetDirectory()
 * @see TIFFClose()
 */
uint8_t isImageJIm(const char* fileName){
    TIFF* tif = TIFFOpen(fileName, "r");
    if(!tif) return 0;
    char* tiffDesc = NULL;
    if(TIFFGetField(tif, TIFFTAG_IMAGEDESCRIPTION, &tiffDesc)){
        if(strstr(tiffDesc, "ImageJ")){
            uint64_t* size = getImageSize(fileName);
            if(size[2] > 1){
                if(TIFFSetDirectory(tif,1)){
                    free(size);
                    return 0;
                }
            }
            free(size);
            uint16_t compressed = 1;
            TIFFGetField(tif, TIFFTAG_COMPRESSION, &compressed);
            TIFFClose(tif);
            if(compressed != 1) return 0;
            else return 1;
        }
    }
    TIFFClose(tif);
    return 0;
}

/**
 * @brief Retrieves the Z dimension (number of slices) from an ImageJ TIFF file.
 *
 * This function opens the specified TIFF file in read mode and attempts to extract the image description.
 * It then checks if the description contains the identifier "ImageJ" and, if so, looks for the substring "images=".
 * If the substring is found, the function extracts the numerical value following "images=", which represents the Z dimension
 * (i.e., the number of image slices), and returns it. The TIFF file is closed before returning.
 *
 * @param fileName Pointer to a null-terminated string containing the path to the TIFF file.
 * @return The Z dimension (number of slices) as a uint64_t if a valid ImageJ image is detected; otherwise, returns 0.
 */
uint64_t imageJImGetZ(const char* fileName){
    TIFF* tif = TIFFOpen(fileName, "r");
    if(!tif) return 0;
    char* tiffDesc = NULL;
    if(TIFFGetField(tif, TIFFTAG_IMAGEDESCRIPTION, &tiffDesc)){
        if(strstr(tiffDesc, "ImageJ")){
            char* nZ = strstr(tiffDesc,"images=");
            if(nZ){
                TIFFClose(tif);
                nZ+=7;
                char* temp;
                return strtol(nZ,&temp,10);
            }
        }
    }
    TIFFClose(tif);
    return 0;
}

/**
 * @brief Calculates the number of image slices (Z dimension) in a TIFF file.
 *
 * This function determines the number of slices by probing the TIFF file's directories. It first
 * advances exponentially through directory indices until it encounters an invalid directory, then performs
 * a binary search between the last valid and the first invalid index to pinpoint the maximum valid directory.
 * Each valid directory corresponds to one slice in the TIFF file. A custom warning handler (DummyHandler)
 * is set to suppress TIFF library warnings.
 *
 * @param fileName A pointer to a null-terminated string representing the path to the TIFF file.
 * @return The total number of slices (Z dimension) as a uint32_t.
 *
 * @note If the TIFF file cannot be opened, an error message is printed. Additionally, if the number of slices
 * exceeds 1,073,741,824, a warning is printed and an upper limit of 4,294,967,295 is used in the search.
 *
 * @warning The function does not robustly handle file opening errors; failure to open the file may lead to undefined behavior.
 */
uint32_t getImageSizeZ(const char* fileName){
    TIFFSetWarningHandler(DummyHandler);
    TIFF* tif = TIFFOpen(fileName, "r");
    if(!tif) printf("File \"%s\" cannot be opened",fileName);

    uint32_t s = 0, m = 0, t = 1, z = 1;
    while(TIFFSetDirectory(tif,t)){
        s = t;
        t *= 8;
        if(s > t){
            t = 4294967295;
            printf("Number of slices > 1073741824\n");
            break;
        }
    }
    while(s != t){
        m = (s+t+1)/2;
        if(TIFFSetDirectory(tif,m)){
            s = m;
        }
        else{
            if(m > 0) t = m-1;
            else t = m;
        }
    }
    z = s+1;
    TIFFClose(tif);
    return z;
}

/**
 * @brief Retrieves the dimensions of a TIFF image.
 *
 * This function opens the specified TIFF file and retrieves its dimensions. It uses
 * TIFFGetField to obtain the image width and height, and calls getImageSizeZ() to determine
 * the number of slices (Z dimension). The dimensions are stored in a dynamically allocated
 * array where:
 *   - Index 0 holds the image height,
 *   - Index 1 holds the image width,
 *   - Index 2 holds the Z dimension.
 *
 * A dummy warning handler is set with DummyHandler to suppress TIFF library warnings.
 *
 * @param fileName A constant character pointer specifying the path to the TIFF file.
 * @return A pointer to a dynamically allocated array of three uint64_t elements containing the 
 *         image dimensions. The caller is responsible for freeing the allocated memory.
 *
 * @note If the TIFF file cannot be opened, an error message is printed. The function does not
 *       perform further error handling in this case.
 */
uint64_t* getImageSize(const char* fileName){
    TIFFSetWarningHandler(DummyHandler);
    TIFF* tif = TIFFOpen(fileName, "r");
    if(!tif) printf("File \"%s\" cannot be opened",fileName);

    uint64_t x = 1,y = 1,z = 1;
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &x);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &y);
    z = getImageSizeZ(fileName);
    TIFFClose(tif);

    uint64_t* dims = (uint64_t*)malloc(3*sizeof(uint64_t));
    dims[0] = y;
    dims[1] = x;
    dims[2] = z;
    return dims;
}

// Returns number of bits the tiff file is.
uint64_t getDataType(const char* fileName){
    TIFFSetWarningHandler(DummyHandler);
    TIFF* tif = TIFFOpen(fileName, "r");
    if(!tif) printf("File \"%s\" cannot be opened",fileName);

    uint64_t bits = 1;
    TIFFGetField(tif, TIFFTAG_BITSPERSAMPLE, &bits);
    TIFFClose(tif);

    return bits;
}

