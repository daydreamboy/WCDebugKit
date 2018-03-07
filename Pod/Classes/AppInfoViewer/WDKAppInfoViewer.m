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

#import "WCMobileProvisionTool.h"
#import "WCInfoPlistTool.h"
#import "WCNSObjectTool.h"

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
    
    WDKSubMenuAction *action4 = [WDKSubMenuAction actionWithName:NSLocalizedString(@"Class Explorer", nil) subMenuBlock:^NSArray<WDKDebugGroup *> *{
        return [self createClassList];
    }];
    
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:NSLocalizedString(@"App信息查看", nil) actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[action1, action2, action3, action4];
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

#define kTitle          @"title"
#define kSubtitle       @"subtitle"
#define kAlertMessage   @"alertMessage"

#define NILABLE(var)                                                                                        \
    ({                                                                                                      \
        id ret;                                                                                             \
        static NSString *__nilString__ = @"(null)";                                                         \
        if (var == nil) {                                                                                   \
            ret = __nilString__;                                                                            \
        }                                                                                                   \
        else if ([var isKindOfClass:[NSString class]] && [(NSString *)var isEqualToString:__nilString__]) { \
            ret = nil;                                                                                      \
        }                                                                                                   \
        else {                                                                                              \
            ret = var;                                                                                      \
        }                                                                                                   \
        ret;                                                                                                \
    })


