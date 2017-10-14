//
//  AppInfoDebugActions.m
//  WCDebugKit
//
//  Created by wesley chen on 16/10/17.
//  Copyright © 2016年 wesley_chen. All rights reserved.
//

#import "WDKAppInfoViewer.h"

#import "WDKDebugPanelCellItem.h"
#import "WDKDebugPanelSectionItem.h"
#import "WDKDebugPanelGerenalViewController.h"
#import "WDKDebugGroup_Internal.h"

#define wdk_tagColor        [UIColor orangeColor]
#define wdk_versionColor    [UIColor blueColor]
#define wdk_branchColor     [UIColor greenColor]
#define wdk_commitColor     [UIColor magentaColor]
#define wdk_fromColor       [UIColor cyanColor]

@implementation WDKAppInfoViewer

- (WDKDebugGroup *)wdk_debugGroup {
    
    WDKCustomPanelAction *action1 = [WDKCustomPanelAction actionWithName:NSLocalizedString(@"标识符", nil) customPanelBlock:^(UIViewController *panelViewController) {
        WDKDebugPanelGerenalViewController *vc = [WDKDebugPanelGerenalViewController new];
        vc.listData = [self createIdentifiersList];
        vc.listSection = [self createSectionFooterItemsWithListData:vc.listData];
        vc.title = NSLocalizedString(@"标识符", nil);
        [panelViewController.navigationController pushViewController:vc animated:YES];
    }];
    action1.desc = @"";
    
    WDKCustomPanelAction *action2 = [WDKCustomPanelAction actionWithName:NSLocalizedString(@"版本", nil) customPanelBlock:^(UIViewController *panelViewController) {
        WDKDebugPanelGerenalViewController *vc = [WDKDebugPanelGerenalViewController new];
        vc.listData = [self createVersionsList];
        vc.listSection = [self createSectionItemsForVersionWithListData:vc.listData];
        vc.title = NSLocalizedString(@"版本", nil);
        [panelViewController.navigationController pushViewController:vc animated:YES];
    }];
    action2.desc = NSLocalizedString(@"App和SDK的版本", nil);
    
    WDKCustomPanelAction *action3 = [WDKCustomPanelAction actionWithName:NSLocalizedString(@"预编译宏", nil) customPanelBlock:^(UIViewController *panelViewController) {
        WDKDebugPanelGerenalViewController *vc = [WDKDebugPanelGerenalViewController new];
        vc.listData = [self createMacrosList];
        vc.listSection = [self createSectionFooterItemsWithListData:vc.listData];
        vc.title = NSLocalizedString(@"预编译宏", nil);
        [panelViewController.navigationController pushViewController:vc animated:YES];
    }];
    
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:NSLocalizedString(@"App信息查看", nil) actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[action1, action2, action3];
    }];
    group.nameColor = [UIColor brownColor];
    
    return group;
}

#pragma mark

- (NSMutableArray<NSMutableArray<WDKDebugPanelCellItem*> *> *)createMacrosList {
    WDKDebugPanelCellItem *item1 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item1.title = @"DEBUG";
#if DEBUG
    item1.subtitle = @"On";
#else
    item1.subtitle = @"Off";
#endif
    
    WDKDebugPanelCellItem *item2 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item2.title = @"NDEBUG";
#if NDEBUG
    item2.subtitle = @"On";
#else
    item2.subtitle = @"Off";
#endif
    
    WDKDebugPanelCellItem *item3 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item3.title = @"COCOAPODS";
#if COCOAPODS
    item3.subtitle = @"On";
#else
    item3.subtitle = @"Off";
#endif
    /*
    WDKDebugPanelCellItem *item4 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item4.title = @"SD_WEBP";
#if SD_WEBP
    item4.subtitle = @"On";
#else
    item4.subtitle = @"Off";
#endif
   
    WDKDebugPanelCellItem *item5 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item5.title = @"GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS";
#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
    item5.subtitle = @"On";
#else
    item5.subtitle = @"Off";
#endif
    */
    
    WDKDebugPanelCellItem *item6 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item6.title = @"NS_BLOCK_ASSERTIONS";
#if NS_BLOCK_ASSERTIONS
    item6.subtitle = @"On";
#else
    item6.subtitle = @"Off";
#endif
    
    return [@[
             [@[item1, item2, item3, item6] mutableCopy]
             ] mutableCopy];
}

