//
//  WDKSubMenuAction.m
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import "WDKSubMenuAction.h"
#import "WDKDebugPanel.h"
#import "WDKDebugPanel_Internal.h"
#import "WDKDebugActionsViewController.h"

@interface WDKSubMenuAction ()
@property (nonatomic, copy) NSArray<WDKDebugGroup *> *(^subMenuBlock)(void);
@end

@implementation WDKSubMenuAction

+ (instancetype)actionWithName:(NSString*)name subMenuBlock:(NSArray<WDKDebugGroup *> *(^)(void))block {
    WDKSubMenuAction *action = [WDKSubMenuAction actionWithName:name actionBlock:nil];
    action.subMenuBlock = block;
    action.shouldDismissPanel = NO;
    
    return action;
}

- (void)doAction {
    if (self.subMenuBlock) {
        NSArray *actionGroups = self.subMenuBlock();
        
        WDKDebugActionsViewController *actionsViewController = [[WDKDebugActionsViewController alloc] init];
        actionsViewController.actionGroups = actionGroups;
        actionsViewController.flagPresentByInternal = YES;
        actionsViewController.title = self.name;
        actionsViewController.isSubMenu = YES;
        
        [[WDKDebugPanel sharedPanel].navController pushViewController:actionsViewController animated:YES];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDKSubMenuAction *actionCopy = [WDKSubMenuAction actionWithName:self.name actionBlock:nil];
    actionCopy.subMenuBlock = self.subMenuBlock;
    actionCopy.shouldDismissPanel = self.shouldDismissPanel;
    
    return actionCopy;
}

@end
