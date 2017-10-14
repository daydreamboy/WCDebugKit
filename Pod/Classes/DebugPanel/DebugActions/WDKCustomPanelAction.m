//
//  WDKCustomPanelAction.m
//  Pods
//
//  Created by wesley chen on 16/10/20.
//
//

#import "WDKCustomPanelAction.h"
#import "WDKDebugPanel.h"
#import "WDKDebugPanel_Internal.h"

@interface WDKCustomPanelAction ()
@property (nonatomic, copy) void (^customPanelBlock)(UIViewController *mainPanelViewController);
@end

@implementation WDKCustomPanelAction

+ (instancetype)actionWithName:(NSString*)name customPanelBlock:(void(^)(UIViewController *mainPanelViewController))block {
    WDKCustomPanelAction *action = [WDKCustomPanelAction actionWithName:name actionBlock:nil];
    action.customPanelBlock = block;
    action.shouldDismissPanel = NO;
    
    return action;
}

- (void)doAction {
    if (self.customPanelBlock) {
        self.customPanelBlock((UIViewController *)[[WDKDebugPanel sharedPanel].navController.viewControllers firstObject]);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDKCustomPanelAction *actionCopy = [WDKCustomPanelAction actionWithName:self.name actionBlock:nil];
    actionCopy.customPanelBlock = self.customPanelBlock;
    actionCopy.shouldDismissPanel = self.shouldDismissPanel;
    
    return actionCopy;
}

@end
