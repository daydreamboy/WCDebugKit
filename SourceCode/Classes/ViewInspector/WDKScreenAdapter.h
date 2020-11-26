//
//  WDKScreenAdapter.h
//  WCDebugKit
//
//  Created by wesley_chen on 2020/11/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// @see https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
typedef NS_ENUM(NSUInteger, WDKScreenAdapterDeviceModel) {
    /// current device screen
    WDKScreenAdapterDeviceModel_iPhoneCurrent,
    /// 320 x 480
    WDKScreenAdapterDeviceModel_iPhone2G_3G_3GS_4_4S,
    /// 320 x 568
    WDKScreenAdapterDeviceModel_iPhone5_5S_5C_SE,
    /// 375 x 667
    WDKScreenAdapterDeviceModel_iPhone6_6S_7_8,
    /// 414 x 736
    WDKScreenAdapterDeviceModel_iPhone6P_6SP_7P_8P,
    /// 375 x 812
    WDKScreenAdapterDeviceModel_iPhoneX_XS_11Pro,
    /// 414 x 896
    WDKScreenAdapterDeviceModel_iPhoneXR_XSMax_11_11ProMax,
};

@interface WDKScreenAdapter : NSObject
@property (nonatomic, assign, readonly) WDKScreenAdapterDeviceModel fakedDeviceModel;

+ (instancetype)sharedInstance;
- (CGRect)fakedScreenBounds;
- (NSArray<NSString *> *)deviceModels;
- (void)changeFakedDeviceModel:(WDKScreenAdapterDeviceModel)fakedDeviceModel;

@end

NS_ASSUME_NONNULL_END
