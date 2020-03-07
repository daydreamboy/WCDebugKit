//
//  WDKDebugGroup.m
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import "WDKDebugGroup.h"
#import "WDKDebugGroup_Internal.h"

@interface WDKDebugGroup ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong, readwrite) NSArray<WDKDebugAction *> *actions;
@end

@implementation WDKDebugGroup

+ (instancetype)groupWithName:(NSString *)name actionsBlock:(NSArray<WDKDebugAction *> *(^)(void))block {
    NSArray<WDKDebugAction *> *actions;
    if (block) {
        actions = block();
    }
    
    return [self groupWithName:name actions:actions];
}

+ (instancetype)groupWithName:(NSString *)name actions:(NSArray<WDKDebugAction *> *)actions {
    WDKDebugGroup *group = [[WDKDebugGroup alloc] init];
    group.name = name;
    group.actions = actions;
    
    return group;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDKDebugGroup *groupCopy = [[WDKDebugGroup alloc] init];
    groupCopy.name = [self.name copy];
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.actions count]; i++) {
        WDKDebugAction *action = self.actions[i];
        [arrM addObject:[action copy]];
    }
    groupCopy.actions = arrM;
    
    return groupCopy;
}

@end
