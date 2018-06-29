//
//  WDKViewInspector.m
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import "WDKViewInspector.h"
#import "WDKUserInterfaceInspector.h"
#import "WDKDebugGroup_Internal.h"
#import "WDKViewExplorerWindow.h"
#import "WCObjCRuntimeUtility.h"

@implementation WDKViewInspector

- (WDKDebugGroup *)wdk_debugGroup {
    
    NSMutableArray *arrM = [NSMutableArray array];
    WDKDebugAction *action;
    
    action = [WDKToggleAction actionWithName:NSLocalizedString(@"Slow Animations", nil) enabled:[WDKUserInterfaceInspector sharedInstance].slowAnimationsEnabled toggleBlock:^(BOOL enabled) {
        [[WDKUserInterfaceInspector sharedInstance] setSlowAnimationsEnabled:enabled];
    }];
    [arrM addObject:action];
    
    action = [WDKToggleAction actionWithName:NSLocalizedString(@"Show View Frames", nil) enabled:[WDKUserInterfaceInspector sharedInstance].colorizedViewBorderEnabled toggleBlock:^(BOOL enabled) {
        [[WDKUserInterfaceInspector sharedInstance] setColorizedViewBorderEnabled:enabled];
    }];
    [arrM addObject:action];
    
    action = [WDKDebugAction actionWithName:NSLocalizedString(@"View Explorer", nil) actionBlock:^{
        [WDKViewExplorerWindow enableViewExplorerWindow:YES];
    }];
    [arrM addObject:action];
    
    action = [WDKToggleAction actionWithName:NSLocalizedString(@"Show Touch", nil) enabled:[WDKUserInterfaceInspector sharedInstance].colorizedViewBorderEnabled toggleBlock:^(BOOL enabled) {
        [[WDKUserInterfaceInspector sharedInstance] setColorizedViewBorderEnabled:enabled];
    }];
    [arrM addObject:action];
    
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:NSLocalizedString(@"UI检查器", nil) actions:arrM];
    group.nameColor = [UIColor brownColor];
    
    return group;
}

@end
