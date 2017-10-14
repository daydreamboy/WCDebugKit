//
//  WDKDebugPanel_Internal.h
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import "WCDebugKit.h"

@class WDKDebugActionsViewController;

@interface WDKDebugPanel ()
@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, copy) void (^enterBlock)(UIViewController *viewController);
@property (nonatomic, copy) void (^exitBlock)(UIViewController *viewController);
@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, strong) NSMutableArray<WDKDebugGroup *> *actionGroupsM;

+ (instancetype)sharedPanel;
+ (void)cleanup;

- (void)dismissDebugPanel;
- (void)loadExternalToolsFromArray:(NSArray *)array;

// 高级功能（暂时不开放）
//+ (void)configureTransitionWithEnterBlock:(void (^)(UIViewController *viewController))enterBlock exitBlock:(void (^)(UIViewController *viewController))exitBlock;

@end
