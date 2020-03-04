//
//  WDKApplicationTool.h
//  WCDebugKit
//
//  Created by wesley_chen on 2020/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WDKApplicationTool : NSObject

#pragma mark > Get debug configuration (Only Simulator)

/**
 Get JSON Object at the specific JSON file at MacOS user direcotry
 
 @param userHomeFileName the debug configuratio file name. If pass nil、empty string or not a string, use @"simulator_debug.json" instead.
 
 @return the JSON object which allow fragments
 */
+ (nullable id)JSONObjectWithUserHomeFileName:(nullable NSString *)userHomeFileName;

@end

NS_ASSUME_NONNULL_END
