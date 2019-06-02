//
//  WDKViewExplorerOverlayView.m
//  WCDebugKit
//
//  Created by wesley_chen on 2018/12/3.
//

#import "WDKViewExplorerOverlayView.h"
#import "UIApplication+WDK.h"
#import "WDKViewExplorerWindow.h"
#import "WDKDebugActionsViewController.h"
#import "WDKDebugPanelGerenalViewController.h"
#import "WCViewControllerTool.h"

@interface WDKViewExplorerOverlayView ()
@property (nonatomic, assign) WDKViewExplorerMode currentMode;
@property (nonatomic, strong) UIView *panel;

/// Borders of all the visible view in hierachy at the selection point
/// The keys are NSValues with the correponding view (nonretained).
@property (nonatomic, strong) NSDictionary *outlineViewsForVisibleViews;

/// All views whose contain the selection point
@property (nonatomic, strong) NSArray *viewContainsTapPoint;

/// The view that we're currently highlighting with an overlay and displaying details for.
@property (nonatomic, strong) UIView *selectedView;
/// A colored transparent overlay to indicate that the view is selected.
@property (nonatomic, strong) UIView *selectedViewOverlay;
@end

@implementation WDKViewExplorerOverlayView

static WDKViewExplorerOverlayView *sInstance;
static BOOL sEnabled;

@dynamic enabled;

#pragma mark - Public Methods

+ (void)setEnabled:(BOOL)enabled {
    sEnabled = enabled;
}

+ (BOOL)enabled {
    return sEnabled;
}

+ (void)installOverlayToFrontestWindow {
    if (sEnabled) {
        UIWindow *topMostWindow = [[UIApplication sharedApplication].windows lastObject];
        [self addOverlayToWindow:topMostWindow];
    }
}

+ (void)uninstallOverlay {
    [sInstance removeFromSuperview];
    sInstance = nil;
    sEnabled = NO;
}

//- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates {
//    BOOL shouldReceiveTouch = NO;
//    
//    CGPoint pointInLocalCoordinates = [self convertPoint:pointInWindowCoordinates fromView:nil];
//    
//    // Always if it's on the toolbar
//    if (CGRectContainsPoint(self.panel.frame, pointInLocalCoordinates)) {
//        shouldReceiveTouch = YES;
//    }
//    
//    // Always if we're in selection mode
//    if (!shouldReceiveTouch && self.currentMode == WDKViewExplorerModeSelect) {
//        shouldReceiveTouch = YES;
//    }
//    
//    // Always in move mode too
//    if (!shouldReceiveTouch && self.currentMode == WDKViewExplorerModeMove) {
//        shouldReceiveTouch = YES;
//    }
//    
//    // Always if we have a modal presented
//    if (!shouldReceiveTouch && self.presentedViewController) {
//        shouldReceiveTouch = YES;
//    }
//    
//    return shouldReceiveTouch;
//}

#pragma mark -

+ (void)addOverlayToWindow:(UIWindow *)window {
    if (sInstance.superview != window) {
        [sInstance removeFromSuperview];
        sInstance = [[WDKViewExplorerOverlayView alloc] initWithFrame:window.bounds];
        [window addSubview:sInstance];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentMode = WDKViewExplorerModeSelect;
        [self addSubview:self.panel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWDKInterfaceEventNotification:) name:WDKInterfaceEventNotification object:nil];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (NSString *className in [self whiteListForInternalViewControllerClass]) {
        if ([[WCViewControllerTool topViewControllerOnWindow:keyWindow] isKindOfClass:NSClassFromString(className)]) {
            return NO;
        }
    }
    
    return [super pointInside:point withEvent:event];
}

- (NSArray<NSString *> *)whiteListForInternalViewControllerClass {
    return @[
             NSStringFromClass([WDKDebugActionsViewController class]),
             NSStringFromClass([WDKDebugPanelGerenalViewController class]),
             ];
}

#pragma mark - Getters

- (UIView *)panel {
    if (!_panel) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 300, 40)];
        view.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
        
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(0, 0, 50, 40);
        
        [view addSubview:selectButton];
        
        _panel = view;
    }
    
    return _panel;
}

#pragma mark - Actions

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    if (self.currentMode == WDKViewExplorerModeSelect && recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint tapPointInView = [recognizer locationInView:self];
        CGPoint tapPointInWindow = [self convertPoint:tapPointInView toView:nil];
        
        [self updateOutlineViewsForSelectionPoint:tapPointInWindow];
    }
}


