//
//  WCViewControllerTool.h
//  WCDebugKit
//
//  Created by wesley_chen on 2018/12/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCViewControllerTool : NSObject
@end

@interface WCViewControllerTool ()

/**
 Get the top most view controller on the specific window
 
 @param window the window
 @return the top most view controller
 */
+ (nullable UIViewController *)topViewControllerOnWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
