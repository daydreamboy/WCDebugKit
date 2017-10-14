//
//  WCViewController.m
//  WCDebugKit
//
//  Created by wesley chen on 10/04/2017.
//  Copyright (c) 2017 wesley chen. All rights reserved.
//

#import "ViewController.h"

#import "WCDebugKit.h"
#import "SubMenuViewController.h"

@interface ViewController ()
@property (nonatomic, assign) BOOL toggleEnabled;
@property (nonatomic, strong) UIButton *buttonShowDebugPanel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self test_install_debugPanel_on_multiple_views];
    [self test_showDebugPanel];
    //[self test_enableStatusBarEntry_disable_status_bar_entry];
}

#pragma mark - Test Methods

#pragma mark > Test APIs

- (void)test_install_debugPanel_on_multiple_views {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.center = CGPointMake(self.view.center.x, 200);
    view.backgroundColor = [UIColor orangeColor];
    view.layer.borderWidth = 2.0f;
    view.layer.borderColor = [UIColor greenColor].CGColor;
    [WDKDebugPanel installDebugPanelWithView:view];
    [self.view addSubview:view];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view2.center = CGPointMake(self.view.center.x, 400);
    view2.backgroundColor = [UIColor greenColor];
    [WDKDebugPanel installDebugPanelWithView:view2];
    [self.view addSubview:view2];
}

- (void)test_install_more_times_on_same_view {
    [WDKDebugPanel installDebugPanelWithView:self.view];
    [WDKDebugPanel installDebugPanelWithView:self.view];
}

- (void)test_showDebugPanel {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    _buttonShowDebugPanel = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonShowDebugPanel setTitle:@"显示DebugPanel" forState:UIControlStateNormal];
    [_buttonShowDebugPanel sizeToFit];
    _buttonShowDebugPanel.center = CGPointMake(screenSize.width / 2.0, 100);
    [_buttonShowDebugPanel addTarget:self action:@selector(buttonShowDebugPanelClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_buttonShowDebugPanel];
}

- (void)test_enableStatusBarEntry_disable_status_bar_entry {
#if DEBUG
    [WDKDebugPanel enableStatusBarEntry:NO];
#endif
}

#pragma mark - Actions

- (void)buttonShowDebugPanelClicked:(id)sender {
    [WDKDebugPanel showDebugPanel];
}

#pragma mark - WDKDebugPanelDataSource

#if DEBUG
- (WDKDebugGroup *)wdk_debugGroup {
    return [self test_WDKDebugGroup];
}
#endif

#pragma mark > Test Models

- (void)test_action_copy {
#if DEBUG
    WDKDebugAction *action1 = [WDKDebugAction actionWithName:@"Bundle ID" actionBlock:^{
        NSLog(@"Bundle ID executed");
    }];
    WDKDebugAction *actionCopy = [action1 copy];
    NSLog(@"%@", action1);
    NSLog(@"%@", actionCopy);
    [actionCopy doAction];
#endif
}

- (void)test_group_copy {
#if DEBUG
    WDKDebugAction *action1 = [WDKDebugAction actionWithName:@"Bundle ID" actionBlock:^{
        NSLog(@"Bundle ID executed");
    }];
    
    WDKDebugGroup *group1 = [WDKDebugGroup groupWithName:@"App Basic Information" actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[
                 action1
                 ];
    }];
    
    WDKDebugGroup *groupCopy = [group1 copy];
    NSLog(@"%@", group1);
    NSLog(@"%@", groupCopy);
    
    WDKDebugAction *actionCopy = groupCopy.actions[0];
    NSLog(@"%@", action1);
    NSLog(@"%@", actionCopy);
    
    [actionCopy doAction];
#endif
}

#if DEBUG
- (WDKDebugAction *)test_default_action {
    WDKDebugAction *action = [WDKDebugAction actionWithName:@"Not Dismiss DebugPanel (DefaultAction)" actionBlock:^{
        NSLog(@"Not Dismiss DebugPanel executed");
    }];
    action.shouldDismissPanel = NO;
    
    return action;
}

- (WDKSubMenuAction *)test_submenu_action {
    
    __weak typeof(self) weak_self = self;
    WDKDebugGroup *secondary_group = [WDKDebugGroup groupWithName:@"Test Cases" actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[
                 [WDKDebugAction actionWithName:@"Dismiss DebugPanel (DefaultAction)" actionBlock:^{
                     NSLog(@"Dismiss DebugPanel executed");
                 }],
                 [WDKToggleAction actionWithName:@"Test a toggle (ToggleAction)" enabled:self.toggleEnabled toggleBlock:^(BOOL enabled) {
                     NSLog(@"Test a toggle: %@", enabled ? @"YES" : @"NO");
                     weak_self.toggleEnabled = enabled;
                 }],
                 [WDKCustomPanelAction actionWithName:@"Enter custom UI (CustomPanelAction)" customPanelBlock:^(UIViewController *panelViewController) {
                     SubMenuViewController *vc = [SubMenuViewController new];
                     [panelViewController.navigationController pushViewController:vc animated:YES];
                 }],
                 ];
    }];
    
    WDKSubMenuAction *subMenuAction = [WDKSubMenuAction actionWithName:@"Secondary panel (SubMenuAction)" subMenuBlock:^NSArray<WDKDebugGroup *> *{
        return @[
                 secondary_group
                 ];
    }];
    return subMenuAction;
}

- (WDKEnumAction *)test_enum_action {
    NSArray *enumValues = @[@"High", @"Medium", @"Low"];
    WDKEnumAction *enumAction = [WDKEnumAction actionWithName:@"Multiple choice (EnumAction)" enums:enumValues index:1 enumBlock:^(NSUInteger selectedIndex) {
        NSLog(@"Multiple choice executed: %lu", (unsigned long)selectedIndex);
    }];
    enumAction.prompt = @"Log Level";
    
    return enumAction;
}

- (WDKDebugGroup *)test_WDKDebugGroup {
    __weak typeof(self) weak_self = self;
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:@"Test Cases" actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[
                 [WDKDebugAction actionWithName:@"Dismiss DebugPanel (DefaultAction)" actionBlock:^{
                     NSLog(@"Dismiss DebugPanel executed");
                 }],
                 [self test_default_action],
                 [WDKToggleAction actionWithName:@"Test a toggle (ToggleAction)" enabled:self.toggleEnabled toggleBlock:^(BOOL enabled) {
                     NSLog(@"Test a toggle: %@", enabled ? @"YES" : @"NO");
                     weak_self.toggleEnabled = enabled;
                 }],
                 [WDKCustomPanelAction actionWithName:@"Enter Custom UI (CustomPanelAction)" customPanelBlock:^(UIViewController *panelViewController) {
                     SubMenuViewController *vc = [SubMenuViewController new];
                     [panelViewController.navigationController pushViewController:vc animated:YES];
                 }],
                 [self test_submenu_action],
                 [self test_enum_action],
                 ];
    }];
    
    return group;
}
#endif

@end
