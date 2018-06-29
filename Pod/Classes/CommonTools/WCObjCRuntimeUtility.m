//
//  WCObjCRuntimeUtility.m
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import "WCObjCRuntimeUtility.h"
#import <objc/runtime.h>

@implementation WCObjCRuntimeUtility

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

+ (BOOL)exchangeSelectorForClass:(Class)cls origin:(SEL)origin substitute:(SEL)substitute classMethod:(BOOL)classMethod {
    Method originMethod = classMethod ? class_getClassMethod(cls, origin) : class_getInstanceMethod(cls, origin);
    Method replaceMethod = classMethod ? class_getClassMethod(cls, substitute) : class_getInstanceMethod(cls, substitute);
    
    if (originMethod == NULL || replaceMethod == NULL) {
        return NO;
    }
    
    if (classMethod) {
        // @see https://stackoverflow.com/a/3267898
        cls = object_getClass((id)cls);
    }
    
    if (class_addMethod(cls, origin, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod))) {
        class_replaceMethod(cls, substitute, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }
    else {
        method_exchangeImplementations(originMethod, replaceMethod);
    }
    
    return YES;
}

@end
