//
//  WDKExpandableHeaderView.h
//  HelloExpandableTableView
//
//  Created by wesley chen on 16/12/26.
//  Copyright © 2016年 wesley chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDKExpandableHeaderView;

@protocol WDKExpandableHeaderViewDelegate <NSObject>

@required
- (NSInteger)WDKExpandableHeaderView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@optional
- (void)sectionDidExpandAtIndex:(NSInteger)sectionIndex expandableHeaderView:(WDKExpandableHeaderView *)expandableHeaderView;
- (void)sectionDidCollapseAtIndex:(NSInteger)sectionIndex expandableHeaderView:(WDKExpandableHeaderView *)expandableHeaderView;

@end

@interface UITableView (WDKExpandableHeaderView_Delegate)
@property (nonatomic, weak) id<WDKExpandableHeaderViewDelegate> expandableHeaderView_delegate;

- (WDKExpandableHeaderView *)expandableHeaderViewAtSectionIndex:(NSInteger)sectionIndex;
- (void)recordExpandableHeaderView:(WDKExpandableHeaderView *)expandableHeaderView atSectionIndex:(NSInteger)sectionIndex;

@end

@interface WDKExpandableHeaderView : UIView

@property (nonatomic, assign, readonly) BOOL closed;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)sectionTitle;

@end
