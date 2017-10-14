//
//  WDKDebugPluginsInfo.m
//  WDKDebugKit
//
//  Created by wesley chen on 16/11/26.
//  Copyright © 2016年 wesley_chen. All rights reserved.
//

#import "WDKDebugPluginsInfo.h"

//#import <WCDebugKit.h> // 虽然没有用处，可以删掉#import，用于提醒
#import <WCDebugKit/WCDebugKit.h>

@implementation WDKDebugPluginsInfo

/*
- (NSArray<NSString *> *)wdk_pluginsClasses {
    return @[
             @"NetworkUtility",
             ];
}
 */

- (NSString *)wdk_pluginsPlistPath {
    return @"WDKDebugPlugins.bundle/plugin_tools.plist";
}

@end
