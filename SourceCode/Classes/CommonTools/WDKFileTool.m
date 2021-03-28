//
//  WDKFileTool.m
//  WCDebugKit
//
//  Created by wesley_chen on 2021/3/21.
//

#import "WDKFileTool.h"

@implementation WDKFileTool

+ (BOOL)directoryExistsAtPath:(NSString *)path {
    if (![path isKindOfClass:[NSString class]] || path.length == 0) {
        return NO;
    }
    
    BOOL isDirectory = NO;
    BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    return (isDirectory && isExisted) ? YES : NO;
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    if (![path isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    BOOL isDirectory = NO;
    BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    if (isDirectory) {
        // If the path is a directory, no file at the path exists
        return NO;
    }
    
    return isExisted;
}

+ (BOOL)checkImageFileExistsAtPath:(NSString *)path imageTypes:(NSArray<NSNumber *> *)imageTypes {
    if (![path isKindOfClass:[NSString class]] || ![imageTypes isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    if (![self fileExistsAtPath:path]) {
        return NO;
    }
    
    __block BOOL isImageFile = NO;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    const NSUInteger maxLength = 30;
    NSData *chunkData;
    if ([NSFileHandle instancesRespondToSelector:@selector(readDataUpToLength:error:)]) {
        NSError *error;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunguarded-availability-new"
        chunkData = [fileHandle readDataUpToLength:maxLength error:&error];
#pragma GCC diagnostic pop
    }
    else {
        chunkData = [fileHandle readDataOfLength:maxLength];
    }
    
    [fileHandle closeFile];
    
    unsigned char *byteOrder = (unsigned char *)[chunkData bytes];
    
    [imageTypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.intValue) {
            case WCMIMETypeBmp: {
                const unsigned char bytes[] = { 0x42, 0x4D };
                isImageFile = (chunkData.length >= sizeof(bytes) && memcmp(byteOrder, bytes, sizeof(bytes)) == 0);
                break;
            }
            case WCMIMETypeGif: {
                const unsigned char bytes[] = { 0x47, 0x49, 0x46 };
                isImageFile = (chunkData.length >= sizeof(bytes) && memcmp(byteOrder, bytes, sizeof(bytes)) == 0);
                break;
            }
            case WCMIMETypeHeic: {
                // @see https://github.com/rs/SDWebImage/blob/master/SDWebImage/NSData%2BImageContentType.m
                const unsigned char bytes1[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63 }; // @"ftypheic"
                const unsigned char bytes2[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x78 }; // @"ftypheix"
                const unsigned char bytes3[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x76, 0x63 }; // @"ftyphevc"
                const unsigned char bytes4[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x76, 0x78 }; // @"ftyphevx"
                
                if (chunkData.length >= 4 &&
                    (memcmp(byteOrder + 4, bytes1, sizeof(bytes1)) == 0 ||
                     memcmp(byteOrder + 4, bytes2, sizeof(bytes2)) == 0 ||
                     memcmp(byteOrder + 4, bytes3, sizeof(bytes3)) == 0 ||
                     memcmp(byteOrder + 4, bytes4, sizeof(bytes4)) == 0)) {
                    isImageFile = YES;
                }
                break;
            }
            case WCMIMETypeHeif: {
                const unsigned char bytes1[] = { 0x66, 0x74, 0x79, 0x70, 0x6D, 0x69, 0x66, 0x31 }; // @"ftypmif1"
                const unsigned char bytes2[] = { 0x66, 0x74, 0x79, 0x70, 0x6D, 0x73, 0x66, 0x31 }; // @"ftypmsf1"
                
                if (chunkData.length >= 4 &&
                    (memcmp(byteOrder + 4, bytes1, sizeof(bytes1)) == 0 ||
                     memcmp(byteOrder + 4, bytes2, sizeof(bytes2)) == 0)) {
                    isImageFile = YES;
                }
                break;
            }
            case WCMIMETypeIco: {
                const unsigned char bytes[] = { 0x00, 0x00, 0x01, 0x00 };
                isImageFile = (chunkData.length >= sizeof(bytes) && memcmp(byteOrder, bytes, sizeof(bytes)) == 0);
                break;
            }
            case WCMIMETypeJpg: {
                const unsigned char bytes[] = { 0xFF, 0xD8, 0xFF };
                isImageFile = (chunkData.length >= sizeof(bytes) && memcmp(byteOrder, bytes, sizeof(bytes)) == 0);
                break;
            }
            case WCMIMETypePng: {
                const unsigned char bytes[] = { 0x89, 0x50, 0x4E, 0x47 };
                isImageFile = (chunkData.length >= sizeof(bytes) && memcmp(byteOrder, bytes, sizeof(bytes)) == 0);
                break;
            }
            case WCMIMETypeTtf: {
                const unsigned char bytes[] = { 0x00, 0x01, 0x00, 0x00, 0x00 };
                isImageFile = (chunkData.length >= sizeof(bytes) && memcmp(byteOrder, bytes, sizeof(bytes)) == 0);
                break;
            }
            case WCMIMETypeWebp: {
                const unsigned char bytes[] = { 0x57, 0x45, 0x42, 0x50 };
                isImageFile = (chunkData.length >= sizeof(bytes) && memcmp(byteOrder, bytes, sizeof(bytes)) == 0);
                break;
            }
            default:
                break;
        }
        
        if (isImageFile) {
            *stop = YES;
        }
    }];
    
    return isImageFile;
}

@end
