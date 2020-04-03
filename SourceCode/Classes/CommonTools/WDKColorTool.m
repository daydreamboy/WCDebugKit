//
//  WDKColorTool.m
//  WCDebugKit
//
//  Created by wesley_chen on 2020/3/13.
//

#import "WDKColorTool.h"

@implementation WDKColorTool

#pragma mark - Color Conversion

#pragma mark > UIColor to NSString

+ (nullable NSString *)RGBAHexStringFromUIColor:(UIColor *)color {
    if (![color isKindOfClass:[UIColor class]]) {
        return nil;
    }
    
    CGFloat r, g, b, a;
    [self componentsOfRed:&r green:&g blue:&b alpha:&a fromColor:color];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255),
            lroundf(a * 255)
            ];
}

+ (nullable NSString *)RGBHexStringFromUIColor:(UIColor *)color {
    if (![color isKindOfClass:[UIColor class]]) {
        return nil;
    }
    
    CGFloat r, g, b, a;
    [self componentsOfRed:&r green:&g blue:&b alpha:&a fromColor:color];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)
            ];
}

#pragma mark > NSString to UIColor

+ (nullable UIColor *)colorWithHexString:(NSString *)string {
    return [self colorWithHexString:string prefix:@"#"];
}

+ (nullable UIColor *)colorWithHexString:(NSString *)string prefix:(nullable NSString *)prefix {
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    // Note: prefix is not nil, but not a NSString
    if (prefix && ![prefix isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    // Note: prefix is nil, expect string length is 6 or 8
    if (!prefix && (string.length != 6 && string.length != 8)) {
        return nil;
    }
    
    if (prefix == nil) {
        prefix = @"";
    }
    
    if ([prefix rangeOfString:@"%"].location != NSNotFound) {
        return nil;
    }
    
    if ([string hasPrefix:prefix] && (string.length != (6 + prefix.length) && string.length != (8 + prefix.length))) {
        return nil;
    }
    
    // Note: -1 as failure flag
    int r = -1, g = -1, b = -1, a = -1;
    
    if (string.length == (6 + prefix.length)) {
        a = 0xFF;
        NSString *formatString = [NSString stringWithFormat:@"%@%%02x%%02x%%02x", prefix];
        sscanf([string UTF8String], [formatString UTF8String], &r, &g, &b);
    }
    else if (string.length == (8 + prefix.length)) {
        NSString *formatString = [NSString stringWithFormat:@"%@%%02x%%02x%%02x%%02x", prefix];
        sscanf([string UTF8String], [formatString UTF8String], &r, &g, &b, &a);
    }
    
    if (r == -1 || g == -1 || b == -1 || a == -1) {
        // parse hex failed
        return nil;
    }
    
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a / 255.0];
}

#pragma mark - Private Methods

+ (void)componentsOfRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha fromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    
    if (colorSpaceModel == kCGColorSpaceModelRGB && CGColorGetNumberOfComponents(color.CGColor) == 4) {
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    }
    else if (colorSpaceModel == kCGColorSpaceModelMonochrome && CGColorGetNumberOfComponents(color.CGColor) == 2) {
        *red = *green = *blue = components[0];
        *alpha = components[1];
    }
    else {
        *red = *green = *blue = *alpha = 0;
    }
}

@end
