//
//  WDKDebugPanel.m
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import "WDKDebugPanel.h"
#import "WDKDebugPanel_Internal.h"
#import "WDKDebugActionsViewController.h"
#import "WDKRuntimeTool.h"
#import "WCDebugKit_Configuration.h"
#import <objc/runtime.h>

// 默认3次唤起DebugPanel（状态栏和entry views）
#define WDK_DEFAULT_TAP_COUNT   3

#define WDK_UIViewResideInUIWindow(__view) ({                           \
    UIWindow *parentWindow = nil;                                       \
    UIResponder *__responder = __view;                                  \
    while ([__responder isKindOfClass:[UIView class]]                   \
        || [__responder isKindOfClass:[UIViewController class]]) {      \
        if ([__responder isKindOfClass:[UIWindow class]]) { break; }    \
        __responder = [__responder nextResponder];                      \
    }                                                                   \
    if ([__responder isKindOfClass:[UIWindow class]]) {                 \
        parentWindow = (UIWindow *)__responder;                         \
    }                                                                   \
    parentWindow;                                                       \
})

// >= `13.0`
#ifndef IOS13_OR_LATER
#define IOS13_OR_LATER          ([[[UIDevice currentDevice] systemVersion] compare:@"13.0" options:NSNumericSearch] != NSOrderedAscending)
#endif

// 如果将调试插件集成到WCDebugKit中，每个app中需定义名为WDKDebugPluginsInfo类，它实现WDKDebugPluginsDataSource协议中的方法
static NSString *ODKPluginsRegisterClass = @"WDKDebugPluginsInfo";

@interface WDKDebugPanel ()

@property (nonatomic, strong) NSString *pluginsPlistPath;

@property (nonatomic, strong) NSArray<WDKDebugGroup *> *installedActionGroups;

@property (nonatomic, strong) NSMutableArray<id<WDKDebugPanelDataSource>> *registeredTools; /**< registered by code */
@property (nonatomic, strong) NSMutableArray<id<WDKDebugPanelDataSource>> *pluginsTools; /**< registered by plugins plist */
@property (nonatomic, strong) NSMutableArray<id<WDKDebugPanelDataSource>> *builtinTools; /**< registered by builtin plist */
@property (nonatomic, strong) NSMutableArray<id<WDKDebugPanelDataSource>> *externalTools; /**< registered by remote plist */

@property (nonatomic, assign) BOOL needExternalTools;
@property (nonatomic, assign) BOOL statusBarEntryEnabled;

+ (void)installDebugPanelOnStatusBar;
+ (void)registerTakeScreenshotNotification;
+ (void)toggleDebugPanel;

@end


static UIView *WDK_statusBarInstance = nil;

@interface UIView (WDKDebugPanel)
+ (UIView *)odt_statusBarInstance;
@end

@implementation UIView (WDKDebugPanel)

+ (UIView *)odt_statusBarInstance {
    return WDK_statusBarInstance;
}

#if DEBUG

// Note: make sure the main project set other_flag has -ObjC
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class statusBarClass1 = NSClassFromString(@"UIStatusBar");
        [WDKRuntimeTool exchangeSelectorForClass:statusBarClass1 origin:@selector(setFrame:) substitute:@selector(setFrame_intercepted:) classMethod:NO];
        [WDKRuntimeTool exchangeSelectorForClass:statusBarClass1 origin:NSSelectorFromString(@"dealloc") substitute:@selector(dealloc_intercepted) classMethod:NO];
        
        // @see https://www.reddit.com/r/jailbreakdevelopers/comments/bsx3jz/adding_a_tap_gesture_to_iphone_x_type_statusbar/
        Class statusBarClass2 = NSClassFromString(@"UIStatusBar_Modern");
        [WDKRuntimeTool exchangeSelectorForClass:statusBarClass2 origin:@selector(setFrame:) substitute:@selector(setFrame_intercepted:) classMethod:NO];
        [WDKRuntimeTool exchangeSelectorForClass:statusBarClass2 origin:NSSelectorFromString(@"dealloc") substitute:@selector(dealloc_intercepted) classMethod:NO];
        
        if (IOS13_OR_LATER) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [WDKDebugPanel installDebugPanelOnStatusBar];
            });
        }
        
