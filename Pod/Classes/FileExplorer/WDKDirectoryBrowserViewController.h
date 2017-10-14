//
//  WDKDirectoryBrowserViewController.h
//  WDKFileExplorer
//
//  Created by wesley chen on 16/11/3.
//  Copyright © 2016年 wesley chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDKPathItem : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;
+ (instancetype)itemWithPath:(NSString *)path;
+ (instancetype)itemWithName:(NSString *)name path:(NSString *)path;
@end

@interface WDKDirectoryBrowserViewController : UIViewController

+ (NSArray<WDKPathItem *> *)favoritePathItems;
+ (void)deleteFavoritePathItemWithItem:(WDKPathItem *)item;

- (instancetype)initWithPath:(NSString *)path;

@end
