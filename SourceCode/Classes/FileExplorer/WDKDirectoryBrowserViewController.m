//
//  WDKDirectoryBrowserViewController.m
//  WDKFileExplorer
//
//  Created by wesley chen on 16/11/3.
//  Copyright © 2016年 wesley chen. All rights reserved.
//

#import "WDKDirectoryBrowserViewController.h"

#import <objc/runtime.h>

#import "WDKInteractiveLabel.h"
#import "WDKContextMenuCell.h"
#import "WDKTextEditViewController.h"
#import "WDKImageBrowserViewController.h"
#import "WDKPlistViewController.h"
#import "WDKFileTool.h"
#import "UIAlertController+FixAutoLayoutWarning.h"

#define WDK_FAVORITE_PATHS_PLIST_PATH    [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/WCDebugKit/favorite_paths.plist"]

#define STATUS_BAR_H            (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))
#define NAV_BAR_H               (CGRectGetHeight(self.navigationController.navigationBar.frame))

typedef NS_ENUM(NSUInteger, WDKPathType) {
    WDKPathTypeUnknown,  /**< the other paths */
    WDKPathTypeHome,     /**< the path has home folder */
    WDKPathTypeBundle,   /**< the path has bundle folder */
};

NSString *WDKPathTypeUnknownKey = @"unknown";
NSString *WDKPathTypeHomeKey = @"home";
NSString *WDKPathTypeBundleKey = @"bundle";

static NSString *NSStringFromWDKPathType(WDKPathType pathType)
{
    switch (pathType) {
        case WDKPathTypeUnknown:
        default:
            return WDKPathTypeUnknownKey;
        case WDKPathTypeHome:
            return WDKPathTypeHomeKey;
        case WDKPathTypeBundle:
            return WDKPathTypeBundleKey;
    }
}

@interface WDKPathItem ()
@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, copy) NSString *relativePath;
@property (nonatomic, assign) WDKPathType pathType;
@end

@implementation WDKPathItem
+ (instancetype)itemWithPath:(NSString *)path {
    WDKPathItem *item = [[WDKPathItem alloc] init];
    item.path = path;
    return item;
}

+ (instancetype)itemWithName:(NSString *)name path:(NSString *)path {
    WDKPathItem *item = [self itemWithPath:path];
    item.name = name;
    return item;
}
@end

typedef NS_ENUM(NSInteger, WDKActionSheetOperation) {
    WDKActionSheetOperationCancel = 0,
    WDKActionSheetOperationView = 1,
    WDKActionSheetOperationExport,
};

// File Attributes
static NSString *WDKFileAttributeFileSize = @"WDKFileAttributeFileSize";
static NSString *WDKFileAttributeIsDirectory = @"WDKFileAttributeIsDirectory";
static NSString *WDKFileAttributeNumberOfFilesInDirectory = @"WDKFileAttributeNumberOfFilesInDirectory";

#define WDK_SectionHeader_H 40.0f

@interface WDKDirectoryBrowserViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, WDKInteractiveLabelDelegate, WDKContextMenuCellDelegate>
@property (nonatomic, copy) NSString *pwdPath;  /**< current folder path */
@property (nonatomic, strong) NSArray *files;   /**< list name of files */
@property (nonatomic, strong) NSArray *filesFiltered; /**< list name of filtered files */
@property (nonatomic, strong) NSMutableDictionary *fileAttributes; /**< attributes of files */

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic, strong) WDKInteractiveLabel *labelTitle;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL isSearching; /**< YES, when searchBar has keyword */

@property (nonatomic, strong) NSMutableArray *imageFiles;

@end

@implementation WDKDirectoryBrowserViewController

