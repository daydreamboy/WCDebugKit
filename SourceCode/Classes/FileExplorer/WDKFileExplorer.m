//
//  WDKFileExplorer.m
//  Pods
//
//  Created by wesley chen on 16/11/3.
//
//

#import "WDKFileExplorer.h"

#import "WDKDirectoryBrowserViewController.h"
#import "WDKTextEditViewController.h"
#import "WDKPlistViewController.h"
#import "WDKDebugPanelGerenalViewController.h"
#import "WDKDebugPanelCellItem.h"
#import "WDKDebugGroup_Internal.h"

@implementation WDKFileExplorer

- (WDKDebugGroup *)wdk_debugGroup {
    
    NSString *homePath = NSHomeDirectory();
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    
    NSString *appName = [bundlePath lastPathComponent];
    
    WDKCustomPanelAction *action1 = [WDKCustomPanelAction actionWithName:@"App Home文件夹" customPanelBlock:^(UIViewController *mainPanelViewController) {
        [self pushDirectoryBrowserViewControllerWithViewController:mainPanelViewController path:homePath];
    }];
    
    WDKCustomPanelAction *action2 = [WDKCustomPanelAction actionWithName:appName customPanelBlock:^(UIViewController *mainPanelViewController) {
        [self pushDirectoryBrowserViewControllerWithViewController:mainPanelViewController path:bundlePath];
    }];
    
    NSMutableArray *arrM = [NSMutableArray array];
    [arrM addObject:action1];
    [arrM addObject:action2];
    
    if ([self deviceJailBroken]) {
        WDKCustomPanelAction *action = [WDKCustomPanelAction actionWithName:@"/" customPanelBlock:^(UIViewController *mainPanelViewController) {
            [self pushDirectoryBrowserViewControllerWithViewController:mainPanelViewController path:@"/"];
        }];
        [arrM addObject:action];
    }
    
    WDKCustomPanelAction *action = [WDKCustomPanelAction actionWithName:NSLocalizedString(@"收藏夹", nil) customPanelBlock:^(UIViewController *panelViewController) {
        WDKDebugPanelGerenalViewController *vc = [WDKDebugPanelGerenalViewController new];
        vc.blockForViewWillAppear = ^(WDKDebugPanelGerenalViewController *weakViewController) {
            weakViewController.listData = [self createFavoritePaths];
        };
        vc.title = NSLocalizedString(@"收藏夹", nil);
        [panelViewController.navigationController pushViewController:vc animated:YES];
    }];
    [arrM addObject:action];
    
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:NSLocalizedString(@"文件浏览", nil) actions:arrM];
    group.nameColor = [UIColor brownColor];
    
    return group;
}

#pragma mark -

- (void)pushDirectoryBrowserViewControllerWithViewController:(UIViewController *)viewController path:(NSString *)path {
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    WDKDirectoryBrowserViewController *vc = [[WDKDirectoryBrowserViewController alloc] initWithPath:path];
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)pushTextEditViewControllerWithViewController:(UIViewController *)viewController path:(NSString *)path {
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    WDKTextEditViewController *vc = [[WDKTextEditViewController alloc] initWithFilePath:path];
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)pushPlistViewControllerWithViewController:(UIViewController *)viewController path:(NSString *)path {
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    WDKPlistViewController *vc = [[WDKPlistViewController alloc] initWithFilePath:path];
    [viewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark

- (BOOL)deviceJailBroken {
    NSArray *jailbreak_tool_pathes = @[
                                       @"/Applications/Cydia.app",
                                       @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                                       @"/bin/bash",
                                       @"/usr/sbin/sshd",
                                       @"/etc/apt"
                                       ];
    
    for (NSUInteger i = 0; i < jailbreak_tool_pathes.count; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:jailbreak_tool_pathes[i]]) {
            return YES;
        }
    }
    return NO;
}
                                    
- (NSMutableArray<NSMutableArray<WDKDebugPanelCellItem*> *> *)createFavoritePaths {
    
    NSMutableArray<WDKDebugPanelCellItem *> *arrM = [NSMutableArray array];
    
    NSArray<WDKPathItem *> *paths = [WDKDirectoryBrowserViewController favoritePathItems];
    
    for (WDKPathItem *pathItem in paths) {
        WDKDebugPanelCellItem *item = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeDefault];
        item.accessoryType = WDKDebugPanelCellAccessoryTypeDisclosureIndicator;
        
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pathItem.path isDirectory:&isDirectory];
        
        item.swipeable = YES;
        item.title = [pathItem.path lastPathComponent];
        item.titleColor = exists ? (isDirectory ? [UIColor blueColor] : [UIColor blackColor]) : [UIColor redColor];
        item.userInfo = pathItem;
        
        __weak typeof(item) weak_item = item;
        
        item.selectAction = ^(UIViewController *viewController) {
            if ([weak_item.titleColor isEqual:[UIColor blackColor]]) {
                if ([[[pathItem.path pathExtension] lowercaseString] isEqualToString:@"plist"] ||
                    [[[pathItem.path pathExtension] lowercaseString] isEqualToString:@"strings"] ||
                    [[[pathItem.path pathExtension] lowercaseString] isEqualToString:@"json"]) {
                    [self pushPlistViewControllerWithViewController:viewController path:pathItem.path];
                }
                else {
                    [self pushTextEditViewControllerWithViewController:viewController path:pathItem.path];
                }
            }
            else if ([weak_item.titleColor isEqual:[UIColor blueColor]]) {
                [self pushDirectoryBrowserViewControllerWithViewController:viewController path:pathItem.path];
            }
        };
        
        item.deleteAction = ^{
            [WDKDirectoryBrowserViewController deleteFavoritePathItemWithItem:weak_item.userInfo];
        };
        
        [arrM addObject:item];
    }
    
    return [@[arrM] mutableCopy];
}

@end
