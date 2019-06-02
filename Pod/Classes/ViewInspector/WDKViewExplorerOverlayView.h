//
//  WDKViewExplorerOverlayView.h
//  WCDebugKit
//
//  Created by wesley_chen on 2018/12/3.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WDKViewExplorerMode) {
    WDKViewExplorerModeDefault,
    WDKViewExplorerModeSelect,
    WDKViewExplorerModeMove,
};

@interface WDKViewExplorerOverlayView : UIView

@property (nonatomic, assign, class) BOOL enabled;

+ (void)installOverlayToFrontestWindow;
+ (void)uninstallOverlay;

//- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates;

@end