- (NSMutableArray<NSMutableArray<WDKDebugPanelCellItem*> *> *)createIdentifiersList {
    // Section 1
    WDKDebugPanelCellItem *item1 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item1.title = @"Bundle ID";
    item1.subtitle = [[self.class plistInfo] objectForKey:@"CFBundleIdentifier"];
    item1.alertMessage = [item1.subtitle copy];
    
    WDKDebugPanelCellItem *item2 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item2.title = @"Bundle Name";
    item2.subtitle = [[self.class plistInfo] objectForKey:@"CFBundleName"];
    item2.alertMessage = [item2.subtitle copy];
    
    WDKDebugPanelCellItem *item3 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item3.title = @"Bundle Display Name";
    item3.subtitle = [[self.class plistInfo] objectForKey:@"CFBundleDisplayName"];
    item3.alertMessage = [item3.subtitle copy];
    
    WDKDebugPanelCellItem *item4 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item4.title = @"Build Number";
    item4.subtitle = [[self.class plistInfo] objectForKey:@"CFBundleVersion"];
    item4.alertMessage = [item4.subtitle copy];
    
    WDKDebugPanelCellItem *item5 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item5.title = @"Minimum supported iOS Version";
    item5.subtitle = [[self.class plistInfo] objectForKey:@"MinimumOSVersion"];
    item5.alertMessage = [item5.subtitle copy];
    
    WDKDebugPanelCellItem *item6 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item6.title = @"IdentifierForVendor";
    item6.subtitle = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    item6.alertMessage = [item6.subtitle copy];
    
    // Section 2
    WDKDebugPanelCellItem *section2Item;
    NSMutableArray *arrM = [NSMutableArray array];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"App Release Mode";
    section2Item.subtitle = [self.class appReleaseMode];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"AppID Name";
    section2Item.subtitle = [self.class appIDName];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"AppID Prefix";
    section2Item.subtitle = [self.class appIDPrefix];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Entitlements - Apple Push";
    section2Item.subtitle = [self.class entitlementsAPSEnv].length ? [self.class entitlementsAPSEnv] : @"(not enabled)";
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Entitlements - App ID";
    section2Item.subtitle = [self.class entitlementsAppID];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Entitlements - Siri Enabled";
    section2Item.subtitle = [self.class entitlementsSiriEnabled];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Entitlements - TeamID";
    section2Item.subtitle = [self.class entitlementsTeamID];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Entitlements - Debug Enabled";
    section2Item.subtitle = [self.class entitlementsDebugEnabled];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Entitlements - App Groups";
    section2Item.subtitle = [self.class entitlementsAppGroups].count ? @"(click to see more)" : @"(not enabled)";
    section2Item.alertMessage = [self.class entitlementsAppGroups].count ? [[self.class entitlementsAppGroups] componentsJoinedByString:@"\n"]: @"(not enabled)";
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Entitlements - Keychain Sharing";
    section2Item.subtitle = @"(click to see more)";
    section2Item.alertMessage = [[self.class entitlementsKeychainSharingBundleIDs] componentsJoinedByString:@"\n"];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Provision Profile Name";
    section2Item.subtitle = [self.class provisionName];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Provision Profile Expire Date";
    section2Item.subtitle = [self.class provisionExpirationDate];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"Team Name";
    section2Item.subtitle = [self.class teamName];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    section2Item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    section2Item.title = @"UUID";
    section2Item.subtitle = [self.class UUID];
    section2Item.alertMessage = [section2Item.subtitle copy];
    [arrM addObject:section2Item];
    
    return [@[
             [@[item1, item2, item3, item4, item5, item6] mutableCopy],
             arrM
             ] mutableCopy];
}

