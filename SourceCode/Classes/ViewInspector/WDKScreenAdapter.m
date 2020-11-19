//
//  WDKScreenAdapter.m
//  WCDebugKit
//
//  Created by wesley_chen on 2020/11/19.
//

#import "WDKScreenAdapter.h"
#import "WDKRuntimeTool.h"

@interface UIScreen (WDKScreenAdapter)

@end

@implementation UIScreen (WDKScreenAdapter)
- (CGRect)wdk_nativeBounds {
    if ([WDKScreenAdapter sharedInstance].fakedDeviceModel) {
        return [WDKScreenAdapter sharedInstance].fakedScreenBounds;
    }
    return [self wdk_nativeBounds];
}

- (CGRect)wdk_bounds {
    if ([WDKScreenAdapter sharedInstance].fakedDeviceModel) {
        return [WDKScreenAdapter sharedInstance].fakedScreenBounds;
    }
    return [self wdk_bounds];
}

- (CGRect)wdk_applicationFrame {
    if ([WDKScreenAdapter sharedInstance].fakedDeviceModel) {
        return [WDKScreenAdapter sharedInstance].fakedScreenBounds;
    }
    return [self wdk_applicationFrame];
}
@end

@interface UIWindow (WDKScreenAdapter)

@end

@implementation UIWindow (WDKScreenAdapter)
- (CGRect)wdk_sceneBounds {
    if ([WDKScreenAdapter sharedInstance].fakedDeviceModel) {
        return [WDKScreenAdapter sharedInstance].fakedScreenBounds;
    }
    return [self wdk_sceneBounds];
}

- (CGRect)wdk_sceneReferenceBounds {
    if ([WDKScreenAdapter sharedInstance].fakedDeviceModel) {
        return [WDKScreenAdapter sharedInstance].fakedScreenBounds;
    }
    return [self wdk_sceneReferenceBounds];
}
@end

@interface UIViewController (WDKScreenAdapter)

@end

@implementation UIViewController (WDKScreenAdapter)

- (CGRect)wdk_defaultInitialViewFrame {
    if ([WDKScreenAdapter sharedInstance].fakedDeviceModel) {
        return [WDKScreenAdapter sharedInstance].fakedScreenBounds;
    }
    return [self wdk_defaultInitialViewFrame];
}

@end

#define kWDKScreenAdapterDeviceMode @"WDKScreenAdapterDeviceMode"

@interface WDKScreenAdapter ()
@property (nonatomic, assign, readwrite) WDKScreenAdapterDeviceModel fakedDeviceModel;
@end

@implementation WDKScreenAdapter

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[NSUserDefaults standardUserDefaults] integerForKey:kWDKScreenAdapterDeviceMode]) {
            // UIScreen
            [WDKRuntimeTool exchangeSelectorForClass:[UIScreen class] origin:@selector(nativeBounds) substitute:@selector(wdk_nativeBounds) classMethod:NO];
            [WDKRuntimeTool exchangeSelectorForClass:[UIScreen class] origin:@selector(bounds) substitute:@selector(wdk_bounds) classMethod:NO];
            [WDKRuntimeTool exchangeSelectorForClass:[UIScreen class] origin:@selector(applicationFrame) substitute:@selector(wdk_applicationFrame) classMethod:NO];
            
            // UIWindow
            [WDKRuntimeTool exchangeSelectorForClass:[UIWindow class] origin:@selector(_sceneBounds) substitute:@selector(wdk_sceneBounds) classMethod:NO];
            [WDKRuntimeTool exchangeSelectorForClass:[UIWindow class] origin:@selector(_sceneReferenceBounds) substitute:@selector(wdk_sceneReferenceBounds) classMethod:NO];
            
            // UIViewController
            [WDKRuntimeTool exchangeSelectorForClass:[UIViewController class] origin:@selector(_defaultInitialViewFrame) substitute:@selector(wdk_defaultInitialViewFrame) classMethod:NO];
        }
    });
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static WDKScreenAdapter *sInstance;
    dispatch_once(&onceToken, ^{
        sInstance = [[WDKScreenAdapter alloc] init];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:kWDKScreenAdapterDeviceMode]) {
            sInstance.fakedDeviceModel = [[NSUserDefaults standardUserDefaults] integerForKey:kWDKScreenAdapterDeviceMode];
        }
    });
    
    return sInstance;
}

- (CGRect)fakedScreenBounds {
    switch (self.fakedDeviceModel) {
        case WDKScreenAdapterDeviceModel_iPhone2G_3G_3GS_4_4S:
            return CGRectMake(0, 0, 320, 480);
        case WDKScreenAdapterDeviceModel_iPhone5_5S_5C_SE:
            return CGRectMake(0, 0, 320, 568);
        case WDKScreenAdapterDeviceModel_iPhone6_6S_7_8:
            return CGRectMake(0, 0, 375, 667);
        case WDKScreenAdapterDeviceModel_iPhone6P_6SP_7P_8P:
            return CGRectMake(0, 0, 414, 736);
        case WDKScreenAdapterDeviceModel_iPhoneX_XS_11Pro:
            return CGRectMake(0, 0, 375, 812);
        case WDKScreenAdapterDeviceModel_iPhoneXR_XSMax_11_11ProMax:
            return CGRectMake(0, 0, 414, 896);
        default: {
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            return CGRectMake(0, 0, screenSize.width, screenSize.height);
        }
    }
}

- (void)changeFakedDeviceModel:(WDKScreenAdapterDeviceModel)fakedDeviceModel {
    if (fakedDeviceModel >= 0 && fakedDeviceModel <= WDKScreenAdapterDeviceModel_iPhoneXR_XSMax_11_11ProMax) {
        _fakedDeviceModel = fakedDeviceModel;
        [[NSUserDefaults standardUserDefaults] setInteger:_fakedDeviceModel forKey:kWDKScreenAdapterDeviceMode];
    }
}

- (NSArray<NSString *> *)deviceModels {
    return @[
        @"Current iPhone (Reset)",
        @"iPhone2G_3G_3GS_4_4S",
        @"iPhone5_5S_5C_SE",
        @"iPhone6_6S_7_8",
        @"iPhone6P_6SP_7P_8P",
        @"iPhoneX_XS_11Pro",
        @"iPhoneXR_XSMax_11_11ProMax",
    ];
}

@end
