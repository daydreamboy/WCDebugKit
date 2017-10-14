//
//  NetworkUtility.m
//  WDKDebugKit
//
//  Created by wesley chen on 16/10/18.
//  Copyright © 2016年 wesley_chen. All rights reserved.
//

#import "NetworkUtility.h"

#import <WCDebugKit.h>

@implementation NetworkUtility

//#if DEBUG

- (WDKDebugGroup *)wdk_debugGroup {
    
    WDKDebugAction *action1 = [WDKDebugAction actionWithName:@"App Version" actionBlock:^{
        NSLog(@"Cell selection will trigger here");
    }];
    action1.shouldDismissPanel = NO;
    action1.desc = @"This is a detail text";
    
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:@"NetworkUtility" actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[action1];
    }];
    
    return group;
}

//#endif

@end
