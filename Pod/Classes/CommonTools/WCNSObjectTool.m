//
//  WCNSObjectTool.m
//  WCDebugKit
//
//  Created by wesley_chen on 19/01/2018.
//

#import "WCNSObjectTool.h"
#import <objc/runtime.h>

@interface WCNSObjectTool ()
+ (NSString *)formattedPropery:(objc_property_t)prop;
+ (NSArray *)formattedMethodsForProtocol:(Protocol *)proto required:(BOOL)required instance:(BOOL)instance;
+ (NSString *)decodeType:(const char *)cString;
@end

@implementation NSObject (WCNSObjectTool)

+ (NSArray<NSString *> *)wdk_allClasses {
    // Note: objc_copyClassList - get all registered classes on runtime
    unsigned int classesCount;
    Class *classes = objc_copyClassList(&classesCount);
    NSMutableArray *result = [NSMutableArray array];
    for (unsigned int i = 0 ; i < classesCount; i++) {
        [result addObject:NSStringFromClass(classes[i])];
    }
    return [result sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSArray<NSString *> *)wdk_properties {
    // Note: class_copyPropertyList - get properties of a class
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *result = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i++) {
        [result addObject:[WCNSObjectTool formattedPropery:properties[i]]];
    }
    free(properties);
    return result.count ? [result copy] : nil;
}

+ (NSArray<NSString *> *)wdk_instanceVariables {
    // Note: class_copyIvarList - get ivars of a class
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    NSMutableArray *result = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i++) {
        NSString *type = [WCNSObjectTool decodeType:ivar_getTypeEncoding(ivars[i])];
        NSString *name = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
        NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
        [result addObject:ivarDescription];
    }
    free(ivars);
    return result.count ? [result copy] : nil;
}

+ (NSArray<NSString *> *)wdk_classMethods {
    // Note: class methods in meta class, so use `object_getClass`
    return [self methodsForClass:object_getClass([self class]) typeFormat:@"+"];
}

+ (NSArray<NSString *> *)wdk_instanceMethods {
    // Note: instance methods in class
    return [self methodsForClass:[self class] typeFormat:@"-"];
}

+ (NSArray<NSString *> *)wdk_protocols {
    unsigned int outCount;
    Protocol * const *protocols = class_copyProtocolList([self class], &outCount);
    
    NSMutableArray *result = [NSMutableArray array];
    for (unsigned int i = 0; i < outCount; i++) {
        unsigned int adoptedCount;
        Protocol * const *adotedProtocols = protocol_copyProtocolList(protocols[i], &adoptedCount);
        NSString *protocolName = [NSString stringWithCString:protocol_getName(protocols[i]) encoding:NSUTF8StringEncoding];
        
        NSMutableArray *adoptedProtocolNames = [NSMutableArray array];
        for (unsigned int idx = 0; idx < adoptedCount; idx++) {
            [adoptedProtocolNames addObject:[NSString stringWithCString:protocol_getName(adotedProtocols[idx]) encoding:NSUTF8StringEncoding]];
        }
        NSString *protocolDescription = protocolName;
        
        if (adoptedProtocolNames.count) {
            protocolDescription = [NSString stringWithFormat:@"%@ <%@>", protocolName, [adoptedProtocolNames componentsJoinedByString:@", "]];
        }
        [result addObject:protocolDescription];
        //free(adotedProtocols);
    }
    //free((__bridge void *)(*protocols));
    return result.count ? [result copy] : nil;
}

+ (NSDictionary *)wdk_descriptionForProtocol:(Protocol *)protocol {
    NSMutableDictionary *methodsAndProperties = [NSMutableDictionary dictionary];
    
    NSArray *requiredMethods = [[WCNSObjectTool formattedMethodsForProtocol:protocol required:YES instance:NO] arrayByAddingObjectsFromArray:[WCNSObjectTool formattedMethodsForProtocol:protocol required:YES instance:YES]];
    
    NSArray *optionalMethods = [[WCNSObjectTool formattedMethodsForProtocol:protocol required:NO instance:NO] arrayByAddingObjectsFromArray:[WCNSObjectTool formattedMethodsForProtocol:protocol required:NO instance:YES]];
    
    unsigned int propertiesCount;
    NSMutableArray *propertyDescriptions = [NSMutableArray array];
    objc_property_t *properties = protocol_copyPropertyList(protocol, &propertiesCount);
    for (unsigned int i = 0; i < propertiesCount; i++) {
        [propertyDescriptions addObject:[WCNSObjectTool formattedPropery:properties[i]]];
    }
    
    if (requiredMethods.count) {
        [methodsAndProperties setObject:requiredMethods forKey:@"@required"];
    }
    if (optionalMethods.count) {
        [methodsAndProperties setObject:optionalMethods forKey:@"@optional"];
    }
    if (propertyDescriptions.count) {
        [methodsAndProperties setObject:[propertyDescriptions copy] forKey:@"@properties"];
    }
    
    free(properties);
    return methodsAndProperties.count ? [methodsAndProperties copy ] : nil;
}