#if TARGET_OS_SIMULATOR
        dispatch_async(dispatch_get_main_queue(), ^{
            Class managerClass = NSClassFromString(@"FLEXKeyboardShortcutManager");
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
            if ([managerClass respondsToSelector:@selector(sharedManager)]) {
                id managerInstance = [managerClass performSelector:@selector(sharedManager)];
                
                SEL selector = @selector(registerSimulatorShortcutWithKey:modifiers:action:description:);
                if ([managerInstance respondsToSelector:selector]) {
                    NSMethodSignature *methodSignature = [managerInstance methodSignatureForSelector:selector];
                    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    
                    NSString *key = @"p";
                    UIKeyModifierFlags modifiers = UIKeyModifierCommand | UIKeyModifierShift;
                    dispatch_block_t action = ^{
                        [WDKDebugPanel toggleDebugPanel];
                    };
                    NSString *description = @"Toggle Debug Panel";
                    
                    invocation.target = managerInstance;
                    invocation.selector = selector;
                    [invocation setArgument:&key atIndex:2];
                    [invocation setArgument:&modifiers atIndex:3];
                    [invocation setArgument:&action atIndex:4];
                    [invocation setArgument:&description atIndex:5];
                    
                    [invocation invoke];
                }
            }            
#pragma GCC diagnostic pop
        });
#endif
    });
}

- (void)setFrame_intercepted:(CGRect)frame {
    [self setFrame_intercepted:frame];
    WDK_statusBarInstance = self;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WDKDebugPanel installDebugPanelOnStatusBar];
    });
}

- (void)dealloc_intercepted {
    WDK_statusBarInstance = nil;
    [self dealloc_intercepted];
}

#endif

@end

#pragma mark

@implementation WDKDebugPanel

static WDKDebugPanel *WDK_sharedPanel;

+ (instancetype)sharedPanel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WDK_sharedPanel = [[WDKDebugPanel alloc] init];
    });
    
    return WDK_sharedPanel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.actionGroupsM = [NSMutableArray array];
        self.registeredTools = [NSMutableArray array];
        self.pluginsTools = [NSMutableArray array];
        self.builtinTools = [NSMutableArray array];
        self.externalTools = [NSMutableArray array];
        self.needExternalTools = YES;
        self.statusBarEntryEnabled = YES;
    }
    return self;
}

+ (void)installDebugPanelOnStatusBar {
    UIView *statusBar = [UIView odt_statusBarInstance];
    if (!statusBar) {
        // @see https://stackoverflow.com/a/26451989
        @try {
            statusBar = (UIView *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
        }
        @catch (NSException *exception) {
        }
    }
    
    if (!statusBar && IOS13_OR_LATER) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#pragma GCC diagnostic ignored "-Wunguarded-availability-new"
        // @see https://juejin.im/post/5d650aede51d4561c41fb854
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
            UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
            if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                statusBar = [localStatusBar performSelector:@selector(statusBar)];
                
                UIView *frontStatusBar = [[UIView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(statusBarManager.statusBarFrame), 88)];
                frontStatusBar.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
//                [statusBar addSubview:frontStatusBar];
//                [[UIApplication sharedApplication].delegate.window addSubview:frontStatusBar];
                
                statusBar = frontStatusBar;
            }
        }
#pragma GCC diagnostic pop
    }
    
    if (statusBar) {
#if DEBUG
        NSLog(@"install DebugPanel on statusBar successfully");
#endif
        // one finger with five taps
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:[WDKDebugPanel sharedPanel] action:@selector(showDebugPanelFromStatusBar:)];
        tapRecognizer.numberOfTapsRequired = 5;
        [statusBar addGestureRecognizer:tapRecognizer];
        
        // two fingers with two taps
        UITapGestureRecognizer *twoFingersTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:[WDKDebugPanel sharedPanel] action:@selector(showDebugPanelFromStatusBar:)];
        twoFingersTapRecognizer.numberOfTapsRequired = 2;
        twoFingersTapRecognizer.numberOfTouchesRequired = 2;
        [statusBar addGestureRecognizer:twoFingersTapRecognizer];
    }
    
    [self registerTakeScreenshotNotification];
}

#pragma mark Public Methods

#pragma mark > 第一种方式

+ (void)installDebugPanelWithView:(UIView *)view {
    [self installDebugPanelWithView:view groupsBlock:nil tapCount:WDK_DEFAULT_TAP_COUNT];
}

+ (void)installDebugPanelWithView:(UIView *)view tapCount:(NSUInteger)tapCount {
    [self installDebugPanelWithView:view groupsBlock:nil tapCount:tapCount];
}