#pragma mark - Private Methods

- (void)updateOutlineViewsForSelectionPoint:(CGPoint)selectionPoint {
    [self removeAllOutlinesViews];
    
    self.viewContainsTapPoint = [self viewsContainsPoint:selectionPoint skipHiddenViews:NO];
    
    NSArray *visibleViewsContainsTapPoint = [self viewsContainsPoint:selectionPoint skipHiddenViews:YES];
    NSMutableDictionary *outlineViewsM = [NSMutableDictionary dictionary];
    for (UIView *view in visibleViewsContainsTapPoint) {
        UIView *outlineView = [self outlineViewForView:view];
        [self addSubview:outlineView];
        NSValue *key = [NSValue valueWithNonretainedObject:view];
        outlineViewsM[key] = outlineView;
    }
    self.outlineViewsForVisibleViews = outlineViewsM;
    
    self.selectedView = [self viewSelectedWithSelectionPoint:selectionPoint];
}

- (UIView *)viewSelectedWithSelectionPoint:(CGPoint)tapPointInWindow {
    // default to key window if none of the windows want the touch
    UIWindow *windowForSelection = [UIApplication sharedApplication].keyWindow;
    for (UIWindow *window in [[self.class allWindows] reverseObjectEnumerator]) {
        // ignore this view's window
        if (window != self.window) {
            if ([window hitTest:tapPointInWindow withEvent:nil]) {
                windowForSelection = window;
                break;
            }
        }
    }
    
    // select frontest view (the last view) which contains the tap point
    return [[self recursiveSubviewsContainsPoint:tapPointInWindow inView:windowForSelection skipHiddenViews:YES] lastObject];
}

- (UIView *)outlineViewForView:(UIView *)view {
    CGRect outlineFrame = [self frameInLocalCoordinatesForView:view];
    UIView *outlineView = [[UIView alloc] initWithFrame:outlineFrame];
    outlineView.backgroundColor = [UIColor clearColor];
    outlineView.layer.borderWidth = 1.0;
    outlineView.layer.borderColor = [self.class consistentRandomColorForObject:view].CGColor;
    return outlineView;
}

- (CGRect)frameInLocalCoordinatesForView:(UIView *)view {
    // First convert to window coordinates since the view may be in a different window than our view.
    CGRect frameInWindow = [view convertRect:view.bounds toView:nil];
    // Then convert from the window to our view's coordinate space.
    return [self convertRect:frameInWindow fromView:nil];
}

- (void)removeAllOutlinesViews {
    for (id key in self.outlineViewsForVisibleViews) {
        UIView *outlineView = self.outlineViewsForVisibleViews[key];
        [outlineView removeFromSuperview];
    }
    self.outlineViewsForVisibleViews = nil;
}

- (NSArray *)viewsContainsPoint:(CGPoint)tapPointInWindow skipHiddenViews:(BOOL)skipHidden {
    NSMutableArray *views = [NSMutableArray array];
    for (UIWindow *window in [self.class allWindows]) {
        // exclude this view's window
        if (window != self.window && [window pointInside:tapPointInWindow withEvent:nil]) {
            [views addObject:window];
            [views addObjectsFromArray:[self recursiveSubviewsContainsPoint:tapPointInWindow inView:window skipHiddenViews:skipHidden]];
        }
    }
    return views;
}

