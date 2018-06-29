//
//  WDKObjectExplorerViewController.m
//  WCDebugKit
//
//  Created by wesley_chen on 23/03/2018.
//

#import "WDKObjectExplorerViewController.h"

@interface WDKObjectExplorerViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *filterText;
@end

@implementation WDKObjectExplorerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Public Methods

- (void)setObject:(id)object {
    _object = object;
    
    self.title = [[object class] description];
}

#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat navH = 64.0f;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navH, screenSize.width, screenSize.height - navH) style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tableHeaderView = self.searchBar;
        
        _tableView = tableView;
    }
    
    return _tableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.placeholder = NSLocalizedString(@"Filter", nil);
        searchBar.delegate = self;
        searchBar.showsScopeBar = YES;
        searchBar.scopeButtonTitles = @[ NSLocalizedString(@"No Inheritance", nil), NSLocalizedString(@"Include Inheritance", nil) ];
        [searchBar sizeToFit];
        
        _searchBar = searchBar;
    }
    
    return _searchBar;
}

#pragma mark - Override Methods

- (NSArray *)possibleExplorerSections {
    static NSArray *possibleSections = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        possibleSections = @[@(FLEXObjectExplorerSectionDescription),
                             @(FLEXObjectExplorerSectionCustom),
                             @(FLEXObjectExplorerSectionProperties),
                             @(FLEXObjectExplorerSectionIvars),
                             @(FLEXObjectExplorerSectionMethods),
                             @(FLEXObjectExplorerSectionClassMethods),
                             @(FLEXObjectExplorerSectionSuperclasses),
                             @(FLEXObjectExplorerSectionReferencingInstances)];
    });
    return possibleSections;
}

- (BOOL)shouldShowDescription {
    BOOL showDescription = YES;
    
    NSObject *object = self.object;
    NSString *description = nil;
    if ([object respondsToSelector:@selector(debugDescription)]) {
        description = [object debugDescription];
    }
    else if ([object respondsToSelector:@selector(description)]) {
        description = [object description];
    }
    
    // Not if it's empty or nil.
    if (showDescription) {
        showDescription = [description length] > 0;
    }
    
    // Not if we have filter text that doesn't match the desctiption.
    if (showDescription && [self.filterText length] > 0) {
        showDescription = [description rangeOfString:self.filterText options:NSCaseInsensitiveSearch].length > 0;
    }
    
    return showDescription;
}

#pragma mark - Table View Helpers

- (NSArray *)visibleExplorerSections {
    NSMutableArray *visibleSections = [NSMutableArray array];
    
    for (NSNumber *possibleSection in [self possibleExplorerSections]) {
        FLEXObjectExplorerSection explorerSection = [possibleSection unsignedIntegerValue];
        if ([self numberOfRowsForExplorerSection:explorerSection] > 0) {
            [visibleSections addObject:possibleSection];
        }
    }
    
    return visibleSections;
}

- (NSInteger)numberOfRowsForExplorerSection:(FLEXObjectExplorerSection)section
{
    NSInteger numberOfRows = 0;
    /*
    switch (section) {
        case FLEXObjectExplorerSectionDescription:
            numberOfRows = [self shouldShowDescription] ? 1 : 0;
            break;
            
        case FLEXObjectExplorerSectionCustom:
            numberOfRows = [self.customSectionVisibleIndexes count];
            break;
            
        case FLEXObjectExplorerSectionProperties:
            numberOfRows = [self.filteredProperties count];
            break;
            
        case FLEXObjectExplorerSectionIvars:
            numberOfRows = [self.filteredIvars count];
            break;
            
        case FLEXObjectExplorerSectionMethods:
            numberOfRows = [self.filteredMethods count];
            break;
            
        case FLEXObjectExplorerSectionClassMethods:
            numberOfRows = [self.filteredClassMethods count];
            break;
            
        case FLEXObjectExplorerSectionSuperclasses:
            numberOfRows = [self.filteredSuperclasses count];
            break;
            
        case FLEXObjectExplorerSectionReferencingInstances:
            // Hide this section if there is fliter text since there's nothing searchable (only 1 row, always the same).
            numberOfRows = [self.filterText length] == 0 ? 1 : 0;
            break;
    }
     */
    return numberOfRows;
}

#pragma mark - UITableViewDataSource

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self visibleExplorerSections] count];
}
 */

#pragma mark - UITableViewDelegate

@end
