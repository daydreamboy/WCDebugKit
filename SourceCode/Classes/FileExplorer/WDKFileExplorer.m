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
#import "WDKImageBrowserViewController.h"
#import "WDKDebugPanelGerenalViewController.h"
#import "WDKDebugPanelCellItem.h"
#import "WDKDebugGroup_Internal.h"
#import "WDKFileTool.h"
#import "WDKDataTool.h"

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

- (void)openPathWithViewController:(UIViewController *)viewController path:(NSString *)path {
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([[[path pathExtension] lowercaseString] isEqualToString:@"plist"] ||
        [[[path pathExtension] lowercaseString] isEqualToString:@"strings"] ||
        [[[path pathExtension] lowercaseString] isEqualToString:@"json"]) {
        WDKPlistViewController *vc = [[WDKPlistViewController alloc] initWithFilePath:path];
        [viewController.navigationController pushViewController:vc animated:YES];
    }
    else if ([WDKFileTool directoryExistsAtPath:path]) {
        WDKDirectoryBrowserViewController *vc = [[WDKDirectoryBrowserViewController alloc] initWithPath:path];
        [viewController.navigationController pushViewController:vc animated:YES];
    }
    else {
        NSData *data = [NSData dataWithContentsOfFile:path];
        WDKMIMETypeInfo *info = [WDKDataTool checkMIMETypeWithData:data type:WDKMIMETypeJpg];
        if (info) {
            NSMutableArray *images = [NSMutableArray array];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                [images addObject:image];
            }

            WDKImageBrowserViewController *vc = [[WDKImageBrowserViewController alloc] initWithImages:images index:0];
            [viewController.navigationController pushViewController:vc animated:YES];
        }
        else {
            WDKTextEditViewController *vc = [[WDKTextEditViewController alloc] initWithFilePath:path];
            [viewController.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)pushDirectoryBrowserViewControllerWithViewController:(UIViewController *)viewController path:(NSString *)path {
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    WDKDirectoryBrowserViewController *vc = [[WDKDirectoryBrowserViewController alloc] initWithPath:path];
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
        WDKDebugPanelCellItem *cellItem = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeDefault];
        cellItem.accessoryType = WDKDebugPanelCellAccessoryTypeDisclosureIndicator;
        
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pathItem.path isDirectory:&isDirectory];
        
        cellItem.swipeable = YES;
        cellItem.title = [pathItem.path lastPathComponent];
        cellItem.titleColor = exists ? (isDirectory ? [UIColor blueColor] : [UIColor blackColor]) : [UIColor redColor];
        cellItem.userInfo = pathItem;
        
        __weak typeof(cellItem) weak_item = cellItem;
        
        cellItem.selectAction = ^(UIViewController *viewController) {
            WDKPathItem *pathItem = weak_item.userInfo;
            [self openPathWithViewController:viewController path:pathItem.path];
        };
        
        cellItem.deleteAction = ^{
            [WDKDirectoryBrowserViewController deleteFavoritePathItemWithItem:weak_item.userInfo];
        };
        
        [arrM addObject:cellItem];
    }
    
    return [@[arrM] mutableCopy];
}

@end
