//
//  UIAlertController+FixAutoLayoutWarning.h
//  WCDebugKit
//
//  Created by wesley_chen on 2021/3/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (FixAutoLayoutWarning)
- (void)pruneNegativeWidthConstraints;
@end

NS_ASSUME_NONNULL_END
