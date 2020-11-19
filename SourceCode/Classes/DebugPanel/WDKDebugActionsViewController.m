//
//  WDKDebugActionsViewController.m
//  Pods
//
//  Created by wesley chen on 16/10/17.
//
//

#import "WDKDebugActionsViewController.h"

#import <objc/runtime.h>

#import "WDKDebugPanel.h"
#import "WDKDebugPanel_Internal.h"
#import "WDKDebugAction.h"
#import "WDKDebugAction_Internal.h"
#import "WDKDebugGroup.h"
#import "WDKDebugGroup_Internal.h"
#import "WDKToggleAction.h"
#import "WDKSubMenuAction.h"
#import "WDKCustomPanelAction.h"
#import "WDKEnumAction.h"
#import "WDKDebugPanelGerenalViewController.h"
#import "WDKNavBackButtonItem.h"
#import "WDKDebugPanelCellItem.h"
#import "WDKDebugPanelCell.h"
#import "WDKExpandableHeaderView.h"

#define STATUS_BAR_H            (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))
#define NAV_BAR_H               (CGRectGetHeight(self.navigationController.navigationBar.frame))
#define SCREEN_WIDTH            ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT           ([[UIScreen mainScreen] bounds].size.height)
#define SECTION_HEADER_H        28.0f

static NSString *WDK_sIdentifierForDefaultAction  = @"WDK_sIdentifierForDefaultAction";
static NSString *WDK_sIdentifierForToggleAction   = @"WDK_sIdentifierForToggleAction";
static NSString *WDK_sIdentifierForSubMenuAction  = @"WDK_sIdentifierForSubMenuAction";
static NSString *WDK_sIdentifierForCustomPanelAction = @"WDK_sIdentifierForCustomPanelAction";
static NSString *WDK_sIdentifierForEnumAction = @"WDK_sIdentifierForEnumAction";


@interface UIAlertView (WDKDebugActionsViewController)
@property (nonatomic, strong) id odt_userInfo;
@end

@implementation UIAlertView (WDKDebugActionsViewController)

static const char * const WDK_UserInfoObjectTag = "UserInfoObjectTag";

@dynamic odt_userInfo;

- (void)setOdt_userInfo:(id)userInfo {
    objc_setAssociatedObject(self, WDK_UserInfoObjectTag, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)odt_userInfo {
    return objc_getAssociatedObject(self, WDK_UserInfoObjectTag);
}

@end


@interface WDKDebugActionsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate, WDKExpandableHeaderViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *headerInTableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, assign) BOOL originalNavBarHidden;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray<WDKDebugGroup*> *actionGroupsFiltered;

@end

@implementation WDKDebugActionsViewController

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"dealloc: %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
    /*
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
     */
    
    self.originalNavBarHidden = self.navigationController.navigationBarHidden;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setup {
    if (!self.isSubMenu) {
        self.title = NSLocalizedString(@"调试面板", nil);
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissItemClicked:)];
        self.navigationItem.rightBarButtonItem = dismissItem;
        
        UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithTitle:@"⚙" style:UIBarButtonItemStylePlain target:self action:@selector(settingsItemClicked:)];
        self.navigationItem.leftBarButtonItem = settingsItem;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
}

#pragma mark - Getter

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, STATUS_BAR_H + NAV_BAR_H, SCREEN_WIDTH, 44)];
        searchBar.delegate = self;
        searchBar.returnKeyType = UIReturnKeyDone;
        
        _searchBar = searchBar;
    }
    
    return _searchBar;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetHeight(self.searchBar.frame) - NAV_BAR_H - STATUS_BAR_H) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.expandableHeaderView_delegate = self;
        
        _tableView = tableView;
    }
    
    return _tableView;
}

- (void)setActionGroups:(NSArray<WDKDebugGroup *> *)actionGroups {
    _actionGroups = actionGroups;
    _actionGroupsFiltered = [actionGroups copy];
}

- (void)configureRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    if (self.flagPresentByInternal) {
        [self reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.flagPresentByInternal = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = self.originalNavBarHidden;
}

#pragma mark - Actions

- (void)dismissItemClicked:(id)sender {
    [self searchBarCancelButtonClicked:self.searchBar];
    
    if ([WDKDebugPanel sharedPanel].exitBlock) {
        [WDKDebugPanel sharedPanel].exitBlock(self);
    }
    else {
        [[WDKDebugPanel sharedPanel] dismissDebugPanel];
    }
}

- (void)settingsItemClicked:(id)sender {
    WDKDebugPanelGerenalViewController *viewController = [WDKDebugPanelGerenalViewController new];
    viewController.listData = [self createListDataForSettings];
    viewController.blockForViewDidLoad = ^ (WDKDebugPanelGerenalViewController *weakViewController) {
        weakViewController.title = NSLocalizedString(@"设置", nil);
        
        WDKNavBackButtonItem *backItem = [[WDKNavBackButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(backItemClicked:)];
        weakViewController.navigationItem.leftBarButtonItems = @[[WDKNavBackButtonItem navBackButtonLeadingSpaceItem], backItem];
    };
    
    // @sa http://stackoverflow.com/questions/18982724/flip-transition-uinavigationcontroller-push
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.navigationController pushViewController:viewController animated:NO];
                    }
                    completion:nil];
}

