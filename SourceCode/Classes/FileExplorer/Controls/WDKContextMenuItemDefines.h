//
//  WDKContextMenuItemDefines.h
//  Pods
//
//  Created by wesley chen on 16/11/4.
//
//

#ifndef WDKContextMenuItemDefines_h
#define WDKContextMenuItemDefines_h

// Predefined Menu Items, and order is fixed
typedef NS_OPTIONS(NSUInteger, WDKContextMenuItem) {
    WDKContextMenuItemView       = 1 << 0, // 0
    WDKContextMenuItemCopy       = 1 << 1, // 2
    WDKContextMenuItemShare      = 1 << 2, // 4
    WDKContextMenuItemProperty   = 1 << 3, // 8
    WDKContextMenuItemFavorite   = 1 << 4,
    WDKContextMenuItemDeletion   = 1 << 5,
};


#endif /* WDKContextMenuItemDefines_h */
