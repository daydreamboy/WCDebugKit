//
//  WDKDebugPanelGerenalViewController.m
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import "WDKDebugPanelGerenalViewController.h"

#import "WDKDebugPanelCell.h"
#import "WDKDebugPanelCellItem.h"
#import "WDKDebugPanelSectionItem.h"

@interface WDKDebugPanelGerenalViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation WDKDebugPanelGerenalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.blockForViewDidLoad) {
        __weak typeof(self) weak_self = self;
        self.blockForViewDidLoad(weak_self);
    }
    
    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.blockForViewWillAppear) {
        __weak typeof(self) weak_self = self;
        self.blockForViewWillAppear(weak_self);
    }
    
    [self.tableView reloadData];
}

- (void)dealloc {
    NSLog(@"dealloc: %@", self);
}

#pragma mark - Public Methods

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height) style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.alwaysBounceVertical = NO;
        
        _tableView = tableView;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.listData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.listData[section];
    
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    WDKDebugPanelCellItem *item = [self.listData[indexPath.section] objectAtIndex:indexPath.row];
    
    WDKDebugPanelCell *cell = [WDKDebugPanelCell dequeueReusableCellWithTableView:tableView type:item.cellType];
    if (!cell) {
        cell = [[WDKDebugPanelCell alloc] initWithType:item.cellType];
    }
    
    [cell configureCellWithItem:item];
    
    return cell;
}

#define FOOTER_HEIGHT 20.0f

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    WDKDebugPanelSectionItem *sectionItem = self.listSection[section];
    
    return sectionItem.sectionHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    
    WDKDebugPanelSectionItem *sectionItem = self.listSection[section];
    
    if (sectionItem.sectionHeaderView) {
        headerView = sectionItem.sectionHeaderView(section);
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    WDKDebugPanelSectionItem *sectionItem = self.listSection[section];
    
    return sectionItem.sectionFooterViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
    
    WDKDebugPanelSectionItem *sectionItem = self.listSection[section];
    
    if (sectionItem.sectionFooterView) {
        footerView = sectionItem.sectionFooterView(section);
    }
    
    return footerView;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    WDKDebugPanelCellItem *item = [self.listData[indexPath.section] objectAtIndex:indexPath.row];
    
    if (item.swipeable) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WDKDebugPanelCellItem *item = [self.listData[indexPath.section] objectAtIndex:indexPath.row];
    if (item.accessoryType == WDKDebugPanelCellAccessoryTypeDisclosureIndicator) {
        if (item.selectAction) {
            item.selectAction(self);
        }
    }
    else {
        if (item.alertMessage) {            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:item.title message:item.alertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"好的", nil) style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"删除", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        WDKDebugPanelCellItem *item = [self.listData[indexPath.section] objectAtIndex:indexPath.row];
        NSMutableArray *arrM = self.listData[indexPath.section];
        if ([arrM containsObject:item]) {
            if (item.deleteAction) {
                item.deleteAction();
            }
            
            [arrM removeObject:item];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    return @[rowAction];
}

#pragma mark > Context Menu

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    WDKDebugPanelCellItem *item = [self.listData[indexPath.section] objectAtIndex:indexPath.row];
    
    return item.alertMessage ? YES : NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        WDKDebugPanelCellItem *item = [self.listData[indexPath.section] objectAtIndex:indexPath.row];
        if (item.alertMessage) {
            [UIPasteboard generalPasteboard].string = item.alertMessage;
        }
    }
}

@end
