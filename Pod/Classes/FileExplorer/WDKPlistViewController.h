//
//  WDKPlistViewController.h
//  Pods
//
//  Created by wesley chen on 17/4/8.
//
//

#import <UIKit/UIKit.h>

/**
 @note support the following files
    - plist file (plain text, binary)
    - json file
    - strings file (`key=value` plain text, binary plist)
    - mobileprovision file
 */
@interface WDKPlistViewController : UIViewController
- (instancetype)initWithFilePath:(NSString *)filePath;
@end
