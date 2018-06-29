//
//  WCObjCRuntimeUtility.h
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import <Foundation/Foundation.h>

@interface WCObjCRuntimeUtility : NSObject
@end

@interface WCObjCRuntimeUtility ()
+ (IMP)replaceMethodWithSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block;
+ (BOOL)exchangeSelectorForClass:(Class)cls origin:(SEL)origin substitute:(SEL)substitute classMethod:(BOOL)classMethod;
@end

