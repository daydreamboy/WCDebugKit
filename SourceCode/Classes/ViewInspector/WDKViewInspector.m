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
#import "WDKScreenAdapter.h"

#define SHOW_ALERT(title, msg, cancel, dismissCompletion) \
\
do { \
    if ([UIAlertController class]) { \
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:(title) message:(msg) preferredStyle:UIAlertControllerStyleAlert]; \
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:(cancel) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { \
            dismissCompletion; \
        }]; \
        [alert addAction:cancelAction]; \
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil]; \
    } \
} while (0)

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
    
    [group addAction:[WDKEnumAction actionWithName:@"Screen Adpater" title:@"选择适配的机型屏幕" subtitle:@"选择后将自动重启应用" enums:[[WDKScreenAdapter sharedInstance] deviceModels] index:[WDKScreenAdapter sharedInstance].fakedDeviceModel enumBlock:^(NSUInteger selectedIndex) {
        [[WDKScreenAdapter sharedInstance] changeFakedDeviceModel:selectedIndex];
        
        exit(0);
    }]];
    
    return group;
}

@end
