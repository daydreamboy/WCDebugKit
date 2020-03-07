//
//  WDKEnumAction.m
//  Pods
//
//  Created by wesley chen on 16/10/20.
//
//

#import "WDKEnumAction.h"

@interface WDKEnumAction ()
@property (nonatomic, copy) void (^enumBlock)(NSUInteger selectedIndex);
@property (nonatomic, strong) NSArray *enums;
@end

@implementation WDKEnumAction

+ (instancetype)actionWithName:(NSString *)name enums:(NSArray *)enums index:(NSUInteger)index enumBlock:(void (^)(NSUInteger selectedIndex))block {
    WDKEnumAction *action = [WDKEnumAction actionWithName:name actionBlock:nil];
    action.shouldDismissPanel = NO;
    action.enums = enums;
    action.index = index;
    action.enumBlock = block;
    
    return action;
}

- (void)doAction {
    if (self.enumBlock) {        
        self.enumBlock(self.index);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDKEnumAction *actionCopy = [WDKEnumAction actionWithName:self.name actionBlock:nil];
    actionCopy.shouldDismissPanel = self.shouldDismissPanel;
    actionCopy.enums = self.enums;
    actionCopy.index = self.index;
    actionCopy.enumBlock = self.enumBlock;
    
    return actionCopy;
}

@end
