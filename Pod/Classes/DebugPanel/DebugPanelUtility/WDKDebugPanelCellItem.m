//
//  WDKDebugPanelCellItem.m
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import "WDKDebugPanelCellItem.h"

@implementation WDKDebugPanelCellItem

+ (instancetype)itemWithType:(WDKDebugPanelCellType)type {
    WDKDebugPanelCellItem *item = [WDKDebugPanelCellItem new];
    item.cellType = type;
    
    return item;
}

@end
