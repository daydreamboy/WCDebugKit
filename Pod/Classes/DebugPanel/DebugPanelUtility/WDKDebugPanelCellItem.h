//
//  WDKDebugPanelCellItem.h
//  Pods
//
//  Created by wesley chen on 16/10/18.
//
//

#import <Foundation/Foundation.h>

@class WDKDebugPanelCell;

typedef NS_ENUM(NSInteger, WDKDebugPanelCellType) {
    WDKDebugPanelCellTypeDefault = UITableViewCellStyleDefault,
    WDKDebugPanelCellTypeValue1 = UITableViewCellStyleValue1,
    WDKDebugPanelCellTypeValue2 = UITableViewCellStyleValue2,
    WDKDebugPanelCellTypeSubtitle = UITableViewCellStyleSubtitle,
    WDKDebugPanelCellTypeSwitch, /**< started with UITableViewCellStyleDefault. Ignore WDKDebugPanelCellAccessoryType */
};

typedef NS_ENUM(NSInteger, WDKDebugPanelCellAccessoryType) {
    WDKDebugPanelCellAccessoryTypeNone = UITableViewCellAccessoryNone,
    WDKDebugPanelCellAccessoryTypeDisclosureIndicator = UITableViewCellAccessoryDisclosureIndicator,
    // TODO: reserved types
    /*
    WDKDebugPanelCellAccessoryTypeDetailDisclosureButton = UITableViewCellAccessoryDetailDisclosureButton,
    WDKDebugPanelCellAccessoryTypeCheckmark = UITableViewCellAccessoryCheckmark,
    WDKDebugPanelCellAccessoryTypeDetailButton = UITableViewCellAccessoryDetailButton,
     */
};

@interface WDKDebugPanelCellItem : NSObject
// cell's userinterface
@property (nonatomic, assign) WDKDebugPanelCellType cellType;
@property (nonatomic, assign) WDKDebugPanelCellAccessoryType accessoryType;
@property (nonatomic, copy) NSString *title;        // the first text, always on left
@property (nonatomic, copy) NSString *subtitle;     // the second text, below the first text or on right
@property (nonatomic, copy) NSString *imageIcon;    // TODO:

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *subtitleColor;

@property (nonatomic, strong) id userInfo;  // accessory data

// cell's interaction
@property (nonatomic, copy) NSString *alertMessage; // If not nil, show the alertMessage when clicking on cell, and allow copy the alertMessage
@property (nonatomic, copy) void (^selectAction)(UIViewController *viewController); // action for select a cell, when WDKDebugPanelCellAccessoryTypeDisclosureIndicator
@property (nonatomic, copy) void (^deleteAction)(); // action for delete a cell, when `swipeable` is YES
@property (nonatomic, assign) BOOL swipeable; // allow action to swipe

// WDKDebugPanelCellTypeSwitch
@property (nonatomic, assign) BOOL toggleOn;
@property (nonatomic, copy) void (^toggleAction)(WDKDebugPanelCell *cell, BOOL toggleOn);

+ (instancetype)itemWithType:(WDKDebugPanelCellType)type;

@end
