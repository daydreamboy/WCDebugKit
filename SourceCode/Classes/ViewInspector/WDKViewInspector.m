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
#import "WDKRuntimeTool.h"
#import "WDKViewExplorerOverlayView.h"

@implementation WDKViewInspector

- (WDKDebugGroup *)wdk_debugGroup {
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:NSLocalizedString(@"UI检查器", nil)];
    group.nameColor = [UIColor brownColor];
    
    [group addAction:[WDKToggleAction actionWithName:NSLocalizedString(@"Slow Animations", nil) enabled:[WDKUserInterfaceInspector sharedInstance].slowAnimationsEnabled toggleBlock:^(BOOL enabled) {
        [[WDKUserInterfaceInspector sharedInstance] setSlowAnimationsEnabled:enabled];
    }]];
    
    [group addAction:[WDKToggleAction actionWithName:NSLocalizedString(@"Show View Frames", nil) enabled:[WDKUserInterfaceInspector sharedInstance].colorizedViewBorderEnabled toggleBlock:^(BOOL enabled) {
        [[WDKUserInterfaceInspector sharedInstance] setColorizedViewBorderEnabled:enabled];
    }]];
    
    [group addAction:[WDKDebugAction actionWithName:NSLocalizedString(@"View Explorer", nil) actionBlock:^{
        //[WDKViewExplorerWindow enableViewExplorerWindow:YES];
        [WDKViewExplorerOverlayView setEnabled:YES];
    }]];
    
    [group addAction:[WDKToggleAction actionWithName:NSLocalizedString(@"Show Touch", nil) enabled:[WDKUserInterfaceInspector sharedInstance].colorizedViewBorderEnabled toggleBlock:^(BOOL enabled) {
        [[WDKUserInterfaceInspector sharedInstance] setColorizedViewBorderEnabled:enabled];
    }]];
    
    return group;
}

@end