+ (NSArray<NSString *> *)wdk_parentClassHierarchy {
    NSMutableArray *classHierarchy = [NSMutableArray array];

    Class class = [self class];
    
    do {
        [classHierarchy insertObject:NSStringFromClass(class) atIndex:0];
        class = [class superclass];
    }
    while (class);
    
    return classHierarchy;
}

#pragma mark - Private

+ (NSArray *)methodsForClass:(Class)class typeFormat:(NSString *)type {
    unsigned int outCount;
    Method *methods = class_copyMethodList(class, &outCount);
    NSMutableArray *result = [NSMutableArray array];
    for (unsigned int i = 0; i < outCount; i++) {
        NSString *methodDescription = [NSString stringWithFormat:@"%@ (%@)%@",
                                       type,
                                       [WCNSObjectTool decodeType:method_copyReturnType(methods[i])],
                                       NSStringFromSelector(method_getName(methods[i]))];
        
        NSInteger args = method_getNumberOfArguments(methods[i]);
        NSMutableArray *selParts = [[methodDescription componentsSeparatedByString:@":"] mutableCopy];
        unsigned int offset = 2; //1-st arg is object (@), 2-nd is SEL (:)
        
        for (unsigned int idx = offset; idx < args; idx++) {
            NSString *returnType = [WCNSObjectTool decodeType:method_copyArgumentType(methods[i], (unsigned int)idx)];
            selParts[idx - offset] = [NSString stringWithFormat:@"%@:(%@)arg%u",
                                      selParts[idx - offset],
                                      returnType,
                                      idx - 2];
        }
        [result addObject:[selParts componentsJoinedByString:@" "]];
    }
    free(methods);
    return result.count ? [result copy] : nil;
}

@end

@implementation WCNSObjectTool

#pragma mark - Public Methods

+ (NSArray<NSString *> *)allClasses {
    return [NSObject wdk_allClasses];
}

+ (NSArray<NSString *> *)propertiesWithClassName:(NSString *)className {
    return [NSClassFromString(className) wdk_properties];
}

+ (NSArray<NSString *> *)ivarsWithClassName:(NSString *)className {
    return [NSClassFromString(className) wdk_instanceVariables];
}

+ (NSArray<NSString *> *)instanceMethodsWithClassName:(NSString *)className {
    return [NSClassFromString(className) wdk_instanceMethods];
}

+ (NSArray<NSString *> *)classMethodsWithClassName:(NSString *)className {
    return [NSClassFromString(className) wdk_classMethods];
}

+ (NSArray<NSString *> *)protocolsWithClassName:(NSString *)className {
    return [NSClassFromString(className) wdk_protocols];
}

+ (NSArray<NSString *> *)protocolRequiredMethodsWithProtocolName:(NSString *)protocolName className:(NSString *)className {
    return [[NSClassFromString(className) wdk_descriptionForProtocol:NSProtocolFromString(protocolName)] objectForKey:@"@required"];
}

+ (NSArray<NSString *> *)protocolOptionalMethodsWithProtocolName:(NSString *)protocolName className:(NSString *)className {
    return [[NSClassFromString(className) wdk_descriptionForProtocol:NSProtocolFromString(protocolName)] objectForKey:@"@optional"];
}

+ (NSArray<NSString *> *)protocolPropertiesWithProtocolName:(NSString *)protocolName className:(NSString *)className {
    return [[NSClassFromString(className) wdk_descriptionForProtocol:NSProtocolFromString(protocolName)] objectForKey:@"@properties"];
}

+ (NSArray<NSString *> *)parentClassHierarchyWithClassName:(NSString *)className {
    return [NSClassFromString(className) wdk_parentClassHierarchy];
}

+ (BOOL)checkObject:(id)object overridesSelector:(SEL)selector {
    Class superClass = [object superclass];
    BOOL isMethodOverrriden = NO;
    
    while (superClass != Nil) {
        isMethodOverrriden = [object methodForSelector:selector] != [superClass instanceMethodForSelector:selector];
        
        if (isMethodOverrriden) {
            // found super...super class has overriden the method
            break;
        }
        
        superClass = [superClass superclass];
    }
    
    return isMethodOverrriden;
}

