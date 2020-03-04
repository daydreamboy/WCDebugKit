//
//  WDKHookManager.m
//  WCDebugKit
//
//  Created by wesley_chen on 2018/6/29.
//

#import "WDKHookManager.h"
#import "WDKDebugGroup_Internal.h"
#import "WDKRuntimeTool.h"
#import "WDKMacroUtility.h"

@interface UIImage ()
@property (nonatomic, copy) NSString *wdk_original_image_name;
@end

@implementation UIImage (Hook)
SYNTHESIZE_ASSOCIATED_OBJ(wdk_original_image_name, setWdk_original_image_name, UIImage *);
+ (UIImage *)imageNamed_intercepted:(NSString *)name {
    UIImage *image = [self imageNamed_intercepted:name];
    image.wdk_original_image_name = name;
    return image;
}
+ (UIImage *)imageNamed_intercepted:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(UITraitCollection *)traitCollection {
    UIImage *image = [self imageNamed_intercepted:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
    image.wdk_original_image_name = [NSString stringWithFormat:@"%@ (%@)", name, bundle];
    return image;
}
- (NSString *)debugDescription_intercepted {
    NSString *debugDescription = [self debugDescription_intercepted];
    return [debugDescription stringByAppendingFormat:@" WCDebugKit info > image name: %@", self.wdk_original_image_name];
}
@end

@interface WDKHookManager ()
@property (nonatomic, assign) BOOL hookImageEnabled;
@end

@implementation WDKHookManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static WDKHookManager *sInstance;
    dispatch_once(&onceToken, ^{
        sInstance = [[self alloc] init];
    });
    
    return sInstance;
}

- (WDKDebugGroup *)wdk_debugGroup {
    
    NSMutableArray *arrM = [NSMutableArray array];
    WDKDebugAction *action;
    
    action = [WDKToggleAction actionWithName:NSLocalizedString(@"Hook UIImage imageNamed", nil) enabled:[WDKHookManager sharedInstance].hookImageEnabled toggleBlock:^(BOOL enabled) {
        [WDKHookManager sharedInstance].hookImageEnabled = enabled;
        
        if (enabled) {
            [WDKRuntimeTool exchangeSelectorForClass:[UIImage class] origin:@selector(imageNamed:) substitute:@selector(imageNamed_intercepted:) classMethod:YES];
            [WDKRuntimeTool exchangeSelectorForClass:[UIImage class] origin:@selector(imageNamed:inBundle:compatibleWithTraitCollection:) substitute:@selector(imageNamed_intercepted:inBundle:compatibleWithTraitCollection:) classMethod:YES];
            [WDKRuntimeTool exchangeSelectorForClass:[UIImage class] origin:@selector(debugDescription) substitute:@selector(debugDescription_intercepted) classMethod:NO];

        }
        else {
            [WDKRuntimeTool exchangeSelectorForClass:[UIImage class] origin:@selector(imageNamed_intercepted:) substitute:@selector(imageNamed:) classMethod:YES];
            [WDKRuntimeTool exchangeSelectorForClass:[UIImage class] origin:@selector(imageNamed_intercepted:inBundle:compatibleWithTraitCollection:) substitute:@selector(imageNamed:inBundle:compatibleWithTraitCollection:) classMethod:YES];
            [WDKRuntimeTool exchangeSelectorForClass:[UIImage class] origin:@selector(debugDescription_intercepted) substitute:@selector(debugDescription) classMethod:NO];
        }
    }];
    [arrM addObject:action];
    
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:NSLocalizedString(@"Hook Manager", nil) actions:arrM];
    group.nameColor = [UIColor brownColor];
    
    return group;
}

@end