+ (NSArray<WDKPathItem *> *)favoritePathItems {
    NSMutableArray<WDKPathItem *> *arrM = [NSMutableArray array];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:WDK_FAVORITE_PATHS_PLIST_PATH];
    
    if ([dict isKindOfClass:[NSDictionary class]]) {
        
        for (NSString *path in dict[WDKPathTypeHomeKey]) {
            
            WDKPathItem *item = [WDKPathItem itemWithPath:[NSHomeDirectory() stringByAppendingPathComponent:path]];
            item.pathType = WDKPathTypeHome;
            item.relativePath = path;
            
            [arrM addObject:item];
        }
        
        for (NSString *path in dict[WDKPathTypeBundleKey]) {
            WDKPathItem *item = [WDKPathItem itemWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:path]];
            item.pathType = WDKPathTypeBundle;
            item.relativePath = path;
            
            [arrM addObject:item];
        }
        
        for (NSString *path in dict[WDKPathTypeUnknownKey]) {
            WDKPathItem *item = [WDKPathItem itemWithPath:path];
            item.pathType = WDKPathTypeUnknown;
            item.relativePath = path;
            
            [arrM addObject:item];
        }
    }
    
    return arrM;
}

+ (void)deleteFavoritePathItemWithItem:(WDKPathItem *)item {
    WDKPathType pathType = item.pathType;
    
    NSMutableDictionary *plistDictM = [NSMutableDictionary dictionary];
    
    NSData *data = [NSData dataWithContentsOfFile:WDK_FAVORITE_PATHS_PLIST_PATH];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSMutableDictionary *dictM = (NSMutableDictionary *)[NSPropertyListSerialization
                                                         propertyListFromData:data
                                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                         format:0
                                                         errorDescription:nil];
#pragma GCC diagnostic pop
    
    [plistDictM addEntriesFromDictionary:dictM];
    
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:dictM[NSStringFromWDKPathType(pathType)]];
    
    NSString *pathToRemove = nil;
    for (NSString *path in arrM) {
        if ([path isEqualToString:item.relativePath]) {
            pathToRemove = path;
            break;
        }
    }
    
    if (pathToRemove) {
        [arrM removeObject:pathToRemove];
        plistDictM[NSStringFromWDKPathType(pathType)] = arrM;
        
        BOOL success = [plistDictM writeToFile:WDK_FAVORITE_PATHS_PLIST_PATH atomically:YES];
        if (!success) {
            NSLog(@"delete path failed");
        }
    }
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _pwdPath = path;
    }
    return self;
}

#pragma mark

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    self.labelTitle.text = self.pwdPath;
    [self.labelTitle sizeToFit];
    
    self.navigationItem.titleView = self.labelTitle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.pwdPath.length) {
        
        if (!self.isSearching) {
            NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.pwdPath error:nil];
            self.files = [fileNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            self.filesFiltered = [self.files copy];
            
            [self parseAttributesOfFiles];
        }
    }
    
    if (self.navigationController && self.isMovingToParentViewController) {
        // appear by pushing
        [self.tableView setContentOffset:CGPointMake(0, CGRectGetHeight(self.searchBar.frame)) animated:NO];
    }
    else {
        // appear by popping
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.imageFiles = [NSMutableArray array];
    
    for (NSString *file in self.filesFiltered) {
        if ([self fileIsPicture:[self pathForFile:file]]) {
            [self.imageFiles addObject:file];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Getters

- (WDKInteractiveLabel *)labelTitle {
    if (!_labelTitle) {
        WDKInteractiveLabel *label = [[WDKInteractiveLabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:15.0f];
        label.lineBreakMode = NSLineBreakByTruncatingHead;
        label.textColor = [UIColor blueColor];
        label.contextMenuItemTypes = @[ @(WDKContextMenuItemCopy), @(WDKContextMenuItemView)];
        label.contextMenuItemTitles = @[ NSLocalizedString(@"复制", nil), NSLocalizedString(@"查看", nil) ];
        label.delegate = self;
        label.showContextMenuAlwaysCenetered = YES;
        
        _labelTitle = label;
    }
    
    return _labelTitle;
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_H + NAV_BAR_H, screenSize.width, screenSize.height - STATUS_BAR_H - NAV_BAR_H) style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 44)];
        searchBar.delegate = self;
        searchBar.returnKeyType = UIReturnKeyDone;
        _searchBar = searchBar;
        
        tableView.tableHeaderView = searchBar;
        
        _tableView = tableView;
    }
    
    return _tableView;
}

