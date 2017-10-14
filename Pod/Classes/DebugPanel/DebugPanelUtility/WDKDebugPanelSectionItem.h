//
//  WDKDebugPanelSectionItem.h
//  Pods
//
//  Created by wesley chen on 16/11/15.
//
//

#import <Foundation/Foundation.h>

@interface WDKDebugPanelSectionItem : NSObject

@property (nonatomic, assign) CGFloat sectionHeaderViewHeight;
@property (nonatomic, assign) CGFloat sectionFooterViewHeight;

@property (nonatomic, strong) UIView *(^sectionHeaderView)(NSInteger section);
@property (nonatomic, strong) UIView *(^sectionFooterView)(NSInteger section);

@end
