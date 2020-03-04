//
//  WDKMobileProvisionTool.h
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import <Foundation/Foundation.h>

@interface WDKMobileProvisionTool : NSObject
+ (NSDictionary *)mobileprovisionInfo;

+ (NSString *)appReleaseMode;
+ (NSString *)appIDName;
+ (NSString *)appIDPrefix;
+ (NSString *)entitlementsAPSEnv;
+ (NSString *)entitlementsAppID;
+ (NSString *)entitlementsSiriEnabled;
+ (NSString *)entitlementsTeamID;
+ (NSString *)entitlementsDebugEnabled;
+ (NSArray<NSString *> *)entitlementsAppGroups;
+ (NSArray<NSString *> *)entitlementsKeychainSharingBundleIDs;
+ (NSString *)provisionName;
+ (NSString *)provisionExpirationDate;
+ (NSString *)teamName;
+ (NSString *)UUID;
@end
