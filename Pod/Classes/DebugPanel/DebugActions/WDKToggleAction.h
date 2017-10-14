//
//  WDKToogleAction.h
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import "WCDebugKit.h"

@interface WDKToggleAction : WDKDebugAction

@property (nonatomic, assign) BOOL enabled;

+ (instancetype)actionWithName:(NSString *)name enabled:(BOOL)enabled toggleBlock:(void (^)(BOOL enabled))block;

@end
