//
//  WDKContextMenuCell.h
//  Pods
//
//  Created by wesley chen on 16/11/4.
//
//

#import <UIKit/UIKit.h>

#import "WDKContextMenuItemDefines.h"

@class WDKContextMenuCell;

@protocol WDKContextMenuCellDelegate <NSObject>
- (void)contextMenuCell:(WDKContextMenuCell *)cell contextMenuItemClicked:(WDKContextMenuItem)item withSender:(id)sender;
@end

/*!
 *  WARNING: Conflict with default menu actions. If you use default menu for cell, please implement these methods instead of using WDKContextMenuCell
 *
 - (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath;
 - (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
 - (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
 */
@interface WDKContextMenuCell : UITableViewCell

/*!
 *  Showed context menu items' types, e.g. @(WDKContextMenuItemView)
 *
 *  @warning If not defined, won't show context menu
 */
@property (nonatomic, strong) NSArray<NSNumber *> *contextMenuItemTypes;

/*!
 *  Showed context menu items' titles, related to `contextMenuItemTypes` <br/>
 *  If not defined, use default titles
 */
@property (nonatomic, strong) NSArray<NSString *> *contextMenuItemTitles;

/*!
 *  Allow menu items perform custom action
 */
@property (nonatomic, assign) WDKContextMenuItem allowCustomActionContextMenuItems;
@property (nonatomic, weak) id<WDKContextMenuCellDelegate> delegate;

/*!
 *  Show context menu centered on label. Default is YES
 */
@property (nonatomic, assign) BOOL showContextMenuAlwaysCenetered;

@end
