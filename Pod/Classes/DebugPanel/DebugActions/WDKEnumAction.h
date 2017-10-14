//
//  WDKEnumAction.h
//  Pods
//
//  Created by wesley chen on 16/10/20.
//
//

#import "WCDebugKit.h"

@interface WDKEnumAction : WDKDebugAction

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, readonly) NSArray *enums;
@property (nonatomic, copy) NSString *prompt;

/*
 *  Initializer
 *
 *  @param name
 *  @param enums    an array of enum values, e.g. NSString, NSNumber
 *  @param index    the index of enum values
 *  @param block    the callback WON'T be called when user choose `Cancel`
 */
+ (instancetype)actionWithName:(NSString *)name enums:(NSArray *)enums index:(NSUInteger)index enumBlock:(void (^)(NSUInteger selectedIndex))block;

@end
