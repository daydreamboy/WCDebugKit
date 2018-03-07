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
// get all classes registed in runtime
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

// print help info by `po [WCNSObjectTool help]`
+ (id)help;

@end