#pragma mark > 第二种方式

+ (void)showDebugPanel {
    [[WDKDebugPanel sharedPanel] showDebugPanel:nil];
}

#pragma mark > 第三种方式（默认）

+ (void)enableStatusBarEntry:(BOOL)enabled {
    [WDKDebugPanel sharedPanel].statusBarEntryEnabled = enabled;
}

#pragma mark

+ (void)installDebugPanelWithView:(UIView*)view groupsBlock:(NSArray<WDKDebugGroup *> *(^)(void))block tapCount:(NSUInteger)tapCount {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:[WDKDebugPanel sharedPanel] action:@selector(showDebugPanel:)];
    tap.numberOfTapsRequired = tapCount;
    
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    
    if (block) {
        NSArray *groups = block();
        if (groups.count) {
            [WDKDebugPanel sharedPanel].installedActionGroups = groups;
        }
    }
}

+ (void)configureTransitionWithEnterBlock:(void (^)(UIViewController *viewController))enterBlock exitBlock:(void (^)(UIViewController *viewController))exitBlock {
    [WDKDebugPanel sharedPanel].enterBlock = enterBlock;
    [WDKDebugPanel sharedPanel].exitBlock = exitBlock;
}

+ (void)addDataSource:(id<WDKDebugPanelDataSource>)dataSource {
    if (dataSource && ![[WDKDebugPanel sharedPanel].registeredTools containsObject:dataSource]) {
        [[WDKDebugPanel sharedPanel].registeredTools addObject:dataSource];
    }
}

+ (void)removeDataSource:(id<WDKDebugPanelDataSource>)dataSource {
    if (dataSource) {
        [[WDKDebugPanel sharedPanel].registeredTools removeObject:dataSource];
    }
}

+ (void)cleanup {
    [WDKDebugPanel sharedPanel].presenting = NO;
    [WDKDebugPanel sharedPanel].navController = nil;
    
    [[WDKDebugPanel sharedPanel].actionGroupsM removeAllObjects];
    
    [[WDKDebugPanel sharedPanel].registeredTools removeAllObjects];
    [[WDKDebugPanel sharedPanel].pluginsTools removeAllObjects];
    [[WDKDebugPanel sharedPanel].builtinTools removeAllObjects];
    [[WDKDebugPanel sharedPanel].externalTools removeAllObjects];
}

+ (void)refreshDebugPanel {
    WDKDebugActionsViewController *vc = [[[WDKDebugPanel sharedPanel].navController viewControllers] lastObject];
    [vc reloadData];
}

