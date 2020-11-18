//
//  WDKDebugGroup.h
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import <Foundation/Foundation.h>

#import "WDKDebugAction.h"

@interface WDKDebugGroup : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSMutableArray<WDKDebugAction *> *actions;

+ (instancetype)groupWithName:(NSString *)name;
+ (instancetype)groupWithName:(NSString *)name actionsBlock:(NSArray<WDKDebugAction *> *(^)(void))block;
+ (instancetype)groupWithName:(NSString *)name actions:(NSArray<WDKDebugAction *> *)actions;

- (void)addAction:(WDKDebugAction *)action;

@end