- (NSMutableArray<NSMutableArray<WDKDebugPanelCellItem*> *> *)createVersionsList {
    
    NSMutableArray *section1 = [NSMutableArray array];
    NSMutableArray *section2 = [NSMutableArray array];
    
    WDKDebugPanelCellItem *item1 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item1.title = @"App Version";
    item1.subtitle = [[self.class plistInfo] objectForKey:@"CFBundleShortVersionString"];
    [section1 addObject:item1];
    
    WDKDebugPanelCellItem *item2 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
    item2.title = @"WDKDebugPanel";
    item2.subtitle = WDKDebugPanel_PodVersion;
    [section1 addObject:item2];
    
    NSString *filename = @"tag_summary.json";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WCDebugKit" ofType:@"bundle"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, filename];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *dictM = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@", dictM);
    
    if ([dictM isKindOfClass:[NSDictionary class]]) {
        NSString *cocoaPodsKey = @"COCOAPODS";
        NSDictionary *attributes = dictM[cocoaPodsKey];
        if ([attributes isKindOfClass:[NSDictionary class]]) {
            WDKDebugPanelCellItem *item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
            item.title = cocoaPodsKey;
            item.subtitle = attributes[@"version"];
            
            [section1 addObject:item];
            
            [dictM removeObjectForKey:cocoaPodsKey];
        }
        
        NSArray *sortedKeys = [[dictM allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (NSInteger i = 0; i < sortedKeys.count; i++) {
            NSString *key = sortedKeys[i];
            NSDictionary *attributes = dictM[key];
            
            WDKDebugPanelCellItem *item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
            item.title = key;
            [self configureItem:item attributes:attributes];
            
            [section2 addObject:item];
        }
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"请检查", nil), filename];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"读取配置文件出错", nil) message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"好的", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    NSMutableArray *allVersions = [NSMutableArray array];
    [allVersions addObject:section1];
    
    if (section2.count) {
        [allVersions addObject:section2];
    }
    
    return allVersions;
}

- (void)configureItem:(WDKDebugPanelCellItem *)item  attributes:(NSDictionary *)attributes {
    
    if ([attributes isKindOfClass:[NSDictionary class]]) {
        if ([attributes[@"tag"] length]) {
            item.subtitle = attributes[@"tag"];
            item.subtitleColor = wdk_tagColor;
        }
        else if ([attributes[@"version"] length]) {
            item.subtitle = attributes[@"version"];
            item.subtitleColor = wdk_versionColor;
        }
        else if ([attributes[@"branch"] length]) {
            item.subtitle = attributes[@"branch"];
            item.subtitleColor = wdk_branchColor;
        }
        else if ([attributes[@"commit"] length]) {
            item.subtitle = attributes[@"commit"];
            item.subtitleColor = wdk_commitColor;
        }
        else if ([attributes[@"from"] length]) {
            item.subtitle = attributes[@"from"];
            item.subtitleColor = wdk_fromColor;
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:attributes options:NSJSONWritingPrettyPrinted error:nil];
        if (jsonData) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            // handle escaped characters
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            item.alertMessage = jsonString;
        }
    }
}

#pragma mark - 

#define FOOTER_HEIGHT 30.0f

// Only has footer view
- (NSArray<WDKDebugPanelSectionItem *> *)createSectionFooterItemsWithListData:(NSArray<NSArray<WDKDebugPanelCellItem*> *> *)listData {
    
    NSMutableArray *sectionItems = [NSMutableArray array];
    
    for (NSInteger i = 0; i < listData.count; i++) {
        WDKDebugPanelSectionItem *item = [WDKDebugPanelSectionItem new];
        item.sectionFooterViewHeight = FOOTER_HEIGHT;
        item.sectionFooterView = ^UIView *(NSInteger section) {
            
            NSArray *items = listData[section];
            NSString *footerString = [NSString stringWithFormat:@"共计%ld项", (long)items.count];
            
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, FOOTER_HEIGHT)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 20)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:12.0f];
            label.text = footerString;
            
            [footerView addSubview:label];
            
            return footerView;
        };
        
        [sectionItems addObject:item];
    }
    
    return sectionItems;
}

