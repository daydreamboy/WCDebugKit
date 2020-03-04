//
//  WDKUserInterfaceInspector.m
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

#import "WDKUserInterfaceInspector.h"
#import "WDKRuntimeTool.h"
#import "WDKMacroUtility.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface UIView (WDKUserInterfaceInspector)

@property (nonatomic, assign) CGColorRef debugBorderColor;
@property (nonatomic, assign) BOOL debugBorderColorShowed;

@property (nonatomic, assign) CGColorRef previousBorderColor;
@property (nonatomic, assign) CGFloat previousBorderWidth;

- (void)handleWCColorizedViewBorderToggleDidChangeNotification:(NSNotification *)notification;

@end

#pragma mark - WDKUserInterfaceInspector

NSNotificationName WCColorizedViewBorderToggleDidChangeNotification = @"WCColorizedViewBorderToggleDidChangeNotification";

@interface WDKUserInterfaceInspector ()
@property (nonatomic, assign) CGFloat debugViewBorderWidth;
@end

@implementation WDKUserInterfaceInspector

#pragma mark - Public Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static WDKUserInterfaceInspector *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[[self class] alloc] init];
        [sSharedInstance setup];
    });
    
    return sSharedInstance;
}

- (void)setSlowAnimationsEnabled:(BOOL)slowAnimationsEnabled {
    if (_slowAnimationsEnabled != slowAnimationsEnabled) {
        _slowAnimationsEnabled = slowAnimationsEnabled;
        
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            [self setSpeedForWindow:window];
        }
    }
}

- (void)setColorizedViewBorderEnabled:(BOOL)colorizedViewBorderEnabled {
    if (_colorizedViewBorderEnabled != colorizedViewBorderEnabled) {
        _colorizedViewBorderEnabled = colorizedViewBorderEnabled;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WCColorizedViewBorderToggleDidChangeNotification object:nil];
    }
}

#pragma mark - Private Methods

#pragma mark > Debug Animations

- (void)setup {
    [self registerNotifications];
    
    self.debugViewBorderWidth = 1.0f / [UIScreen mainScreen].scale;
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIWindowDidBecomeKeyNotification:)
                                                 name:UIWindowDidBecomeKeyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIKeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)handleUIWindowDidBecomeKeyNotification:(NSNotification *)notification {
    UIWindow *newKeyWindow = notification.object;
    [self setSpeedForWindow:newKeyWindow];
}

- (void)handleUIKeyboardWillShowNotification:(NSNotification *)notification {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        [self setSpeedForWindow:window];
    }
}

- (void)setSpeedForWindow:(UIWindow *)window {
    float speed = self.slowAnimationsEnabled ? 0.1 : 1.0;
    window.layer.speed = speed;
}

#pragma mark > Debug Borders

+ (void)setFrameBorderWithView:(UIView *)view {
    if ([WDKUserInterfaceInspector sharedInstance].colorizedViewBorderEnabled) {
        [self showFrameBorderForView:view];
    }
    else {
        [self hideFrameBorderForView:view];
    }
}

+ (void)showFrameBorderForView:(UIView *)view {
    if (view.debugBorderColorShowed) {
        return;
    }
    
    view.debugBorderColorShowed = YES;
    
    view.previousBorderColor = view.layer.borderColor;
    view.previousBorderWidth = view.layer.borderWidth;
    
    view.layer.borderColor = view.debugBorderColor;
    view.layer.borderWidth = [WDKUserInterfaceInspector sharedInstance].debugViewBorderWidth;
}

+ (void)hideFrameBorderForView:(UIView *)view {
    if (!view.debugBorderColorShowed) {
        return;
    }
    
    view.debugBorderColorShowed = NO;
    
    view.layer.borderColor = view.previousBorderColor;
    view.layer.borderWidth = view.previousBorderWidth;
}

+ (void)addNotificationsForView:(UIView *)view {
    [[NSNotificationCenter defaultCenter] addObserver:view selector:@selector(handleWCColorizedViewBorderToggleDidChangeNotification:) name:WCColorizedViewBorderToggleDidChangeNotification object:nil];
}

