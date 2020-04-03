//
//  WDKColorTool.h
//  WCDebugKit
//
//  Created by wesley_chen on 2020/3/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WDKColorTool : NSObject

#pragma mark - Color Conversion

#pragma mark > UIColor to NSString

+ (nullable NSString *)RGBHexStringFromUIColor:(UIColor *)color;
+ (nullable NSString *)RGBAHexStringFromUIColor:(UIColor *)color;

#pragma mark > NSString to UIColor

/**
 Convert hex string to UIColor
 
 @param string the hex string with foramt @"#RRGGBB" or @"#RRGGBBAA"
 @return the UIColor object. return nil if string is not valid.
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)string;

/**
 Convert hex string to UIColor with the specific prefix

 @param string the hex string with foramt @"<prefix>RRGGBB" or @"<prefix>RRGGBBAA"
 @param prefix the prefix. For safety, prefix not allow the `%` character
 @return the UIColor object. return nil if string is not valid.
 @discussion If the prefix contains `%` character, will return nil.
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)string prefix:(nullable NSString *)prefix;

@end

NS_ASSUME_NONNULL_END
