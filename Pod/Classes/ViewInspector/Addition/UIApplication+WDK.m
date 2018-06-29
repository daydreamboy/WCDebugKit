//
//  UIApplication+WDK.m
//  WCDebugKit
//
//  Created by wesley_chen on 21/01/2018.
//

@import ObjectiveC.runtime;

#import "UIApplication+WDK.h"
#import "WCObjCRuntimeUtility.h"

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
    
    [self wdk_sendEvent_intercepted:event];
}

@end
