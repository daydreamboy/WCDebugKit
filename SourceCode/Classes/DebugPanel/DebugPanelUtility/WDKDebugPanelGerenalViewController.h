//
//  WDKDebugPanelGerenalViewController.h
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import <UIKit/UIKit.h>

@class WDKDebugPanelCellItem;
@class WDKDebugPanelSectionItem;

@interface WDKDebugPanelGerenalViewController : UIViewController

@property (nonatomic, strong) NSMutableArray<NSMutableArray<WDKDebugPanelCellItem*> *> *listData;
@property (nonatomic, strong) NSArray<WDKDebugPanelSectionItem *> *listSection;

@property (nonatomic, copy) void (^blockForViewDidLoad)(WDKDebugPanelGerenalViewController *weakViewController);
@property (nonatomic, copy) void (^blockForViewWillAppear)(WDKDebugPanelGerenalViewController *weakViewController);

- (void)reloadData;

@end
