//
//  WDKDebugActionsViewController.h
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import <UIKit/UIKit.h>
#import "WDKDebugAction.h"
#import "WDKDebugGroup.h"

@class WDKDebugActionsViewController;

@interface WDKDebugActionsViewController : UIViewController

@property (nonatomic, assign) BOOL isSubMenu; // If YES, has no default nav items (left & right bar items, title)
@property (nonatomic, assign) BOOL flagPresentByInternal;
@property (nonatomic, strong) NSArray<WDKDebugGroup*> *actionGroups;

- (void)reloadData;

@end
