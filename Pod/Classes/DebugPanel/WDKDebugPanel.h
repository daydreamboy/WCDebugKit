//
//  WDKDebugPanel.h
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import <Foundation/Foundation.h>

#import "WDKDebugAction.h"
#import "WDKDebugGroup.h"

// Only For WDKDebugPluginsInfo Class
@protocol WDKDebugPluginsDataSource <NSObject>
@optional
// 下面两种注册方式，只能任选其一实现，如果都实现，wdk_pluginsClasses优先于wdk_pluginsPlistPath
- (NSArray<NSString *> *)wdk_pluginsClasses; /**< 插件类的名字构成的数组 */
- (NSString *)wdk_pluginsPlistPath; /**< plist文件在xxx.app在相对路径，e.g. @"WDKDebugPlugins.bundle/plugins_tools.plist" */
@end

@protocol WDKDebugPanelDataSource <NSObject>
- (WDKDebugGroup *)wdk_debugGroup;
@end

@interface WDKDebugPanel : NSObject

// 第一种方式：将3次点击手势安装到特定UIView上，用于唤起DebugPanel
+ (void)installDebugPanelWithView:(UIView *)view;
+ (void)installDebugPanelWithView:(UIView *)view tapCount:(NSUInteger)tapCount;

// 第二种方式：代码直接唤起DebugPanel
+ (void)showDebugPanel;

// 第三种方式：点击状态栏3次（默认方式）
// 是否将状态栏作为唤起DebugPanel的入口，默认是开启的
+ (void)enableStatusBarEntry:(BOOL)enabled;

// 将来会移除
+ (void)addDataSource:(id<WDKDebugPanelDataSource>)dataSource DEPRECATED_ATTRIBUTE;
+ (void)removeDataSource:(id<WDKDebugPanelDataSource>)dataSource DEPRECATED_ATTRIBUTE;

@end
