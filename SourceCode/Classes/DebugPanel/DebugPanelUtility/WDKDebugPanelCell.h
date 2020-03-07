//
//  WDKDebugPanelCell.h
//  Pods
//
//  Created by wesley chen on 16/8/27.
//
//

#import <UIKit/UIKit.h>
#import "WDKDebugPanelCellItem.h"

@interface WDKDebugPanelCell : UITableViewCell

- (instancetype)initWithType:(WDKDebugPanelCellType)type;
- (void)configureCellWithItem:(WDKDebugPanelCellItem *)item;
+ (CGFloat)heightForCellType:(WDKDebugPanelCellType)type;

+ (WDKDebugPanelCell *)dequeueReusableCellWithTableView:(UITableView *)tableView type:(WDKDebugPanelCellType)type;


// WDKDebugPanelCellTypeSwitch
- (void)startLoading;
- (void)stopLoading;
- (void)setToggleOn:(BOOL)on;

@end
