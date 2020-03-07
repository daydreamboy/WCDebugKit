//
//  WDKToogleAction.m
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import "WDKToggleAction.h"

@interface WDKToggleAction ()
@property (nonatomic, copy) void (^toggleBlock)(BOOL enabled);
@end

@implementation WDKToggleAction

+ (instancetype)actionWithName:(NSString *)name enabled:(BOOL)enabled toggleBlock:(void (^)(BOOL enabled))block {
    WDKToggleAction *action = [WDKToggleAction actionWithName:name actionBlock:nil];
    action.toggleBlock = block;
    action.shouldDismissPanel = NO;
    action.enabled = enabled;
    
    return action;
}

- (void)doAction {
    if (self.toggleBlock) {
        self.enabled = !self.enabled;
        self.toggleBlock(self.enabled);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDKToggleAction *actionCopy = [WDKToggleAction actionWithName:self.name actionBlock:nil];
    actionCopy.toggleBlock = self.toggleBlock;
    actionCopy.shouldDismissPanel = self.shouldDismissPanel;
    actionCopy.enabled = self.enabled;
    
    return actionCopy;
}

@end
