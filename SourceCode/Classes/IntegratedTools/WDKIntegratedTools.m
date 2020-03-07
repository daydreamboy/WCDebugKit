//
//  WDKIntegratedTools.m
//  Pods
//
//  Created by wesley chen on 16/11/15.
//
//

#import "WDKIntegratedTools.h"
#import "WDKDebugGroup_Internal.h"

#if __has_include(<FLEX/FLEX.h>)
#import <FLEX/FLEX.h>
#endif

@implementation WDKIntegratedTools

- (WDKDebugGroup *)wdk_debugGroup {
    NSMutableArray *arrM = [NSMutableArray array];
    
#if __has_include(<FLEX/FLEX.h>)
    WDKDebugAction *action1 = [WDKDebugAction actionWithName:NSLocalizedString(@"显示FLEX", nil) actionBlock:^{
        [[FLEXManager sharedManager] showExplorer];
    }];
    action1.shouldDismissPanel = YES;
    
    [arrM addObject:action1];
#endif
    
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:NSLocalizedString(@"第三方工具库", nil) actionsBlock:^NSArray<WDKDebugAction *> *{
        return arrM;
    }];
    group.nameColor = [UIColor brownColor];
    
    return group;
}

@end
