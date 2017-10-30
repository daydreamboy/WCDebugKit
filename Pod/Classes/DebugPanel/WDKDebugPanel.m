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

#import <objc/runtime.h>

#define WDK_RESOURCE_BUNDLE     @"WCDebugKit.bundle"
#define WDK_BUILTIN_TOOLS       @"builtin_tools.plist"

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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class statusBarClass = NSClassFromString(@"UIStatusBar");
        [self exchangeSelectorForClass:statusBarClass origin:@selector(setFrame:) substitute:@selector(setFrame_intercepted:)];
        [self exchangeSelectorForClass:statusBarClass origin:NSSelectorFromString(@"dealloc") substitute:@selector(dealloc_intercepted)];
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

+ (void)exchangeSelectorForClass:(Class)cls origin:(SEL)origin substitute:(SEL)substitute {
    Method origMethod = class_getInstanceMethod(cls, origin);
    Method replaceMethod = class_getInstanceMethod(cls, substitute);
    
    if (class_addMethod(cls, origin, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod))) {
        class_replaceMethod(cls, substitute, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, replaceMethod);
    }
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
    if (statusBar) {
#if DEBUG
        NSLog(@"install DebugPanel on statusBar successfully");
#endif
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:[WDKDebugPanel sharedPanel] action:@selector(showDebugPanelFromStatusBar:)];
        tapRecognizer.numberOfTapsRequired = 3;
        [statusBar addGestureRecognizer:tapRecognizer];
    }
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
                hostViewController = [[[UIApplication sharedApplication].delegate window] rootViewController];
            }
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:actionsViewController];
            
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

#pragma mark - Load Tools

- (void)loadBuiltinTools {
    NSString *fileName = WDK_BUILTIN_TOOLS;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", [bundle bundlePath], WDK_RESOURCE_BUNDLE, fileName];
    NSArray *tools = [NSArray arrayWithContentsOfFile:filePath];
    
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
