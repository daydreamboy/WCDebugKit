//
//  WDKExpandableHeaderView.m
//  HelloExpandableTableView
//
//  Created by wesley chen on 16/12/26.
//  Copyright © 2016年 wesley chen. All rights reserved.
//

#import "WDKExpandableHeaderView.h"
#import <objc/runtime.h>

@interface WDKTableViewSectionInfo : NSObject
@property (nonatomic, weak) id<WDKExpandableHeaderViewDelegate> expandableHeaderView_delegate;
@property (nonatomic, weak) UITableView *tableView;
// key is index of section
@property (nonatomic, strong) NSMutableDictionary *headerViews;
@end

@implementation WDKTableViewSectionInfo
@end


@implementation UITableView (WDKExpandableHeaderView_Delegate)

static NSString *WDKTableViewSectionInfoObjectTag = @"WDKExpandableHeaderViewDelegateObjectTag";

- (void)setExpandableHeaderView_delegate:(id<WDKExpandableHeaderViewDelegate>)expandableHeaderView_delegate {
    
    WDKTableViewSectionInfo *info = objc_getAssociatedObject(self, &WDKTableViewSectionInfoObjectTag);
    if (!info.expandableHeaderView_delegate) {
        WDKTableViewSectionInfo *info = [WDKTableViewSectionInfo new];
        info.expandableHeaderView_delegate = expandableHeaderView_delegate;
        info.tableView = self;
        info.headerViews = [NSMutableDictionary dictionary];
        
        objc_setAssociatedObject(self, &WDKTableViewSectionInfoObjectTag, info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (id<WDKExpandableHeaderViewDelegate>)expandableHeaderView_delegate {
    WDKTableViewSectionInfo *info = objc_getAssociatedObject(self, &WDKTableViewSectionInfoObjectTag);
    return info.expandableHeaderView_delegate;
}

- (WDKExpandableHeaderView *)expandableHeaderViewAtSectionIndex:(NSInteger)sectionIndex {
    WDKTableViewSectionInfo *info = objc_getAssociatedObject(self, &WDKTableViewSectionInfoObjectTag);
    return info.headerViews[@(sectionIndex)];
}

- (void)recordExpandableHeaderView:(WDKExpandableHeaderView *)expandableHeaderView atSectionIndex:(NSInteger)sectionIndex {
    WDKTableViewSectionInfo *info = objc_getAssociatedObject(self, &WDKTableViewSectionInfoObjectTag);
    info.headerViews[@(sectionIndex)] = expandableHeaderView;
}

@end

@interface WDKExpandableHeaderView ()
@property (nonatomic, assign, readwrite) BOOL closed;
@property (nonatomic, strong) WDKTableViewSectionInfo *sectionInfo;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIButton *buttonIndicator;
@end

@implementation WDKExpandableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.closed = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpenOrClose:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)sectionTitle {
    self = [self initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.0f];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(frame) - 15, CGRectGetHeight(frame))];
        label.backgroundColor = [UIColor clearColor];
        label.text = sectionTitle;
        label.font = [UIFont boldSystemFontOfSize:17.0f];
        label.textColor = [UIColor colorWithRed:0.137f green:0.137f blue:0.137f alpha:1.0f];
        [self addSubview:label];
        _labelTitle = label;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.userInteractionEnabled = NO;
        button.transform = CGAffineTransformMakeRotation(M_PI);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"△" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [button sizeToFit];
        button.center = CGPointMake(CGRectGetWidth(frame) - CGRectGetWidth(button.bounds) / 2.0, CGRectGetHeight(frame) / 2.0);
        [self addSubview:button];
        _buttonIndicator = button;
    }
    return self;
}

#pragma mark - Actions

- (void)toggleOpenOrClose:(id)sender {
    WDKExpandableHeaderView *headerView = (WDKExpandableHeaderView *)[(UITapGestureRecognizer *)sender view];
    WDKTableViewSectionInfo *info = objc_getAssociatedObject([self superTableView], &WDKTableViewSectionInfoObjectTag);
    
    NSInteger sectionIndex = 0;
    for (NSNumber *number in info.headerViews) {
        WDKExpandableHeaderView *view = info.headerViews[number];
        if (view == headerView) {
            sectionIndex = [number integerValue];
            break;
        }
    }
    
    if (headerView.closed) {
        // to open
        NSInteger sectionOpened = sectionIndex;
        
        // Get the number of rows in the open section
        NSInteger countOfRowsToInsert = [info.expandableHeaderView_delegate WDKExpandableHeaderView_tableView:info.tableView numberOfRowsInSection:sectionOpened];
        NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
        
        // Gather the indexes for inserting
        for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
        }
        
        headerView.closed = NO;
        
        // Commit the animation
        [CATransaction begin];
        [info.tableView beginUpdates];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _buttonIndicator.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:nil];
        [CATransaction setCompletionBlock:^{
            if ([info.expandableHeaderView_delegate respondsToSelector:@selector(sectionDidExpandAtIndex:expandableHeaderView:)]) {
                [info.expandableHeaderView_delegate sectionDidExpandAtIndex:sectionOpened expandableHeaderView:headerView];
            }
        }];
        [info.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationTop];
        [info.tableView endUpdates];
        [CATransaction commit];
    }
    else {
        // to close
        NSInteger sectionClosed = sectionIndex;
        
        // Get the number of rows in the close section
        NSInteger countOfRowsToDelete = [info.expandableHeaderView_delegate WDKExpandableHeaderView_tableView:info.tableView numberOfRowsInSection:sectionClosed];
        if (countOfRowsToDelete > 0) {
            NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
            
            // Gather the indexes for deleting
            for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
            }
            
            headerView.closed = YES;
            
            // Commit the animation
            [CATransaction begin];
            [info.tableView beginUpdates];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _buttonIndicator.transform = CGAffineTransformMakeRotation(-2 * M_PI);
            } completion:nil];
            [CATransaction setCompletionBlock:^{
                if ([info.expandableHeaderView_delegate respondsToSelector:@selector(sectionDidCollapseAtIndex:expandableHeaderView:)]) {
                    [info.expandableHeaderView_delegate sectionDidCollapseAtIndex:sectionClosed expandableHeaderView:headerView];
                }
            }];
            [info.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
            [info.tableView endUpdates];
            [CATransaction commit];
        }
    }
}

#pragma mark - Helpers

- (UITableView *)superTableView {
    
    id view = [(UIView *)self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    
    return tableView;
}

@end
