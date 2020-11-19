//
//  WDKEnumAction.h
//  Pods
//
//  Created by wesley chen on 16/10/20.
//
//

#import "WCDebugKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface WDKEnumAction : WDKDebugAction

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong, readonly) NSArray *enums;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *prompt;

/*
 *  Initializer
 *
 *  @param name
 *  @param enums    an array of enum values, e.g. NSString, NSNumber
 *  @param index    the index of enum values
 *  @param block    the callback WON'T be called when user choose `Cancel`
 */
+ (instancetype)actionWithName:(NSString *)name title:(NSString *)title subtitle:(nullable NSString *)subtitle enums:(NSArray *)enums index:(NSInteger)index enumBlock:(void (^)(NSUInteger selectedIndex))block;

@end

NS_ASSUME_NONNULL_END