+ (id)help {
    return [self classMethodsWithClassName:NSStringFromClass(self)];
}

#pragma mark - Safe KVC

+ (nullable id)safeValueWithObject:(NSObject *)object forKey:(NSString *)key {
    return [WCNSObjectTool safeValueWithObject:object forKey:key typeClass:[NSObject class]];
}

+ (nullable id)safeValueWithObject:(NSObject *)object forKey:(NSString *)key typeClass:(Class)typeClass {
    if (![object isKindOfClass:[NSObject class]] || ![key isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    id returnValue = nil;
    @try {
        returnValue = [object valueForKey:key];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        if ([returnValue isKindOfClass:typeClass]) {
            return returnValue;
        }
        else {
            return nil;
        }
    }
}

#pragma mark - Private Methods

+ (NSString *)formattedPropery:(objc_property_t)prop {
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(prop, &attrCount);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    for (unsigned int idx = 0; idx < attrCount; idx++) {
        NSString *name = [NSString stringWithCString:attrs[idx].name encoding:NSUTF8StringEncoding];
        NSString *value = [NSString stringWithCString:attrs[idx].value encoding:NSUTF8StringEncoding];
        [attributes setObject:value forKey:name];
    }
    free(attrs);
    NSMutableString *property = [NSMutableString stringWithFormat:@"@property "];
    NSMutableArray *attrsArray = [NSMutableArray array];
    
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
    [attrsArray addObject:[attributes objectForKey:@"N"] ? @"nonatomic" : @"atomic"];
    
    if ([attributes objectForKey:@"&"]) {
        [attrsArray addObject:@"strong"];
    }
    else if ([attributes objectForKey:@"C"]) {
        [attrsArray addObject:@"copy"];
    }
    else if ([attributes objectForKey:@"W"]) {
        [attrsArray addObject:@"weak"];
    }
    else {
        [attrsArray addObject:@"assign"];
    }
    if ([attributes objectForKey:@"R"]) {[attrsArray addObject:@"readonly"];}
    if ([attributes objectForKey:@"G"]) {
        [attrsArray addObject:[NSString stringWithFormat:@"getter=%@", [attributes objectForKey:@"G"]]];
    }
    if ([attributes objectForKey:@"S"]) {
        [attrsArray addObject:[NSString stringWithFormat:@"setter=%@", [attributes objectForKey:@"G"]]];
    }
    
    [property appendFormat:@"(%@) %@ %@",
     [attrsArray componentsJoinedByString:@", "],
     [self decodeType:[[attributes objectForKey:@"T"] cStringUsingEncoding:NSUTF8StringEncoding]],
     [NSString stringWithCString:property_getName(prop) encoding:NSUTF8StringEncoding]];
    return [property copy];
}

+ (NSArray *)formattedMethodsForProtocol:(Protocol *)proto required:(BOOL)required instance:(BOOL)instance {
    unsigned int methodCount;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(proto, required, instance, &methodCount);
    NSMutableArray *methodsDescription = [NSMutableArray array];
    for (unsigned int i = 0; i < methodCount; i++) {
        [methodsDescription addObject:
         [NSString stringWithFormat:@"%@ (%@)%@",
          instance ? @"-" : @"+",
#warning return correct type
          @"void",
          NSStringFromSelector(methods[i].name)]];
    }
    
    free(methods);
    return  [methodsDescription copy];
}

+ (NSString *)decodeType:(const char *)cString {
    if (!strcmp(cString, @encode(id))) return @"id";
    if (!strcmp(cString, @encode(void))) return @"void";
    if (!strcmp(cString, @encode(float))) return @"float";
    if (!strcmp(cString, @encode(int))) return @"int";
    if (!strcmp(cString, @encode(BOOL))) return @"BOOL";
    if (!strcmp(cString, @encode(char *))) return @"char *";
    if (!strcmp(cString, @encode(double))) return @"double";
    if (!strcmp(cString, @encode(Class))) return @"class";
    if (!strcmp(cString, @encode(SEL))) return @"SEL";
    if (!strcmp(cString, @encode(unsigned int))) return @"unsigned int";
    
    //@TODO: do handle bitmasks
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    }
    else if ([[result substringToIndex:1] isEqualToString:@"^"]) {
        result = [NSString stringWithFormat:@"%@ *", [self decodeType:[[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
    }
    return result;
}

@end
