//
//  WDKNavBackButtonItem.m
//  WCDebugKit
//
//  Created by wesley chen on 16/10/19.
//  Copyright © 2016年 wesley chen. All rights reserved.
//

#import "WDKNavBackButtonItem.h"

#ifndef UICOLOR_RGB
#define UICOLOR_RGB(color) [UIColor colorWithRed : (((color) >> 16) & 0xFF) / 255.0 green : (((color) >> 8) & 0xFF) / 255.0 blue : ((color) & 0xFF) / 255.0 alpha : 1.0]
#endif

@interface WDKNavBackButtonItem ()
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) id receiver;
@property (nonatomic, strong) UIButton *barButton;
@end

@implementation WDKNavBackButtonItem

@synthesize tintColor = _tintColor;

#pragma mark - Public Methods

- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    _receiver = target;
    _selector = action;
    
    UIFont *font = (style == UIBarButtonItemStyleDone ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17]);
    
    CGSize calculatedSize = CGSizeZero;
    if ([title respondsToSelector:@selector(sizeWithAttributes:)]) {
        calculatedSize = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    }
    else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        calculatedSize = [title sizeWithFont:font];
#pragma GCC diagnostic pop
    }
    
    CGSize textSize = title.length > 0 ? calculatedSize : CGSizeZero;
    UIImage *arrowImage = [self createArrowImageWithTintColor:nil];
    CGFloat space = 6.0f;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(0, 0, arrowImage.size.width + space + textSize.width, 44);
    button.backgroundColor = [UIColor clearColor];
    button.exclusiveTouch = YES;
    button.titleLabel.font = font;
    
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setImage:arrowImage forState:UIControlStateNormal];
    [button setImage:arrowImage forState:UIControlStateSelected];
    [button setImage:[self createArrowImageWithTintColor:[UICOLOR_RGB(0x0076FF) colorWithAlphaComponent:0.2]] forState:UIControlStateHighlighted];
    [button setImage:[self createArrowImageWithTintColor:[UICOLOR_RGB(0x8E8E93) colorWithAlphaComponent:0.8]] forState:UIControlStateDisabled];
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, space, 0, 0);
    
    [button setTitleColor:UICOLOR_RGB(0x0076FF) forState:UIControlStateNormal];
    [button setTitleColor:UICOLOR_RGB(0x0076FF) forState:UIControlStateSelected];
    [button setTitleColor:[UICOLOR_RGB(0x0076FF) colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    [button setTitleColor:[UICOLOR_RGB(0x8E8E93) colorWithAlphaComponent:0.8] forState:UIControlStateDisabled];
    
    self = [super initWithCustomView:button];
    
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _barButton = button;

    return self;
}

+ (UIBarButtonItem *)navBackButtonLeadingSpaceItem {
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceItem setWidth:-8];
    
    return spaceItem;
}

#pragma mark Setters

- (void)setTintColor:(UIColor *)tintColor {
    [_barButton setImage:[self createArrowImageWithTintColor:tintColor] forState:UIControlStateNormal];
    [_barButton setImage:[self createArrowImageWithTintColor:tintColor] forState:UIControlStateSelected];
    [_barButton setImage:[self createArrowImageWithTintColor:[tintColor colorWithAlphaComponent:0.2]] forState:UIControlStateHighlighted];
    [_barButton setImage:[self createArrowImageWithTintColor:[UICOLOR_RGB(0x8E8E93) colorWithAlphaComponent:0.8]] forState:UIControlStateDisabled];
    
    [_barButton setTitleColor:tintColor forState:UIControlStateNormal];
    [_barButton setTitleColor:tintColor forState:UIControlStateSelected];
    [_barButton setTitleColor:[tintColor colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    [_barButton setTitleColor:[UICOLOR_RGB(0x8E8E93) colorWithAlphaComponent:0.8] forState:UIControlStateDisabled];
}

- (void)setBarItemTitle:(NSString *)barItemTitle {
    if (!_titleTransitionAnimated) {
        [UIView setAnimationsEnabled:NO];
    }
    self.title = barItemTitle;
    if (!_titleTransitionAnimated) {
        [UIView setAnimationsEnabled:YES];
    }
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    UIFont *font = attributes[UITextAttributeFont];
    UIColor *textColor = attributes[UITextAttributeTextColor];
#pragma GCC diagnostic pop

    if (textColor) {
        [_barButton setTitleColor:textColor forState:UIControlStateNormal];
        [_barButton setTitleColor:[textColor colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    }
    
    if (font) {
        _barButton.titleLabel.font = font;
    }
}

#pragma mark - Actions

- (void)buttonClicked:(UIButton *)sender {
    IMP imp = [_receiver methodForSelector:_selector];
    void (*func)(id, SEL, UIBarButtonItem *) = (void *)imp;
    func(_receiver, _selector, self);
}

#pragma mark

- (UIImage *)createArrowImageWithTintColor:(UIColor *)tintColor {
    
    CGRect rect = CGRectMake(0, 0, 13, 21);
    float width = rect.size.width;
    float height = rect.size.height;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, width * 5.0/6.0, height * 0.0/10.0);
    CGContextAddLineToPoint(context, width * 0.0/6.0, height * 5.0/10.0);
    CGContextAddLineToPoint(context, width * 5.0/6.0, height * 10.0/10.0);
    CGContextAddLineToPoint(context, width * 6.0/6.0, height * 9.0/10.0);
    CGContextAddLineToPoint(context, width * 2.0/6.0, height * 5.0/10.0);
    CGContextAddLineToPoint(context, width * 6.0/6.0, height * 1.0/10.0);
    CGContextClosePath(context);
    
    if (!tintColor) {
        tintColor = [UIView new].tintColor;
    }
    
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