#pragma mark

- (void)parseAttributesOfFiles {
    NSMutableArray *directories = [NSMutableArray array];
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    for (NSString *fileName in self.files) {
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        NSString *path = [self pathForFile:fileName];
        NSArray *subFileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        
        BOOL isDirectory = NO;
        unsigned long long fileSize = [self sizefFileAtPath:path isDirectory:&isDirectory];
        
        attributes[WDKFileAttributeIsDirectory] = @(isDirectory);
        if (!isDirectory) {
            // file
            attributes[WDKFileAttributeFileSize] = @(fileSize);
        }
        else {
            // directory
            attributes[WDKFileAttributeNumberOfFilesInDirectory] = @(subFileNames.count);
            [directories addObject:[fileName copy]];
        }
        
        if (attributes.count) {
            dictM[fileName] = attributes;
        }
    }
    
    self.fileAttributes = dictM;
    
    // calculate folder size
    if (directories.count) {
        __weak typeof(self) weak_self = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            for (NSString *fileName in directories) {
                if (weak_self == nil) {
                    // if the current view controller not exists, just abort loop
                    return;
                }
                
                NSString *path = [self pathForFile:fileName];
                NSError *error = nil;
                unsigned long long totalSize = [self sizeOfDirectoryAtPath:path error:&error];
                
                NSMutableDictionary *attributes = weak_self.fileAttributes[fileName];
                attributes[WDKFileAttributeFileSize] = (error == nil ? @(totalSize) : error);
                
                // once a folder size is calculated, refresh table view to be more real time
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong WDKDirectoryBrowserViewController *strong_self = weak_self;
                    [strong_self.tableView reloadData];
                });
            }
            
            // after all folders' size is calculated, refresh table view
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong WDKDirectoryBrowserViewController *strong_self = weak_self;
                [strong_self.tableView reloadData];
            });
        });
    }
}

#pragma mark - Utility

- (NSString *)pathForFile:(NSString *)file {
    return [self.pwdPath stringByAppendingPathComponent:file];
}

- (unsigned long long)sizefFileAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
    BOOL isDirectoryL = NO;
    BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectoryL];
    
    *isDirectory = isDirectoryL;
    if (isDirectoryL || !isExisted) {
        // If the path is a directory, or no file at the path exists
        return 0;
    }
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    return [attributes[NSFileSize] unsignedLongLongValue];
}

- (unsigned long long)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:error];
    if (*error) {
        NSLog(@"error: %@", *error);
    }
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

- (NSString *)prettySizeWithBytes:(unsigned long long)bytes {
    NSString *sizeString = [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile];
    return sizeString;
}

#pragma mark > Check Files

- (BOOL)fileIsDirectory:(NSString *)file {
    BOOL isDir = NO;
    NSString *path = [self pathForFile:file];
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    return isDir;
}

- (BOOL)fileIsPlist:(NSString *)file {
    return [[file.lowercaseString pathExtension] isEqualToString:@"plist"];
}

- (BOOL)fileIsJSON:(NSString *)file {
    return [[file.lowercaseString pathExtension] isEqualToString:@"json"];
}

- (BOOL)fileIsStrings:(NSString *)file {
    return [[file.lowercaseString pathExtension] isEqualToString:@"strings"];
}

- (BOOL)fileIsPicture:(NSString *)filePath {    
    NSArray<NSNumber *> *types = @[
        @(WCMIMETypeBmp),
        @(WCMIMETypeIco),
        @(WCMIMETypeJpg),
        @(WCMIMETypePng),
        @(WCMIMETypeWebp),
    ];
    
    return [WDKFileTool checkImageFileExistsAtPath:filePath imageTypes:types];
}