- (NSMutableArray<NSMutableArray<WDKDebugPanelCellItem*> *> *)createIdentifiersList {
    
    // Section 1
    NSArray<NSDictionary *> *section1 = @[
        @{ kTitle: @"Bundle ID", kSubtitle: [WCInfoPlistTool bundleID], },
        @{ kTitle: @"Bundle Name", kSubtitle: [WCInfoPlistTool bundleName], },
        @{ kTitle: @"Bundle Display Name", kSubtitle: [WCInfoPlistTool bundleDisplayName], },
        @{ kTitle: @"Build Number", kSubtitle: [WCInfoPlistTool buildNumber], },
        @{ kTitle: @"Minimum supported iOS Version", kSubtitle: [WCInfoPlistTool minimumSupportediOSVersion], },
        @{ kTitle: @"IdentifierForVendor", kSubtitle: [[UIDevice currentDevice] identifierForVendor].UUIDString, },
    ];
    
    // Section 2
    NSArray<NSDictionary *> *section2 = @[
        @{ kTitle: @"App Release Mode", kSubtitle: [WCMobileProvisionTool appReleaseMode], },
        @{ kTitle: @"AppID Name", kSubtitle: [WCMobileProvisionTool appIDName], },
        @{ kTitle: @"AppID Prefix", kSubtitle: [WCMobileProvisionTool appIDPrefix], },
        @{ kTitle: @"Entitlements - Apple Push", kSubtitle: ([WCMobileProvisionTool entitlementsAPSEnv].length ? [WCMobileProvisionTool entitlementsAPSEnv] : @"(not enabled)"), },
        @{ kTitle: @"Entitlements - App ID", kSubtitle: [WCMobileProvisionTool entitlementsAppID], },
        @{ kTitle: @"Entitlements - Siri Enabled", kSubtitle: [WCMobileProvisionTool entitlementsSiriEnabled], },
        @{ kTitle: @"Entitlements - TeamID", kSubtitle: [WCMobileProvisionTool entitlementsTeamID], },
        @{ kTitle: @"Entitlements - Siri Enabled", kSubtitle: [WCMobileProvisionTool entitlementsSiriEnabled], },
        @{ kTitle: @"Entitlements - Debug Enabled", kSubtitle: [WCMobileProvisionTool entitlementsDebugEnabled], },
        @{ kTitle: @"Entitlements - App Groups", kSubtitle: ([WCMobileProvisionTool entitlementsAppGroups].count ? @"(click to see more)" : @"(not enabled)"), kAlertMessage: ([WCMobileProvisionTool entitlementsAppGroups].count ? [[WCMobileProvisionTool entitlementsAppGroups] componentsJoinedByString:@"\n"]: @"(not enabled)") },
        @{ kTitle: @"Entitlements - Keychain Sharing", kSubtitle: @"(click to see more)", kAlertMessage: NILABLE([[WCMobileProvisionTool entitlementsKeychainSharingBundleIDs] componentsJoinedByString:@"\n"]) },
        @{ kTitle: @"Provision Profile Name", kSubtitle: [WCMobileProvisionTool provisionName], },
        @{ kTitle: @"Provision Profile Expire Date", kSubtitle: [WCMobileProvisionTool provisionExpirationDate], },
        @{ kTitle: @"Team Name", kSubtitle: [WCMobileProvisionTool teamName], },
        @{ kTitle: @"UUID", kSubtitle: [WCMobileProvisionTool UUID], },
    ];
    
    NSArray * (^convertDictionaryToItem)(NSArray<NSDictionary *> *) = ^NSArray*(NSArray<NSDictionary *> *arr) {
        
        NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:arr.count];
        
        for (NSDictionary *dict in arr) {
            WDKDebugPanelCellItem *item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeValue1];
            item.title = dict[kTitle];
            item.subtitle = dict[kSubtitle];
            item.alertMessage = dict[kAlertMessage] == nil ? [item.subtitle copy] : dict[kAlertMessage];
            
            [arrM addObject:item];
        }
        
        return arrM;
    };
    
    NSArray *section1Items = convertDictionaryToItem(section1);
    NSArray *section2Items = convertDictionaryToItem(section2);
    
    return [@[
             section1Items, section2Items
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
    if (!data) {
        return nil;
    }
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

- (NSArray<WDKDebugGroup *> *)createClassList {
    NSArray<NSString *> *classes = [WCNSObjectTool allClasses];
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:classes.count];
    for (NSString *className in classes) {
        WDKSubMenuAction *action = [WDKSubMenuAction actionWithName:className subMenuBlock:^NSArray<WDKDebugGroup *> *{
            
            NSMutableArray<WDKDebugAction *> *(^convertToActions)(NSArray *) = ^NSMutableArray<WDKDebugAction *> *(NSArray<NSString *> *arr) {
                
                NSMutableArray<WDKDebugAction *> *actions = [NSMutableArray arrayWithCapacity:arr.count];
                
                for (NSString *title in arr) {
                    WDKDebugAction *action = [WDKDebugAction actionWithName:title actionBlock:nil];
                    action.titleFont = [UIFont systemFontOfSize:12];
                    action.shouldDismissPanel = NO;
                    [actions addObject:action];
                }
                
                return actions;
            };
            
            WDKDebugGroup *propertiesGroup = [WDKDebugGroup groupWithName:@"@property" actionsBlock:^NSArray<WDKDebugAction *> *{
                NSArray *properties = [WCNSObjectTool propertiesWithClassName:className];
                return convertToActions(properties);
            }];
            
            WDKDebugGroup *ivarsGroup = [WDKDebugGroup groupWithName:@"ivars" actionsBlock:^NSArray<WDKDebugAction *> *{
                NSArray *ivars = [WCNSObjectTool ivarsWithClassName:className];
                return convertToActions(ivars);
            }];
            
            WDKDebugGroup *instanceMethodsGroup = [WDKDebugGroup groupWithName:@"-instanceMethods" actionsBlock:^NSArray<WDKDebugAction *> *{
                NSArray *instanceMethods = [WCNSObjectTool instanceMethodsWithClassName:className];
                return convertToActions(instanceMethods);
            }];
            
            WDKDebugGroup *classMethodsGroup = [WDKDebugGroup groupWithName:@"+classMethods" actionsBlock:^NSArray<WDKDebugAction *> *{
                NSArray *classMethods = [WCNSObjectTool classMethodsWithClassName:className];
                return convertToActions(classMethods);
            }];
            
            WDKDebugGroup *protocolsGroup = [WDKDebugGroup groupWithName:@"@protocols" actionsBlock:^NSArray<WDKDebugAction *> *{
                NSArray *protocols = [WCNSObjectTool protocolsWithClassName:className];
                
                NSMutableArray<WDKSubMenuAction *> *actions = [NSMutableArray arrayWithCapacity:protocols.count];
                
                for (NSString *protocol in protocols) {
                    NSString *firstLevelProtocol = [[protocol componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<,> "]] firstObject];
                    
                    WDKSubMenuAction *action = [WDKSubMenuAction actionWithName:protocol subMenuBlock:^NSArray<WDKDebugGroup *> *{
                        WDKDebugGroup *section1 = [WDKDebugGroup groupWithName:@"required methods" actionsBlock:^NSArray<WDKDebugAction *> *{
                            NSArray *requiredMethods = [WCNSObjectTool protocolRequiredMethodsWithProtocolName:firstLevelProtocol className:className];
                            return convertToActions(requiredMethods);
                        }];
                        
                        WDKDebugGroup *section2 = [WDKDebugGroup groupWithName:@"optional methods" actionsBlock:^NSArray<WDKDebugAction *> *{
                            NSArray *optionalMethods = [WCNSObjectTool protocolOptionalMethodsWithProtocolName:firstLevelProtocol className:className];
                            return convertToActions(optionalMethods);
                        }];
                        
                        WDKDebugGroup *section3 = [WDKDebugGroup groupWithName:@"properties" actionsBlock:^NSArray<WDKDebugAction *> *{
                            NSArray *properties = [WCNSObjectTool protocolPropertiesWithProtocolName:firstLevelProtocol className:className];
                            return convertToActions(properties);
                        }];
                        
                        return @[section1, section2, section3];
                    }];
                    action.titleFont = [UIFont systemFontOfSize:12];
                    action.shouldDismissPanel = NO;
                    [actions addObject:action];
                }
                
                return actions;
            }];
            
            WDKDebugGroup *parentClassesGroup = [WDKDebugGroup groupWithName:@"class hierarchy" actionsBlock:^NSArray<WDKDebugAction *> *{
                NSMutableArray *classNames = [NSMutableArray arrayWithArray:[WCNSObjectTool parentClassHierarchyWithClassName:className]];
                
                for (NSInteger i = 0; i < classNames.count; i++) {
                    
                    NSMutableString *indent = [[NSMutableString alloc] initWithString:@""];
                    for (NSInteger j = 0; j < i; j++) {
                        [indent appendString:@"  "];
                    }
                    
                    classNames[i] = [NSString stringWithFormat:@"%@ - %@", indent, classNames[i]];
                }
                
                return convertToActions(classNames);
            }];
            
            return @[propertiesGroup, ivarsGroup, instanceMethodsGroup, classMethodsGroup, protocolsGroup, parentClassesGroup];
        }];
        action.shouldDismissPanel = NO;
        [arrM addObject:action];
    }
    
    return @[[WDKDebugGroup groupWithName:@"Class Info" actions:arrM]];
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
#define HEADER_HEIGHT 20.0f

- (NSArray<WDKDebugPanelSectionItem *> *)createSectionFooterItemsWithListData:(NSArray<NSArray<WDKDebugPanelCellItem*> *> *)listData {
    
    NSMutableArray *sectionItems = [NSMutableArray array];
    
    for (NSInteger i = 0; i < listData.count; i++) {
        WDKDebugPanelSectionItem *item = [WDKDebugPanelSectionItem new];
        item.sectionFooterViewHeight = FOOTER_HEIGHT;
        item.sectionHeaderViewHeight = HEADER_HEIGHT;
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
        item.sectionHeaderViewHeight = HEADER_HEIGHT;
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

@end
