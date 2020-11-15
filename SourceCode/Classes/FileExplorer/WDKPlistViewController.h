//
//  WDKPlistViewController.h
//  Pods
//
//  Created by wesley chen on 17/4/8.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WDKPlistViewController_FileType) {
    WDKPlistViewController_FileTypeUnsupported,
    WDKPlistViewController_FileTypePlist,
    WDKPlistViewController_FileTypeJSON,
    WDKPlistViewController_FileTypeJSONString,
};

/**
 @note support the following files
    - plist file (plain text, binary)
    - json file
    - strings file (`key=value` plain text, binary plist)
    - mobileprovision file
 */
@interface WDKPlistViewController : UIViewController

- (instancetype)initWithFilePath:(NSString *)filePath;

+ (BOOL)isSupportedFileWithFilePath:(NSString *)filePath fileType:(WDKPlistViewController_FileType * _Nullable)fileType rootObject:(id _Nullable * _Nullable)rootObject;

@end

NS_ASSUME_NONNULL_END
