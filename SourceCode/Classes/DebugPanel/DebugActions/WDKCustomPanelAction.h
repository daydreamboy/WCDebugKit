//
//  WDKCustomPanelAction.h
//  Pods
//
//  Created by wesley chen on 16/10/20.
//
//

#import "WCDebugKit.h"

@interface WDKCustomPanelAction : WDKDebugAction

+ (instancetype)actionWithName:(NSString*)name customPanelBlock:(void(^)(UIViewController *mainPanelViewController))block;

@end
