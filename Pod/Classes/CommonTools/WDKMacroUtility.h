//
//  WDKMacroUtility.h
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import <objc/runtime.h>

#define SYNTHESIZE_ASSOCIATED_PRIMITIVE(getterName, setterName, type)                                           \
static NSString *WCMacroKit_##getterName = @"WCMacroKit_" #getterName;                                          \
                                                                                                                \
- (void)setterName:(type)value {                                                                                \
    NSValue *nsValue = [NSValue value:&value withObjCType:@encode(type)];                                       \
    objc_setAssociatedObject(self, &WCMacroKit_##getterName, nsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);       \
}                                                                                                               \
                                                                                                                \
- (type)getterName {                                                                                            \
    type value;                                                                                                 \
    memset(&value, 0, sizeof(type));                                                                            \
    NSValue *nsValue = objc_getAssociatedObject(self, &WCMacroKit_##getterName);                                \
    [nsValue getValue:&value];                                                                                  \
    return value;                                                                                               \
}

#define SYNTHESIZE_ASSOCIATED_OBJ(getterName, setterName, type)                                                 \
- (void)setterName:(type)object {                                                                               \
    if (object) {                                                                                               \
        objc_setAssociatedObject(self, @selector(getterName), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);       \
    }                                                                                                           \
}                                                                                                               \
- (type)getterName {                                                                                            \
    return objc_getAssociatedObject(self, @selector(getterName));                                               \
}

#pragma mark - Weak-Strong Dance

/**
 Weakify the object variable

 @param object the original variable
 @discussion Use weakify/strongify as pair
 @see https://www.jianshu.com/p/9e18f28bf28d
 @see https://github.com/ReactiveCocoa/ReactiveObjC/blob/master/ReactiveObjC/extobjc/EXTScope.h#L83
 @code
 
 id foo = [[NSObject alloc] init];
 id bar = [[NSObject alloc] init];
 
 weakify(foo);
 weakify(bar);
 
 // this block will not keep 'foo' or 'bar' alive
 BOOL (^matchesFooOrBar)(id) = ^ BOOL (id obj){
    // but now, upon entry, 'foo' and 'bar' will stay alive until the block has
    // finished executing
    strongify(foo);
    strongifyWithReturn(bar, return NO);
 
    return [foo isEqual:obj] || [bar isEqual:obj];
 };
 
 @endcode
 */
#define weakify(object) \
__weak __typeof__(object) object##_weak_ = object;

/**
 Strongify the weak object variable which is created by weakify(object)

 @param object the original variable
 @discussion Use weakify/strongify as pair
 @see https://www.jianshu.com/p/9e18f28bf28d
 @note See #weakify for an example of usage.
 */
#define strongify(object) \
__strong __typeof__(object) object = object##_weak_;

/**
 Strongify the weak object variable which is created by weakify(object).
 And optional add a return clause

 @param object the original variable
 @param ... the return clause
 @discussion strongifyWithReturn works as strongify, except for allowing a return clause
 @note See #weakify for an example of usage.
 */
#define strongifyWithReturn(object, ...) \
__strong __typeof__(object) object = object##_weak_; \
if (!object) { \
    __VA_ARGS__; \
}