- (void)backItemClicked:(id)sender {
    
    // @sa http://stackoverflow.com/questions/18982724/flip-transition-uinavigationcontroller-push
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.navigationController popToRootViewControllerAnimated:NO];
                    }
                    completion:nil];
}

#pragma mark

- (void)cancelSearch {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
}

#pragma mark - Settings

- (NSMutableArray<NSMutableArray<WDKDebugPanelCellItem*> *> *)createListDataForSettings {
    WDKDebugPanelCellItem *item1 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeSwitch];
    item1.title = @"远程加载external tools";
    item1.toggleOn = NO;
    item1.toggleAction = ^(WDKDebugPanelCell *cell, BOOL toggleOn) {
        // after togging
        if (toggleOn) {
            [cell startLoading];
            
            [self requestExternalToolsPlistWithCompletion:^(BOOL success) {
                if (success) {
                   [cell stopLoading];
                }
                else {
                   [cell setToggleOn:NO];
                }
            }];
        }
    };
    
    WDKDebugPanelCellItem *item2 = [WDKDebugPanelCellItem itemWithType:WDKDebugPanelCellTypeDefault];
    item2.title = @"Test Cases";
    item2.accessoryType = WDKDebugPanelCellAccessoryTypeDisclosureIndicator;
    item2.selectAction = ^(UIViewController *viewController) {
        WDKDebugActionsViewController *vc = [WDKDebugActionsViewController new];
        vc.title = @"Actions Demo";
        vc.isSubMenu = YES;
        vc.actionGroups = @[ [self test_WDKDebugGroup] ];
        [self.navigationController pushViewController:vc animated:YES];
    };

    return [@[
             [@[item1] mutableCopy],
             [@[item2] mutableCopy]
             ] mutableCopy];
}

- (void)requestExternalToolsPlistWithCompletion:(void (^)(BOOL success))completion {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/wesley chen/NetFiles/master/external_tools.plist"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10;
    
    NSLog(@"will get plist");
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data && !error) {
            NSArray *array = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:nil];
            
            NSLog(@"array: %@", array);
            [[WDKDebugPanel sharedPanel] loadExternalToolsFromArray:array];
            
            WDKDebugActionsViewController *vc = [[[WDKDebugPanel sharedPanel].navController viewControllers] firstObject];
            vc.actionGroups = [WDKDebugPanel sharedPanel].actionGroupsM;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [vc reloadData];
                
                if (completion) {
                    completion(YES);
                }
            });
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *msg = [NSString stringWithFormat:@"code: %ld, %@", (long)error.code, error.localizedDescription];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"获取配置文件出错", nil) message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"好的", nil) otherButtonTitles:nil];
                [alert show];
                
                if (completion) {
                    completion(NO);
                }
            });
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    [dataTask resume];
}

#pragma mark - Public Methods

- (void)reloadData {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - WDKExpandableHeaderViewDelegate

- (NSInteger)WDKExpandableHeaderView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WDKDebugGroup *group = self.actionGroupsFiltered[section];
    return [group.actions count];
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.actionGroupsFiltered count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WDKDebugGroup *group = self.actionGroupsFiltered[section];
    
    WDKExpandableHeaderView *headerView = [self.tableView expandableHeaderViewAtSectionIndex:section];
    return headerView.closed ? 0 : [group.actions count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WDKDebugGroup *group = self.actionGroupsFiltered[section];
    
    WDKExpandableHeaderView *headerView = [self.tableView expandableHeaderViewAtSectionIndex:section];
    if (!headerView) {
        headerView = [[WDKExpandableHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SECTION_HEADER_H)];
        headerView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.0f];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 15, SECTION_HEADER_H)];
        label.backgroundColor = [UIColor clearColor];
        label.text = group.name;
        label.font = [UIFont boldSystemFontOfSize:17.0f];
        label.textColor = group.nameColor ? group.nameColor : [UIColor colorWithRed:0.137f green:0.137f blue:0.137f alpha:1.0f];
        
        [headerView addSubview:label];
        
        [self.tableView recordExpandableHeaderView:headerView atSectionIndex:section];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEADER_H;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    WDKDebugGroup *group = self.actionGroupsFiltered[indexPath.section];
    WDKDebugAction *action = group.actions[indexPath.row];
    
    NSString *cellIdentifier = [self reuseIdentifierForAction:action];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:[self cellStyleForAction:action] reuseIdentifier:cellIdentifier];
    }

    [self configureCell:cell forAction:action];

    return cell;
}

