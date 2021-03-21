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

@end