+ (void)removeNotificationsForView:(UIView *)view {
    [[NSNotificationCenter defaultCenter] removeObserver:view name:WCColorizedViewBorderToggleDidChangeNotification object:nil];
}

#pragma mark > Override Methods
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selector1 = @selector(initWithCoder:);
        SEL selector2 = @selector(initWithFrame:);
        SEL selector3 = NSSelectorFromString(@"dealloc");// @selector(dealloc); // Error: ARC forbids use of 'dealloc' in a @selector
        
        __block IMP originalInitWithCoderIMP = [WDKRuntimeTool replaceMethodWithSelector:selector1 onClass:[UIView class] withBlock:^UIView *(UIView *slf, NSCoder *coder) {
            UIView *retVal = ((UIView * (*)(UIView *, SEL, NSCoder *))originalInitWithCoderIMP)(slf, selector1, coder);
            
            [WDKUserInterfaceInspector setFrameBorderWithView:retVal];
            [WDKUserInterfaceInspector addNotificationsForView:slf];
            
            return retVal;
        }];
        
        __block IMP originalInitWithFrameIMP = [WDKRuntimeTool replaceMethodWithSelector:selector2 onClass:[UIView class] withBlock:^UIView *(UIView *slf, CGRect frame) {
            UIView *retVal = ((UIView * (*)(UIView *, SEL, CGRect))originalInitWithFrameIMP)(slf, selector2, frame);
            
            [WDKUserInterfaceInspector setFrameBorderWithView:retVal];
            [WDKUserInterfaceInspector addNotificationsForView:slf];
            
            return retVal;
        }];
        
        __block IMP originalDeallocIMP = [WDKRuntimeTool replaceMethodWithSelector:selector3 onClass:[UIView class] withBlock:^void(__unsafe_unretained UIView *slf) {
            [WDKUserInterfaceInspector removeNotificationsForView:slf];
            
            ((void (*)(UIView *, SEL))originalDeallocIMP)(slf, selector3);
        }];
    });
}

@end

#pragma mark - UIView (WDKUserInterfaceInspector)
@implementation UIView (WDKUserInterfaceInspector)

static NSString *UIView_WDKUserInterfaceInspector_debugBorderColor = @"UIView_WDKUserInterfaceInspector_debugBorderColor";
- (void)setDebugBorderColor:(CGColorRef)debugBorderColor {
    UIColor *color = [UIColor colorWithCGColor:debugBorderColor];
    objc_setAssociatedObject(self, &UIView_WDKUserInterfaceInspector_debugBorderColor, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGColorRef)debugBorderColor {
    UIColor *color = objc_getAssociatedObject(self, &UIView_WDKUserInterfaceInspector_debugBorderColor);
    if (!color) {
        CGFloat red = arc4random() % 255 / 255.0f;
        CGFloat green = arc4random() % 255 / 255.0f;
        CGFloat blue = arc4random() % 255 / 255.0f;
        color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        
        [self setDebugBorderColor:color.CGColor];
    }
    
    return color.CGColor;
}

static NSString *UIView_WDKUserInterfaceInspector_previousBorderColor = @"UIView_WDKUserInterfaceInspector_previousBorderColor";
- (void)setPreviousBorderColor:(CGColorRef)previousBorderColor {
    UIColor *color = [UIColor colorWithCGColor:previousBorderColor];
    objc_setAssociatedObject(self, &UIView_WDKUserInterfaceInspector_previousBorderColor, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGColorRef)previousBorderColor {
    UIColor *color = objc_getAssociatedObject(self, &UIView_WDKUserInterfaceInspector_previousBorderColor);
    return color.CGColor;
}

SYNTHESIZE_ASSOCIATED_PRIMITIVE(debugBorderColorShowed, setDebugBorderColorShowed, BOOL);
SYNTHESIZE_ASSOCIATED_PRIMITIVE(previousBorderWidth, setPreviousBorderWidth, CGFloat);

- (void)handleWCColorizedViewBorderToggleDidChangeNotification:(NSNotification *)notification {
    [WDKUserInterfaceInspector setFrameBorderWithView:self];
}

@end