- (NSArray *)recursiveSubviewsContainsPoint:(CGPoint)pointInView inView:(UIView *)view skipHiddenViews:(BOOL)skipHidden {
    NSMutableArray *subviewsAtPoint = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        BOOL isHidden = subview.hidden || subview.alpha < 0.01;
        if (skipHidden && isHidden) {
            continue;
        }
        
        BOOL subviewContainsPoint = CGRectContainsPoint(subview.frame, pointInView);
        if (subviewContainsPoint) {
            [subviewsAtPoint addObject:subview];
        }
        
        // Note: 1. if it contains point, so look up its subviews;
        //       2. if it contains point, but maybe its subviews contains the point which is different from "hitTest", still need to look up its subviews
        if (subviewsAtPoint || !subview.clipsToBounds) {
            CGPoint pointInSubview = [view convertPoint:pointInView toView:subview];
            [subviewsAtPoint addObjectsFromArray:[self recursiveSubviewsContainsPoint:pointInSubview inView:subview skipHiddenViews:skipHidden]];
        }
    }
    if (view.subviews.count == 0 && [view isKindOfClass:NSClassFromString(@"_UIRemoteKeyboardPlaceholderView")]) {
        if ([view respondsToSelector:NSSelectorFromString(@"placeheldView")]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
            UIView *subview = [view performSelector:NSSelectorFromString(@"placeheldView")];
#pragma GCC diagnostic pop
            BOOL isHidden = subview.hidden || subview.alpha < 0.01;
            if (!(skipHidden && isHidden)) {
                BOOL subviewContainsPoint = CGRectContainsPoint(subview.frame, pointInView);
                if (subviewContainsPoint) {
                    [subviewsAtPoint addObject:subview];
                }
                
                // Note: 1. if it contains point, so look up its subviews;
                //       2. if it contains point, but maybe its subviews contains the point which is different from "hitTest", still need to look up its subviews
                if (subviewsAtPoint || !subview.clipsToBounds) {
                    CGPoint pointInSubview = [view convertPoint:pointInView toView:subview];
                    [subviewsAtPoint addObjectsFromArray:[self recursiveSubviewsContainsPoint:pointInSubview inView:subview skipHiddenViews:skipHidden]];
                }
            }
        }
    }
    return subviewsAtPoint;
}

#pragma mark - Setters

- (void)setSelectedView:(UIView *)selectedView {
    if (![_selectedView isEqual:selectedView]) {
        /*
         if (![selfContainsTapPoint containsObject:_selectedView]) {
         [self stopObservingView:_selectedView];
         }
         */
        
        _selectedView = selectedView;
        
        /*
         [self beginObservingView:selectedView];
         */
        
        if (selectedView) {
            if (!self.selectedViewOverlay) {
                self.selectedViewOverlay = [[UIView alloc] init];
                [self addSubview:self.selectedViewOverlay];
                self.selectedViewOverlay.layer.borderWidth = 1.0;
            }
            UIColor *outlineColor = [self.class consistentRandomColorForObject:selectedView];
            self.selectedViewOverlay.backgroundColor = [outlineColor colorWithAlphaComponent:0.2];
            self.selectedViewOverlay.layer.borderColor = [outlineColor CGColor];
            self.selectedViewOverlay.frame = [self convertRect:selectedView.bounds fromView:selectedView];
            
            // Make sure the selected overlay is in front of all the other subviews except the toolbar, which should always stay on top.
            [self bringSubviewToFront:self.selectedViewOverlay];
        }
        else {
            [self.selectedViewOverlay removeFromSuperview];
            self.selectedViewOverlay = nil;
        }    }
}

#pragma mark - NSNotification

- (void)handleWDKInterfaceEventNotification:(NSNotification *)notification {
    UIEvent *event = notification.object;
    UITouch *touch = [[event allTouches] anyObject];
    UIWindow *window = touch.window;
    if (window != WDKViewExplorerWindow.currentViewExplorerWindow && touch.phase == UITouchPhaseEnded) {
        CGPoint tapPointInView = [touch locationInView:touch.view];
        CGPoint tapPointInWindow = [self convertPoint:tapPointInView toView:nil];
        
        [self updateOutlineViewsForSelectionPoint:tapPointInWindow];
    }
}

#pragma mark - Utility Methods

+ (NSArray *)allWindows {
    BOOL includeInternalWindows = YES;
    BOOL onlyVisibleWindows = NO;
    
    NSArray *allWindowsComponents = @[@"al", @"lWindo", @"wsIncl", @"udingInt", @"ernalWin", @"dows:o", @"nlyVisi", @"bleWin", @"dows:"];
    SEL allWindowsSelector = NSSelectorFromString([allWindowsComponents componentsJoinedByString:@""]);
    
    NSMethodSignature *methodSignature = [[UIWindow class] methodSignatureForSelector:allWindowsSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    invocation.target = [UIWindow class];
    invocation.selector = allWindowsSelector;
    [invocation setArgument:&includeInternalWindows atIndex:2];
    [invocation setArgument:&onlyVisibleWindows atIndex:3];
    [invocation invoke];
    
    __unsafe_unretained NSArray *windows = nil;
    [invocation getReturnValue:&windows];
    return windows;
}

+ (UIColor *)consistentRandomColorForObject:(id)object {
    CGFloat hue = (((NSUInteger)object >> 4) % 256) / 255.0;
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

@end
