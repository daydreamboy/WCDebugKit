//
//  WDKInteractiveLabel.h
//  Pods
//
//  Created by wesley chen on 16/11/3.
//
//

#import <UIKit/UIKit.h>

#import "WDKContextMenuItemDefines.h"

@class WDKInteractiveLabel;

@protocol WDKInteractiveLabelDelegate <NSObject>
- (void)interactiveLabel:(WDKInteractiveLabel *)label contextMenuItemClicked:(WDKContextMenuItem)item withSender:(id)sender;
@end

@interface WDKInteractiveLabel : UILabel

@property (nonatomic, strong) NSArray<NSNumber *> *contextMenuItemTypes;            /**< showed context menu items */
@property (nonatomic, strong) NSArray<NSString *> *contextMenuItemTitles;
@property (nonatomic, assign) WDKContextMenuItem allowCustomActionContextMenuItems;  /**< allow menu items perform custom action */
@property (nonatomic, weak) id<WDKInteractiveLabelDelegate> delegate;
@property (nonatomic, assign) BOOL showContextMenuAlwaysCenetered;                  /**< show context menu centered on label. Default is YES */

@end
