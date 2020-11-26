//
//  WDKInputAction.h
//  WCDebugKit
//
//  Created by wesley_chen on 2020/11/25.
//

#import "WDKDebugAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface WDKInputAction : WDKDebugAction

/**
 
 */
+ (instancetype)actionWithName:(NSString *)name text:(NSString *)text inputBlock:(void (^)(NSString *text))inputBlock;

@end

NS_ASSUME_NONNULL_END
