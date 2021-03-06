//
//  WDKViewExplorerWindow.m
//  WCDebugKit
//
//  Created by wesley_chen on 23/10/2017.
//

#import "WDKViewExplorerWindow.h"
#import "WDKViewExplorerViewController.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation WDKViewExplorerWindow

static WDKViewExplorerWindow *sWDKViewExplorerWindow_sharedInstance = nil;

#pragma mark - Public Methods

+ (void)enableViewExplorerWindow:(BOOL)enabled {
    if (enabled) {
        if (!sWDKViewExplorerWindow_sharedInstance) {
            WDKViewExplorerViewController *rootViewController = [[WDKViewExplorerViewController alloc] init];
            
            sWDKViewExplorerWindow_sharedInstance = [[WDKViewExplorerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            sWDKViewExplorerWindow_sharedInstance.rootViewController = rootViewController;
        }
        
        sWDKViewExplorerWindow_sharedInstance.hidden = NO;
    }
    else {
        sWDKViewExplorerWindow_sharedInstance.hidden = YES;
    }
}

+ (WDKViewExplorerWindow *)currentViewExplorerWindow {
    return sWDKViewExplorerWindow_sharedInstance;
}

#pragma mark - Override Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = 10000002;//pow(10, 3);//UIWindowLevelStatusBar + 100;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    if ([self.rootViewController isKindOfClass:[WDKViewExplorerViewController class]]) {
        WDKViewExplorerViewController *viewController = (WDKViewExplorerViewController *)self.rootViewController;
        
        if ([viewController shouldReceiveTouchAtWindowPoint:point]) {
            pointInside = [super pointInside:point withEvent:event];
        }
    }
    return pointInside;
}


#pragma mark - Private Methods


@end
