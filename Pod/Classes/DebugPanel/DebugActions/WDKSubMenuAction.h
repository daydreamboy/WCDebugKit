//
//  WDKSubMenuAction.h
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import "WCDebugKit.h"

@interface WDKSubMenuAction : WDKDebugAction

+ (instancetype)actionWithName:(NSString*)name subMenuBlock:(NSArray<WDKDebugGroup *> *(^)(void))block;

@end
