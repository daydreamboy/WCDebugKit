//
//  UIAlertController+FixAutoLayoutWarning.m
//  WCDebugKit
//
//  Created by wesley_chen on 2021/3/28.
//

#import "UIAlertController+FixAutoLayoutWarning.h"

@implementation UIAlertController (FixAutoLayoutWarning)

- (void)pruneNegativeWidthConstraints {
    [[self.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        [subview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([constraint.debugDescription containsString:@"width == - 16"]) {
                [subview removeConstraint:constraint];
            }
        }];
    }];
    
//    for subView in self.view.subviews {
//
//
//        for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
//            subView.removeConstraint(constraint)
//        }
//    }
}

@end