- (BOOL)fileIsMatching:(NSString *)file extensions:(NSArray *)extensions {
    __block BOOL matching = NO;
    [extensions enumerateObjectsUsingBlock:^(NSString *ext, NSUInteger idx, BOOL *stop) {
        if ([[file.lowercaseString pathExtension] isEqualToString:[ext lowercaseString]]) {
            matching = YES;
            *stop = YES;
        }
    }];
    
    return matching;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filesFiltered count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sCellIdentifier = @"Cell";
    
    WDKContextMenuCell *cell = (WDKContextMenuCell *)[tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (cell == nil) {
        cell = [[WDKContextMenuCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }
    
    NSString *file = [self.filesFiltered objectAtIndex:indexPath.row];
    NSString *path = [self pathForFile:file];
    
    NSDictionary *attributes = self.fileAttributes[file];
    BOOL isDir = [attributes[WDKFileAttributeIsDirectory] boolValue];
    
    cell.textLabel.text = file;
    cell.textLabel.textColor = isDir ? [UIColor blueColor] : [UIColor darkTextColor];
    
    NSString *sizeString = nil;
    if (attributes[WDKFileAttributeFileSize] == nil) {
        sizeString = NSLocalizedString(@"正在计算大小...", nil);
    }
    else {
        if ([attributes[WDKFileAttributeFileSize] isKindOfClass:[NSError class]]) {
            NSError *error = (NSError *)attributes[WDKFileAttributeFileSize];
            sizeString = error.localizedDescription;
        }
        else {
            sizeString = [self prettySizeWithBytes:[attributes[WDKFileAttributeFileSize] unsignedLongLongValue]];
        }
    }
    if (!isDir) {
        // file
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", sizeString];
    }
    else {
        // directory
        NSString *unit = [attributes[WDKFileAttributeNumberOfFilesInDirectory] isEqualToNumber:@(1)] ? @"file" : @"files";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", attributes[WDKFileAttributeNumberOfFilesInDirectory], unit, sizeString];
    }
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = isDir ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    if (isDir) {
        cell.contextMenuItemTypes = @[ @(WDKContextMenuItemFavorite), @(WDKContextMenuItemView), @(WDKContextMenuItemCopy), @(WDKContextMenuItemDeletion) ];
        cell.contextMenuItemTitles = @[ NSLocalizedString(@"收藏", nil), NSLocalizedString(@"查看", nil), NSLocalizedString(@"复制路径", nil), NSLocalizedString(@"删除", nil) ];
    }
    else {
        cell.contextMenuItemTypes = @[ @(WDKContextMenuItemFavorite), @(WDKContextMenuItemView), @(WDKContextMenuItemCopy), @(WDKContextMenuItemShare), @(WDKContextMenuItemDeletion) ];
        cell.contextMenuItemTitles = @[ NSLocalizedString(@"收藏", nil),NSLocalizedString(@"查看", nil), NSLocalizedString(@"复制路径", nil), NSLocalizedString(@"导出", nil), NSLocalizedString(@"删除", nil)];
    }
    cell.allowCustomActionContextMenuItems = WDKContextMenuItemFavorite | WDKContextMenuItemView | WDKContextMenuItemCopy | WDKContextMenuItemShare | WDKContextMenuItemDeletion;
    cell.delegate = self;
    
    if ([self fileIsPicture:path]) {
        UIImage *img = [UIImage imageWithContentsOfFile:path];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = img;
    }
    else {
        cell.imageView.image = nil;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat paddingT = 15.0f;
    CGFloat paddingL = 15.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, WDK_SectionHeader_H)];
    
    if ([self.filesFiltered count]) {
        
        NSString *loadingTip = nil;
        unsigned long long totalSize = 0;
        
        for (NSString *file in self.filesFiltered) {
            NSDictionary *attributes = self.fileAttributes[file];
            
            if (attributes[WDKFileAttributeFileSize] == nil) {
                loadingTip = NSLocalizedString(@"正在计算大小...", nil);
                break;
            }
            else {
                if ([attributes[WDKFileAttributeFileSize] isKindOfClass:[NSNumber class]]) {
                    totalSize += [attributes[WDKFileAttributeFileSize] unsignedLongLongValue];
                }
            }
        }
        
        NSString *unit = [self.filesFiltered count] == 1 ? @"item" : @"items";
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(paddingL, paddingT, screenSize.width - paddingL, 20)];
        label.text = [NSString stringWithFormat:@"%lu %@ (%@)", (unsigned long)[self.filesFiltered count], unit, loadingTip == nil ? [self prettySizeWithBytes:totalSize] : loadingTip];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textColor = [UIColor darkGrayColor];
        
        [view addSubview:label];
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return WDK_SectionHeader_H;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isSearching) {
        [self.searchBar resignFirstResponder];
    }
    
    NSString *file = self.filesFiltered[indexPath.row];
    NSString *path = [self pathForFile:file];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([self fileIsDirectory:file]) {
        WDKDirectoryBrowserViewController *vc = [[WDKDirectoryBrowserViewController alloc] initWithPath:path];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([self fileIsPicture:path]) {
        NSMutableArray *images = [NSMutableArray array];
        NSUInteger currentIndex = 0;
        for (NSUInteger i = 0; i < [self.imageFiles count]; i++) {
            NSString *imageFile = self.imageFiles[i];
            
            UIImage *image = [UIImage imageWithContentsOfFile:[self pathForFile:imageFile]];
            if (image) {
                [images addObject:image];
                
                if ([imageFile isEqualToString:file]) {
                    currentIndex = i;
                }
            }
        }
        
        if (images.count) {
            WDKImageBrowserViewController *vc = [[WDKImageBrowserViewController alloc] initWithImages:images index:currentIndex];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if ([WDKPlistViewController isSupportedFileWithFilePath:path fileType:nil rootObject:nil]) {
        WDKPlistViewController *vc = [[WDKPlistViewController alloc] initWithFilePath:path];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        if ([[path lastPathComponent] isEqualToString:@"CodeResources"] ||
            [[path lastPathComponent] isEqualToString:@"embedded.mobileprovision"]) {
            WDKPlistViewController *vc = [[WDKPlistViewController alloc] initWithFilePath:path];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            WDKTextEditViewController *vc = [[WDKTextEditViewController alloc] initWithFilePath:path];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.isSearching = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    
    self.isSearching = NO;
    
    self.filesFiltered = [self.files copy];
    [self.tableView reloadData];
    
    CGFloat offsetY = CGRectGetHeight(self.searchBar.frame);
    [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length) {
        NSMutableArray *arrM = [NSMutableArray array];
        
        for (NSString *fileName in self.files) {
            
            if ([fileName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [arrM addObject:fileName];
            }
        }
        
        self.filesFiltered = arrM;
    }
    else {
        self.filesFiltered = [self.files copy];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

#pragma mark - WDKInteractiveLabelDelegate

- (void)interactiveLabel:(WDKInteractiveLabel *)label contextMenuItemClicked:(WDKContextMenuItem)item withSender:(id)sender {
    if (item & WDKContextMenuItemView) {
        NSLog(@"view");
    }
    if (item & WDKContextMenuItemCopy) {
        NSLog(@"Copy");
    }
}

#pragma mark - WDKContextMenuCellDelegate

- (void)contextMenuCell:(WDKContextMenuCell *)cell contextMenuItemClicked:(WDKContextMenuItem)item withSender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cell.center];
    
    NSString *file = self.filesFiltered[indexPath.row];
    NSString *path = [self pathForFile:file];
    
    if (item & WDKContextMenuItemView) {        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:path preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"好的", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (item & WDKContextMenuItemCopy) {
        [UIPasteboard generalPasteboard].string = path;
    }
    else if (item & WDKContextMenuItemShare) {
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.documentController.UTI = @"public.data";
        [self.documentController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
    else if (item & WDKContextMenuItemProperty) {
        NSLog(@"WDKContextMenuItemProperty");
    }
    else if (item & WDKContextMenuItemFavorite) {
        NSLog(@"WDKContextMenuItemFavorite");
        [self doSavePathToFavorites:path];
    }
    else if (item & WDKContextMenuItemDeletion) {
        NSLog(@"WDKContextMenuItemDeletion");
        NSString *title = [NSString stringWithFormat:@"%@%@?", NSLocalizedString(@"确认删除", nil), file];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"删除", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSError *error = nil;
            NSString *fileName = file;
            NSString *filePath = [self pathForFile:fileName];
            if (filePath.length && [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.files];
                [arrM removeObject:fileName];
                
                self.files = arrM;
                self.filesFiltered = [self.files copy];
                [self.tableView reloadData];
            }
            else {
                NSLog(@"delete file failed at path: %@, error: %@", filePath, error);
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        // Note: Fix UIAlertController auto layout warning https://stackoverflow.com/questions/55372093/uialertcontrollers-actionsheet-gives-constraint-error-on-ios-12-2-12-3
        // @see https://stackoverflow.com/a/58666480
        [alert pruneNegativeWidthConstraints];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Favorites

- (void)doSavePathToFavorites:(NSString *)path {
    BOOL isDirectory = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:WDK_FAVORITE_PATHS_PLIST_PATH isDirectory:&isDirectory];
    
    if (!existed || isDirectory) {
        if (isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        NSString *directoryPath = [WDK_FAVORITE_PATHS_PLIST_PATH stringByDeletingLastPathComponent];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:NULL]) {
            // create the directory
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // create new file
        [[NSFileManager defaultManager] createFileAtPath:WDK_FAVORITE_PATHS_PLIST_PATH contents:nil attributes:nil];
    }
    
    NSString *relativePath = nil;
    WDKPathType pathType = [self pathTypeForPath:path relativePath:&relativePath];
    
    NSMutableDictionary *plistDictM = [NSMutableDictionary dictionary];
    
    NSData *data = [NSData dataWithContentsOfFile:WDK_FAVORITE_PATHS_PLIST_PATH];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSMutableDictionary *dictM = (NSMutableDictionary *)[NSPropertyListSerialization
                                                         propertyListFromData:data
                                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                         format:0
                                                         errorDescription:nil];
#pragma GCC diagnostic pop
    
    [plistDictM addEntriesFromDictionary:dictM];
    
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:dictM[NSStringFromWDKPathType(pathType)]];
    
    if (pathType == WDKPathTypeUnknown) {
        [arrM addObject:relativePath];
    }
    else if (pathType == WDKPathTypeHome) {
        [arrM addObject:relativePath];
    }
    else if (pathType == WDKPathTypeBundle) {
        [arrM addObject:relativePath];
    }
    
    plistDictM[NSStringFromWDKPathType(pathType)] = arrM;
    
    BOOL success = [plistDictM writeToFile:WDK_FAVORITE_PATHS_PLIST_PATH atomically:YES];
    if (!success) {
        NSLog(@"write failed");
    }
}

- (WDKPathType)pathTypeForPath:(NSString *)path relativePath:(NSString **)relativePath {
    static NSString *sHomeFolderName;
    static NSString *sBundleFolderName;
    
    NSString *relativePathL = [path copy];
    
    if (!sHomeFolderName) {
        sHomeFolderName = [NSHomeDirectory() lastPathComponent];
    }
    
    if (!sBundleFolderName) {
        sBundleFolderName = [[[NSBundle mainBundle] bundlePath] lastPathComponent];
    }
    
    if ([path rangeOfString:sHomeFolderName].location != NSNotFound) {
        NSRange range = [path rangeOfString:sHomeFolderName];
        relativePathL = [path substringFromIndex:range.location + range.length];
        *relativePath = [relativePathL stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        return WDKPathTypeHome;
    }
    else if ([path rangeOfString:sBundleFolderName].location != NSNotFound) {
        NSRange range = [path rangeOfString:sBundleFolderName];
        relativePathL = [path substringFromIndex:range.location + range.length];
        *relativePath = [relativePathL stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        return WDKPathTypeBundle;
    }
    else {
        *relativePath = relativePathL;
        return WDKPathTypeUnknown;
    }
}

@end
