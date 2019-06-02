//
//  UIApplication+WDK.m
//  WCDebugKit
//
//  Created by wesley_chen on 21/01/2018.
//

@import ObjectiveC.runtime;

#import "UIApplication+WDK.h"
#import "WCObjCRuntimeUtility.h"
#import "WDKViewExplorerWindow.h"
#import "WDKViewExplorerOverlayView.h"

NSNotificationName WDKShakeMotionNotification = @"kWDKShakeMotionNotification";
NSNotificationName WDKInterfaceEventNotification = @"kWDKInterfaceEventNotification";

@implementation UIApplication (WDK)

+ (void)load {
    [WCObjCRuntimeUtility exchangeSelectorForClass:self origin:@selector(sendEvent:) substitute:@selector(wdk_sendEvent_intercepted:) classMethod:NO];
}

- (void)wdk_sendEvent_intercepted:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WDKShakeMotionNotification object:event];
    }
    
    //
    // Send notification of event
    //
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WDKInterfaceEventNotification object:event];
    
    [WDKViewExplorerOverlayView installOverlayToFrontestWindow];
    
    [self wdk_sendEvent_intercepted:event];
}

@end

@implementation UIWindow (WDK)
+ (void)load {
    [WCObjCRuntimeUtility exchangeSelectorForClass:self origin:@selector(windowLevel) substitute:@selector(wdk_windowLevel_intercepted) classMethod:NO];
}

- (UIWindowLevel)wdk_windowLevel_intercepted {
    if ([self isKindOfClass:[NSClassFromString(@"UIRemoteKeyboardWindow") class]]) {
        return 10000000 - 1;
    }
    return [self wdk_windowLevel_intercepted];
}

@end
