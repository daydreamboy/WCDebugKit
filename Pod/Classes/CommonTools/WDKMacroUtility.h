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

