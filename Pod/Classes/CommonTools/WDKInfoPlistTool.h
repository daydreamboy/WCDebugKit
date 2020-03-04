//
//  WDKInfoPlistTool.h
//  Pods-WCDebugKit_Example
//
//  Created by wesley_chen on 19/01/2018.
//

#import <Foundation/Foundation.h>

@interface WDKInfoPlistTool : NSObject

+ (NSDictionary *)plistInfo;

+ (NSString *)bundleID;
+ (NSString *)bundleName;
+ (NSString *)bundleDisplayName;
+ (NSString *)buildNumber;
+ (NSString *)minimumSupportediOSVersion;

@end
