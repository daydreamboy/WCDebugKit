//
//  WDKRuntimeUtility.m
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import "WDKRuntimeUtility.h"
#import <objc/runtime.h>

@implementation WDKRuntimeUtility

+ (IMP)replaceMethodWithSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block {
    if (!block) {
        return NULL;
    }
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    if (!originalMethod) {
        return NULL;
    }
    
    IMP newIMP = imp_implementationWithBlock(block);
    
    if (!class_addMethod(class, originalSelector, newIMP, method_getTypeEncoding(originalMethod))) {
        return method_setImplementation(originalMethod, newIMP);
    } else {
        return method_getImplementation(originalMethod);
    }
}

+ (void)exchangeSelectorForClass:(Class)cls origin:(SEL)origin substitute:(SEL)substitute {
    Method origMethod = class_getInstanceMethod(cls, origin);
    Method replaceMethod = class_getInstanceMethod(cls, substitute);
    
    if (class_addMethod(cls, origin, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod))) {
        class_replaceMethod(cls, substitute, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, replaceMethod);
    }
}

@end