+ (void)registerTakeScreenshotNotification {
    [[NSNotificationCenter defaultCenter] addObserver:[WDKDebugPanel sharedPanel] selector:@selector(handleUIApplicationUserDidTakeScreenshotNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

+ (void)toggleDebugPanel {
    if (![WDKDebugPanel sharedPanel].presenting) {
        [[WDKDebugPanel sharedPanel] showDebugPanel:nil];
    }
    else {
        [[WDKDebugPanel sharedPanel] dismissDebugPanel];
    }
}

- (void)dismissDebugPanel {
    [self.navController dismissViewControllerAnimated:YES completion:^{
        self.presenting = NO;
        [WDKDebugPanel cleanup];
    }];
}

#pragma mark - Actions

- (void)showDebugPanel:(UITapGestureRecognizer *)sender {
    if (!self.presenting) {
        
        [self.actionGroupsM removeAllObjects];
        [self.actionGroupsM addObjectsFromArray:self.installedActionGroups];
        
        [self loadBuiltinTools];    // load both in Debug and Release
        [self loadPluginsTools];    // load only in Debug
        [self loadRegisteredTools]; // load only in Debug
        
        self.presenting = YES;
        
        WDKDebugActionsViewController *actionsViewController = [[WDKDebugActionsViewController alloc] init];
        
        actionsViewController.actionGroups = self.actionGroupsM;
        actionsViewController.flagPresentByInternal = YES;
        
        if (self.enterBlock) {
            self.enterBlock(actionsViewController);
        }
        else {
            // try to get hostViewController from tapped view's window, if not found use AppDelegate's window
            UIWindow *window = WDK_UIViewResideInUIWindow(sender.view);
            UIViewController *hostViewController = window.rootViewController;
            
            if (!hostViewController) {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
                    hostViewController = [[[UIApplication sharedApplication].delegate window] rootViewController];
                }
                else {
                    // @see https://stackoverflow.com/a/57978362
                    for (UIWindow *window in [UIApplication sharedApplication].windows) {
                        if (window.isKeyWindow) {
                            hostViewController = [window rootViewController];
                            break;
                        }
                    }
                }
            }
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:actionsViewController];
            navController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            if (hostViewController.isViewLoaded && hostViewController.view.window) {
                // if hostViewController is visible, use it to present
                // @see https://stackoverflow.com/questions/2777438/how-to-tell-if-uiviewcontrollers-view-is-visible
                [hostViewController presentViewController:navController animated:YES completion:nil];
            }
            else if (hostViewController.presentedViewController) {
                // check hostViewController has presented view controller, if it has, use the presented view controller to present
                [hostViewController.presentedViewController presentViewController:navController animated:YES completion:nil];
            }
            else {
                NSLog(@"Show debug panel from status bar failed, please check reason");
            }
            
            self.navController = navController;
        }
    }
}

- (void)showDebugPanelFromStatusBar:(UISwipeGestureRecognizer *)sender {
    if (self.statusBarEntryEnabled) {
        [self showDebugPanel:nil];
    }
}

#pragma mark - NSNotification

- (void)handleUIApplicationUserDidTakeScreenshotNotification:(NSNotification *)notification {
    [[WDKDebugPanel sharedPanel] showDebugPanel:nil];
}

#pragma mark - Load Tools

- (void)loadBuiltinTools {
    NSArray *tools = WDK_BUILTIN_TOOLS;
    
    for (NSString *cls in tools) {
        id<WDKDebugPanelDataSource> dataSource = [[NSClassFromString(cls) alloc] init];
        if ([dataSource respondsToSelector:@selector(wdk_debugGroup)]) {
            WDKDebugGroup *group = [dataSource wdk_debugGroup];
            if (group) {
                [self.actionGroupsM addObject:group];
            }
        }
    }
}

- (void)loadPluginsTools {
#if DEBUG
    if (NSClassFromString(ODKPluginsRegisterClass)) {
        
        NSArray *tools = nil;
        
        Class pluginsInfoClass = NSClassFromString(ODKPluginsRegisterClass);
        id<WDKDebugPluginsDataSource> pluginsInfo = [[pluginsInfoClass alloc] init];
        if ([pluginsInfo respondsToSelector:@selector(wdk_pluginsClasses)]) {
            NSArray<NSString *> *classes = [pluginsInfo wdk_pluginsClasses];
            if (classes) {
                tools = classes;
            }
        }
        else if ([pluginsInfo respondsToSelector:@selector(wdk_pluginsPlistPath)]) {
            NSString *plugin_tools_path = [pluginsInfo wdk_pluginsPlistPath];
            
            if (plugin_tools_path.length) {
                NSBundle *bundle = [NSBundle mainBundle];
                tools = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [bundle bundlePath], plugin_tools_path]];
            }
        }
        
        if (tools) {
            for (NSString *cls in tools) {
                id<WDKDebugPanelDataSource> dataSource = [[NSClassFromString(cls) alloc] init];
                if ([dataSource respondsToSelector:@selector(wdk_debugGroup)]) {
                    WDKDebugGroup *group = [dataSource wdk_debugGroup];
                    if (group) {
                        [self.actionGroupsM addObject:group];
                    }
                }
            }
        }
    }
#endif
}

- (void)loadRegisteredTools {
#if DEBUG
    for (id<WDKDebugPanelDataSource> dataSource in self.registeredTools) {
        if ([dataSource respondsToSelector:@selector(wdk_debugGroup)]) {
            WDKDebugGroup *group = [dataSource wdk_debugGroup];
            if ([group isKindOfClass:[WDKDebugGroup class]]) {
                [self.actionGroupsM addObject:group];
            }
        }
    }
#endif
}

- (void)loadExternalToolsFromArray:(NSArray *)array {
#if DEBUG
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSString *cls in array) {
            id<WDKDebugPanelDataSource> dataSource = [[NSClassFromString(cls) alloc] init];

            if ([dataSource respondsToSelector:@selector(wdk_debugGroup)]) {
                WDKDebugGroup *group = [dataSource wdk_debugGroup];
                if ([group isKindOfClass:[WDKDebugGroup class]]) {
                    [self.actionGroupsM addObject:group];
                }
            }
        }
    }
#endif
}

@end
