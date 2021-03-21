//
//  WDKFileTool.h
//  WCDebugKit
//
//  Created by wesley_chen on 2021/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WCMIMEType) {
    WCMIMETypeBmp,
    WCMIMETypeGif,
    WCMIMETypeHeic,
    WCMIMETypeHeif,
    WCMIMETypeIco,
    WCMIMETypeJpg,
    WCMIMETypePng,
    WCMIMETypeTtf,
};

@interface WDKFileTool : NSObject

/**
 Check a directory if exists

 @param path the path of directory
 @return YES if the directory exists, or NO if the directory not exists or it's a file
 */
+ (BOOL)directoryExistsAtPath:(NSString *)path;

+ (BOOL)checkImageFileExistsAtPath:(NSString *)path imageTypes:(NSArray<NSNumber *> *)imageTypes;

@end

NS_ASSUME_NONNULL_END