// Only for version list
- (NSArray<WDKDebugPanelSectionItem *> *)createSectionItemsForVersionWithListData:(NSArray<NSArray<WDKDebugPanelCellItem*> *> *)listData {
    
    NSMutableArray *sectionItems = [NSMutableArray array];
    
    for (NSInteger i = 0; i < listData.count; i++) {
        WDKDebugPanelSectionItem *item = [WDKDebugPanelSectionItem new];
        item.sectionFooterViewHeight = FOOTER_HEIGHT;
        item.sectionFooterView = ^UIView *(NSInteger section) {
            
            NSArray *items = listData[section];
            NSString *footerString = [NSString stringWithFormat:@"共计%ld项", (long)items.count];
            
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, FOOTER_HEIGHT)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 20)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:12.0f];
            label.text = footerString;
            
            [footerView addSubview:label];
            
            return footerView;
        };
        
        if (i == 1) {
            __block NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@""];
            
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc] initWithString:@"● tag\t"];
            [attr1 setAttributes:@{ NSForegroundColorAttributeName: wdk_tagColor } range:NSMakeRange(0, 1)];
            [attrString appendAttributedString:attr1];
            
            NSMutableAttributedString *attr2 = [[NSMutableAttributedString alloc] initWithString:@"● version\t"];
            [attr2 setAttributes:@{ NSForegroundColorAttributeName: wdk_versionColor } range:NSMakeRange(0, 1)];
            [attrString appendAttributedString:attr2];
            
            NSMutableAttributedString *attr3 = [[NSMutableAttributedString alloc] initWithString:@"● branch\t"];
            [attr3 setAttributes:@{ NSForegroundColorAttributeName: wdk_branchColor } range:NSMakeRange(0, 1)];
            [attrString appendAttributedString:attr3];
            
            NSMutableAttributedString *attr4 = [[NSMutableAttributedString alloc] initWithString:@"● commit\t"];
            [attr4 setAttributes:@{ NSForegroundColorAttributeName: wdk_commitColor } range:NSMakeRange(0, 1)];
            [attrString appendAttributedString:attr4];
            
            NSMutableAttributedString *attr5 = [[NSMutableAttributedString alloc] initWithString:@"● none\t"];
            [attr5 setAttributes:@{ NSForegroundColorAttributeName: wdk_fromColor } range:NSMakeRange(0, 1)];
            [attrString appendAttributedString:attr5];
            
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            CGRect textRect = [attrString boundingRectWithSize:CGSizeMake(screenSize.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            
            __block CGFloat height = ceil(textRect.size.height) + 10;
            
            item.sectionHeaderViewHeight = height;
            item.sectionHeaderView = ^UIView *(NSInteger section) {
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, height)];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:14.0f];
                label.attributedText = attrString;

                return label;
            };
        }
        
        [sectionItems addObject:item];
    }
    
    return sectionItems;
}

#pragma mark - Utility

#pragma mark > Info.plist

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

#pragma mark > embedded.mobileprovision

+ (NSDictionary *)mobileprovisionInfo {
    static NSDictionary *infoDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
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
    return info[@"AppIDName"];
}

+ (NSString *)appIDPrefix {
    NSDictionary *info = [self mobileprovisionInfo];
    return [info[@"ApplicationIdentifierPrefix"] firstObject];
}

+ (NSString *)entitlementsAPSEnv {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"aps-environment"];
}

+ (NSString *)entitlementsAppID {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"application-identifier"];
}

+ (NSString *)entitlementsSiriEnabled {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"com.apple.developer.siri"] ? @"YES" : @"NO";
}

+ (NSString *)entitlementsTeamID {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"Entitlements"][@"com.apple.developer.team-identifier"];
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
    return info[@"Name"];
}

+ (NSString *)provisionExpirationDate {
    NSDictionary *info = [self mobileprovisionInfo];
    return [info[@"ExpirationDate"] descriptionWithLocale:[NSLocale currentLocale]];
}

+ (NSString *)teamName {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"TeamName"];
}

+ (NSString *)UUID {
    NSDictionary *info = [self mobileprovisionInfo];
    return info[@"UUID"];
}

@end
