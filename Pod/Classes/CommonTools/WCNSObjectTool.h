//
//  WCNSObjectTool.h
//  WCDebugKit
//
//  Created by wesley_chen on 19/01/2018.
//

#import <Foundation/Foundation.h>

@interface NSObject (WCNSObjectTool)
+ (NSArray<NSString *> *)wdk_allClasses;

+ (NSArray<NSString *> *)wdk_properties;
+ (NSArray<NSString *> *)wdk_instanceVariables;
+ (NSArray<NSString *> *)wdk_classMethods;
+ (NSArray<NSString *> *)wdk_instanceMethods;

+ (NSArray<NSString *> *)wdk_protocols;
+ (NSDictionary *)wdk_descriptionForProtocol:(Protocol *)protocol;
+ (NSArray<NSString *> *)wdk_parentClassHierarchy;

@end

@interface WCNSObjectTool : NSObject
// get all classes registered in runtime
+ (NSArray<NSString *> *)allClasses;

// get attributes of a class
+ (NSArray<NSString *> *)propertiesWithClassName:(NSString *)className;
+ (NSArray<NSString *> *)ivarsWithClassName:(NSString *)className;
+ (NSArray<NSString *> *)instanceMethodsWithClassName:(NSString *)className;
+ (NSArray<NSString *> *)classMethodsWithClassName:(NSString *)className;
+ (NSArray<NSString *> *)protocolsWithClassName:(NSString *)className;

// get attributes of a protocol based on a class
+ (NSArray<NSString *> *)protocolRequiredMethodsWithProtocolName:(NSString *)protocolName className:(NSString *)className;
+ (NSArray<NSString *> *)protocolOptionalMethodsWithProtocolName:(NSString *)protocolName className:(NSString *)className;
+ (NSArray<NSString *> *)protocolPropertiesWithProtocolName:(NSString *)protocolName className:(NSString *)className;

// get all super class of a class
+ (NSArray<NSString *> *)parentClassHierarchyWithClassName:(NSString *)className;

/**
 Check an object's class if override some one method

 @param object the object
 @param selector the selector of the method
 @return YES, if override; NO, if not override
 @see https://stackoverflow.com/a/28737576
 
 @code
 
 @implmentation BaseClass
 - (void)methodMaybeOverride {
    BOOL overridden = [WCNSObjectTool checkObject:self overridesSelector:@selector(methodMaybeOverride)];
    ...
 }
 @end
 @implementation DerivedClass : BaseClass
 - (void)methodMaybeOverride {
 
 }
 @end
 
 @endcode
 */
+ (BOOL)checkObject:(id)object overridesSelector:(SEL)selector;

// print help info by `po [WCNSObjectTool help]`
+ (id)help;

@end
