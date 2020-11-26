//
//  WDKInputAction.m
//  WCDebugKit
//
//  Created by wesley_chen on 2020/11/25.
//

#import "WDKInputAction.h"

@interface WDKInputAction ()
@property (nonatomic, copy) void (^inputBlock)(NSString *text);
@end

@implementation WDKInputAction

+ (instancetype)actionWithName:(NSString *)name text:(NSString *)text inputBlock:(void (^)(NSString *text))inputBlock {
    WDKInputAction *action = [WDKInputAction actionWithName:name actionBlock:nil];
    action.inputBlock = inputBlock;
    
    return action;
}

- (void)doAction {
    if (self.inputBlock) {
        self.inputBlock(@"");
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDKInputAction *actionCopy = [WDKInputAction actionWithName:self.name actionBlock:nil];
    actionCopy.inputBlock = self.inputBlock;
    
    return actionCopy;
}

@end
