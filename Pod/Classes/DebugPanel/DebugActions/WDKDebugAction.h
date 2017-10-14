//
//  WDKDebugAction.h
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import <Foundation/Foundation.h>

@interface WDKDebugAction : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *name; /**< Title */

@property (nonatomic, copy) NSString *desc; /**< Subtitle */
@property (nonatomic, assign) BOOL shouldDismissPanel; /**< Default is YES */

+ (instancetype)actionWithName:(NSString*)name actionBlock:(void(^)(void))block;
- (void)doAction;

@end