#pragma mark - Configuration Methods

- (void)configureCell:(UITableViewCell *)cell forAction:(WDKDebugAction *)action {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:action.name];
    if (action.titleFont) {
        [attrString addAttribute:NSFontAttributeName value:action.titleFont range:NSMakeRange(0, attrString.length)];
    }
    
    if (self.searchBar.text.length) {
        NSRange range = [action.name rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
        [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:range];
    }
    
    if ([action isKindOfClass:[WDKToggleAction class]]) {
        WDKToggleAction *toggle = (WDKToggleAction *)action;
        
        cell.textLabel.attributedText = attrString;
        cell.detailTextLabel.text = toggle.enabled ? @"On" : @"Off";
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        cell.detailTextLabel.textColor = toggle.enabled ? [UIColor orangeColor] : [UIColor darkGrayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([action isKindOfClass:[WDKEnumAction class]]) {
        WDKEnumAction *enumAction = (WDKEnumAction *)action;
        
        cell.textLabel.attributedText = attrString;
        id enumValue = @"";
        if (enumAction.index >= 0 && enumAction.index < [enumAction.enums count]) {
            enumValue = enumAction.enums[enumAction.index];
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", enumValue];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        cell.detailTextLabel.textColor = [UIColor blueColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([action isKindOfClass:[WDKSubMenuAction class]] || [action isKindOfClass:[WDKCustomPanelAction class]]) {
        cell.textLabel.attributedText = attrString;
        cell.detailTextLabel.text = action.desc;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.textLabel.attributedText = attrString;
        // @see https://stackoverflow.com/a/905565
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.text = action.desc;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (NSString *)reuseIdentifierForAction:(WDKDebugAction *)action {
    if ([action isKindOfClass:[WDKToggleAction class]]) {
        return WDK_sIdentifierForToggleAction;
    }
    else if ([action isKindOfClass:[WDKSubMenuAction class]]) {
        return WDK_sIdentifierForSubMenuAction;
    }
    else if ([action isKindOfClass:[WDKCustomPanelAction class]]) {
        return WDK_sIdentifierForCustomPanelAction;
    }
    else if ([action isKindOfClass:[WDKEnumAction class]]) {
        return WDK_sIdentifierForEnumAction;
    }
    else {
        return WDK_sIdentifierForDefaultAction;
    }
}

- (UITableViewCellStyle)cellStyleForAction:(WDKDebugAction *)action {
    if ([action isKindOfClass:[WDKToggleAction class]]) {
        return UITableViewCellStyleValue1;
    }
    else if ([action isKindOfClass:[WDKSubMenuAction class]]) {
        return UITableViewCellStyleSubtitle;
    }
    else if ([action isKindOfClass:[WDKCustomPanelAction class]]) {
        return UITableViewCellStyleSubtitle;
    }
    else if ([action isKindOfClass:[WDKEnumAction class]]) {
        return UITableViewCellStyleValue1;
    }
    else {
        return UITableViewCellStyleSubtitle;
    }
}

- (BOOL)isDefaultAction:(WDKDebugAction *)action {
    if ([action isKindOfClass:[WDKCustomPanelAction class]]
        || [action isKindOfClass:[WDKEnumAction class]]
        || [action isKindOfClass:[WDKToggleAction class]]
        || [action isKindOfClass:[WDKSubMenuAction class]]) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section < self.actionGroupsFiltered.count) {
        WDKDebugGroup *group = self.actionGroupsFiltered[indexPath.section];
        
        if (indexPath.row < group.actions.count) {
            WDKDebugAction *action = group.actions[indexPath.row];
            
            if ([self isDefaultAction:action]) {
                if (action.shouldDismissPanel) {
                    [self cancelSearch];
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [action doAction];
                        [WDKDebugPanel cleanup];
                    }];
                }
                else {
                    [action doAction];
                }
            }
            else {
                if ([action isKindOfClass:[WDKEnumAction class]]) {
                    
                    WDKEnumAction *enumAction = (WDKEnumAction *)action;
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:enumAction.title message:enumAction.prompt delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    alert.odt_userInfo = enumAction;
                    
                    for (id enumValue in enumAction.enums) {
                        [alert addButtonWithTitle:[NSString stringWithFormat:@"%@", enumValue]];
                    }
                    
                    [alert show];
                    
                }
                else if ([action isKindOfClass:[WDKToggleAction class]]) {
                    [action doAction];
                    [self reloadData];
                }
                else {
                    [action doAction];
                }
            }
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cancelSearch];
    
    self.actionGroupsFiltered = self.actionGroups;
    [self reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length) {
        NSMutableArray *groupArray = [NSMutableArray array];
        for (WDKDebugGroup *group in self.actionGroups) {

            NSMutableArray *actionArray = [NSMutableArray array];
            
            for (WDKDebugAction *action in group.actions) {
                if ([action.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [actionArray addObject:action];
                }
            }
            
            if (actionArray.count) {
                WDKDebugGroup *groupCopy = [WDKDebugGroup groupWithName:group.name actions:actionArray];
                [groupArray addObject:groupCopy];
            }
        }
        
        self.actionGroupsFiltered = groupArray;
    }
    else {
        self.actionGroupsFiltered = self.actionGroups;
    }
    
    [self reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex: %ld", (long)buttonIndex);
    WDKEnumAction *enumAction = (WDKEnumAction *)alertView.odt_userInfo;
    if (buttonIndex >= 1 && buttonIndex <= [enumAction.enums count]) {
        enumAction.index = buttonIndex - 1;
        [enumAction doAction];
        [self reloadData];
    }
}

#pragma mark - NSNotification

- (void)handleKeyboardWillShowNotification:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    }
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

#pragma mark - Test Case

static BOOL TestCase_sToggleEnabled1 = NO;
static BOOL TestCase_sToggleEnabled2 = NO;

- (WDKDebugGroup *)test_WDKDebugGroup {
    WDKDebugGroup *group = [WDKDebugGroup groupWithName:@"Test Cases" actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[
                 [WDKDebugAction actionWithName:@"Dismiss DebugPanel (DefaultAction)" actionBlock:^{
                     NSLog(@"Dismiss DebugPanel executed");
                 }],
                 [self test_default_action],
                 [WDKToggleAction actionWithName:@"Test a toggle (ToggleAction)" enabled:TestCase_sToggleEnabled1 toggleBlock:^(BOOL enabled) {
                     NSLog(@"Test a toggle: %@", enabled ? @"YES" : @"NO");
                     TestCase_sToggleEnabled1 = enabled;
                 }],
                 [WDKCustomPanelAction actionWithName:@"Enter Custom UI (CustomPanelAction)" customPanelBlock:^(UIViewController *panelViewController) {
                     UIViewController *vc = [UIViewController new];
                     vc.view.backgroundColor = [UIColor greenColor];
                     [panelViewController.navigationController pushViewController:vc animated:YES];
                 }],
                 [self test_submenu_action],
                 [self test_enum_action],
                 ];
    }];
    
    return group;
}

- (WDKDebugAction *)test_default_action {
    WDKDebugAction *action = [WDKDebugAction actionWithName:@"Not Dismiss DebugPanel (DefaultAction)" actionBlock:^{
        NSLog(@"Not Dismiss DebugPanel executed");
    }];
    action.shouldDismissPanel = NO;
    
    return action;
}

- (WDKSubMenuAction *)test_submenu_action {
    WDKDebugGroup *secondary_group = [WDKDebugGroup groupWithName:@"Test Cases" actionsBlock:^NSArray<WDKDebugAction *> *{
        return @[
                 [WDKDebugAction actionWithName:@"Dismiss DebugPanel (DefaultAction)" actionBlock:^{
                     NSLog(@"Dismiss DebugPanel executed");
                 }],
                 [WDKToggleAction actionWithName:@"Test a toggle (ToggleAction)" enabled:TestCase_sToggleEnabled2 toggleBlock:^(BOOL enabled) {
                     NSLog(@"Test a toggle: %@", enabled ? @"YES" : @"NO");
                     TestCase_sToggleEnabled2 = enabled;
                 }],
                 [WDKCustomPanelAction actionWithName:@"Enter custom UI (CustomPanelAction)" customPanelBlock:^(UIViewController *panelViewController) {
                     UIViewController *vc = [UIViewController new];
                     vc.view.backgroundColor = [UIColor greenColor];
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
    WDKEnumAction *enumAction = [WDKEnumAction actionWithName:@"Multiple choice (EnumAction)" title:@"Log Level" subtitle:nil enums:enumValues index:1 enumBlock:^(NSUInteger selectedIndex) {
        NSLog(@"Multiple choice executed: %lu", (unsigned long)selectedIndex);
    }];
    
    return enumAction;
}

@end
