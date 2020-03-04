//
//  WDKInfoPlistTool.m
//  Pods-WCDebugKit_Example
//
//  Created by wesley_chen on 19/01/2018.
//

#import "WDKInfoPlistTool.h"

@implementation WDKInfoPlistTool

+ (NSDictionary *)plistInfo {
    static dispatch_once_t onceToken;
    static NSDictionary *info;
    dispatch_once(&onceToken, ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        info = dict ?: [NSBundle mainBundle].infoDictionary;
    });
    
    return info;
}

+ (NSString *)bundleID {
    return [[self plistInfo] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)bundleName {
    return [[self plistInfo] objectForKey:@"CFBundleName"];
}

+ (NSString *)bundleDisplayName {
    return [[self plistInfo] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)buildNumber {
    return [[self plistInfo] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)minimumSupportediOSVersion {
    return [[self plistInfo] objectForKey:@"MinimumOSVersion"];
}


@end
