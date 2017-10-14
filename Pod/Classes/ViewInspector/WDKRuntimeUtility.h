//
//  WDKRuntimeUtility.h
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import <Foundation/Foundation.h>

@interface WDKRuntimeUtility : NSObject
+ (IMP)replaceMethodWithSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block;
@end
