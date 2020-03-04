//
//  WDKMobileProvisionTool.m
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import "WDKMobileProvisionTool.h"

@implementation WDKMobileProvisionTool

+ (NSDictionary *)mobileprovisionInfo {
    static NSDictionary *infoDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
        // NSISOLatin1 keeps the binary wrapper from being parsed as unicode and dropped as invalid
        NSString *binaryString = [NSString stringWithContentsOfFile:provisioningPath encoding:NSISOLatin1StringEncoding error:NULL];
        NSString *plistString = nil;
        
        if (binaryString.length) {
            NSScanner *scanner = [NSScanner scannerWithString:binaryString];
            BOOL hasStart = [scanner scanUpToString:@"<plist" intoString:nil];
            if (hasStart) {
                BOOL hasEnd = [scanner scanUpToString:@"</plist>" intoString:&plistString];
                plistString = hasEnd ? [NSString stringWithFormat:@"%@</plist>", plistString] : nil;
            }
            
            if (plistString) {
                NSData *plistData = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
                NSError *error = nil;
                infoDict = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:&error];
            }
        }
    });
    
    return infoDict;
}

+ (NSString *)appReleaseMode {
    NSDictionary *info = [self mobileprovisionInfo];
    
    if (!info.count) {
#if TARGET_IPHONE_SIMULATOR
        return @"Simulator";
#else
        return @"AppStore";
#endif
    }
    else if ([info[@"ProvisionsAllDevices"] boolValue]) {
        return @"Enterpise";
    }
    else if ([info[@"ProvisionedDevices"] count] > 0) {
        NSDictionary *entitlements = info[@"Entitlements"];
        return [entitlements[@"get-task-allow"] boolValue] ? @"Development" : @"AdHoc";
    }
    else {
        return @"Unknown";
    }
}

+ (NSString *)appIDName {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"AppIDName"] ?: @"(null)";
}

+ (NSString *)appIDPrefix {
    NSDictionary *info = [self mobileprovisionInfo];
    return [info[@"ApplicationIdentifierPrefix"] firstObject] ?: @"(null)";
}

+ (NSString *)entitlementsAPSEnv {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"aps-environment"] ?: @"(null)";
}

+ (NSString *)entitlementsAppID {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"application-identifier"] ?: @"(null)";
}

+ (NSString *)entitlementsSiriEnabled {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"com.apple.developer.siri"] ? @"YES" : @"NO";
}

+ (NSString *)entitlementsTeamID {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"com.apple.developer.team-identifier"] ?: @"(null)";
}

+ (NSString *)entitlementsDebugEnabled {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"get-task-allow"] ? @"YES": @"NO";
}

+ (NSArray<NSString *> *)entitlementsAppGroups {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"com.apple.security.application-groups"];
}

+ (NSArray<NSString *> *)entitlementsKeychainSharingBundleIDs {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"keychain-access-groups"];
}

+ (NSString *)provisionName {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Name"] ?: @"(null)";
}

+ (NSString *)provisionExpirationDate {
    NSDictionary *info = [self mobileprovisionInfo];
    return [info[@"ExpirationDate"] descriptionWithLocale:[NSLocale currentLocale]] ?: @"(null)";
}

+ (NSString *)teamName {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"TeamName"] ?: @"(null)";
}

+ (NSString *)UUID {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"UUID"] ?: @"(null)";
}

@end
