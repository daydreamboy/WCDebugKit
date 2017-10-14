//
//  WDKDebugAction.m
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import "WDKDebugAction.h"
#import "WDKDebugAction_Internal.h"

@interface WDKDebugAction ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) void (^actionBlock)(void);
@end

@implementation WDKDebugAction

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldDismissPanel = YES;
    }
    return self;
}

#pragma mark Public Methods

+ (instancetype)actionWithName:(NSString*)name actionBlock:(void(^)(void))block {
    WDKDebugAction *action = [[self alloc] init];
    action.name = name;
    action.actionBlock = block;
    return action;
}

- (void)doAction {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDKDebugAction *actionCopy = [[WDKDebugAction alloc] init];
    actionCopy.name = [self.name copy];
    actionCopy.actionBlock = [self.actionBlock copy];
    actionCopy.desc = [self.desc copy];
    actionCopy.shouldDismissPanel = self.shouldDismissPanel;
    
    return actionCopy;
}

@end
