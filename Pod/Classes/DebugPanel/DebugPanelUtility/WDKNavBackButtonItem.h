//
//  WDKNavBackButtonItem.h
//  WCDebugKit
//
//  Created by wesley chen on 16/10/19.
//  Copyright © 2016年 wesley chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDKNavBackButtonItem : UIBarButtonItem

// Override properties
@property (nonatomic, strong) UIColor *tintColor;

// Substitutes of UIBarItem title
@property (nonatomic, copy) NSString *barItemTitle;

/*!
 *  The title transition animation allowed or not which is new-added in iOS 7+
 *
 *  Defautl is NO
 */
@property (nonatomic, assign) BOOL titleTransitionAnimated;

- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;

// 支持UITextAttributeFont和UITextAttributeTextColor
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;

+ (UIBarButtonItem *)navBackButtonLeadingSpaceItem;

@end
