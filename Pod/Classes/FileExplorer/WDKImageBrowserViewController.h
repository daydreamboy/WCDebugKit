//
//  WDKImageBrowserViewController.h
//  Pods
//
//  Created by wesley chen on 17/1/6.
//
//

#import <UIKit/UIKit.h>

@interface WDKImageBrowserViewController : UIViewController
- (instancetype)initWithImages:(NSArray<UIImage *> *)images index:(NSUInteger)index;
@end
