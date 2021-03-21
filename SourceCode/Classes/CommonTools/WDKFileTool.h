//
//  WDKFileTool.h
//  WCDebugKit
//
//  Created by wesley_chen on 2021/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WDKFileTool : NSObject

/**
 Check a directory if exists

 @param path the path of directory
 @return YES if the directory exists, or NO if the directory not exists or it's a file
 */
+ (BOOL)directoryExistsAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
