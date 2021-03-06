//
//  WDKContextMenuCell.m
//  Pods
//
//  Created by wesley chen on 16/11/4.
//
//

#import "WDKContextMenuCell.h"

@interface WDKContextMenuCell ()
@property (nonatomic, assign) WDKContextMenuItem contextMenuItemOptions;
@end

@implementation WDKContextMenuCell

#pragma mark - Public Methods

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.showContextMenuAlwaysCenetered = YES;
        
        // @see http://stackoverflow.com/questions/6591044/uilabel-with-uimenucontroller-not-resigning-first-responder-with-touch-outside
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuControllerDidHideMenuNotification:) name:UIMenuControllerDidHideMenuNotification object:nil];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressed:)];
        // Avoid hightlight aborting when long pressed
        longPressRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:longPressRecognizer];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (BOOL)canBecomeFirstResponder {
    NSLog(@"_cmd: %@", NSStringFromSelector(_cmd));
    return YES;
}

#pragma mark - Configure Custom Menu Items

- (void)setContextMenuItemTypes:(NSArray<NSNumber *> *)contextMenuItemTypes {
    _contextMenuItemTypes = contextMenuItemTypes;
    
    if (self.contextMenuItemTypes.count) {
        WDKContextMenuItem options = kNilOptions;
        
        for (NSNumber *number in self.contextMenuItemTypes) {
            WDKContextMenuItem opt = [number unsignedIntegerValue];
            options = options | opt;
        }
        
        self.contextMenuItemOptions = options;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (self.contextMenuItemTypes.count) {

        // Test actions and options
        if (action == @selector(viewAction:) && (self.contextMenuItemOptions & WDKContextMenuItemView)) {
            return YES;
        }
        else if (action == @selector(copyAction:) && (self.contextMenuItemOptions & WDKContextMenuItemCopy)) {
            return YES;
        }
        else if (action == @selector(shareAction:) && (self.contextMenuItemOptions & WDKContextMenuItemShare)) {
            return YES;
        }
        else if (action == @selector(propertyAction:) && (self.contextMenuItemOptions & WDKContextMenuItemProperty)) {
            return YES;
        }
        else if (action == @selector(favoriteAction:) && (self.contextMenuItemOptions & WDKContextMenuItemFavorite)) {
            return YES;
        }
        else if (action == @selector(deleteAction:) && (self.contextMenuItemOptions & WDKContextMenuItemDeletion)) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        // No menu items defined
        return NO;
    }
}

- (NSArray *)customMenuItems {
    NSMutableArray *items = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < [self.contextMenuItemTypes count]; i++) {
        WDKContextMenuItem option = [self.contextMenuItemTypes[i] unsignedIntegerValue];
        
        NSString *itemTitle = i < [self.contextMenuItemTitles count] ? self.contextMenuItemTitles[i] : nil;
        
        if (option & WDKContextMenuItemView) {
            NSString *title = itemTitle.length ? itemTitle : NSLocalizedString(@"View", nil);
            [items addObject:[[UIMenuItem alloc] initWithTitle:title action:@selector(viewAction:)]];
        }
        else if (option & WDKContextMenuItemCopy) {
            NSString *title = itemTitle.length ? itemTitle : NSLocalizedString(@"Copy", nil);
            [items addObject:[[UIMenuItem alloc] initWithTitle:title action:@selector(copyAction:)]];
        }
        else if (option & WDKContextMenuItemShare) {
            NSString *title = itemTitle.length ? itemTitle : NSLocalizedString(@"Share", nil);
            [items addObject:[[UIMenuItem alloc] initWithTitle:title action:@selector(shareAction:)]];
        }
        else if (option & WDKContextMenuItemProperty) {
            NSString *title = itemTitle.length ? itemTitle : NSLocalizedString(@"Property", nil);
            [items addObject:[[UIMenuItem alloc] initWithTitle:title action:@selector(propertyAction:)]];
        }
        else if (option & WDKContextMenuItemFavorite) {
            NSString *title = itemTitle.length ? itemTitle : NSLocalizedString(@"Favorite", nil);
            [items addObject:[[UIMenuItem alloc] initWithTitle:title action:@selector(favoriteAction:)]];
        }
        else if (option & WDKContextMenuItemDeletion) {
            NSString *title = itemTitle.length ? itemTitle : NSLocalizedString(@"Delete", nil);
            [items addObject:[[UIMenuItem alloc] initWithTitle:title action:@selector(deleteAction:)]];
        }
    }
    
    return items;
}

#pragma mark > Menu Item Actions (without UIResponderStandardEditActions)

- (void)viewAction:(id)sender {
    if (self.allowCustomActionContextMenuItems & WDKContextMenuItemView) {
        if ([self.delegate respondsToSelector:@selector(contextMenuCell:contextMenuItemClicked:withSender:)]) {
            [self.delegate contextMenuCell:self contextMenuItemClicked:WDKContextMenuItemView withSender:self];
        }
    }
    else {
        // Default action
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:self.textLabel.text delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)copyAction:(id)sender {
    if (self.allowCustomActionContextMenuItems & WDKContextMenuItemCopy) {
        if ([self.delegate respondsToSelector:@selector(contextMenuCell:contextMenuItemClicked:withSender:)]) {
            [self.delegate contextMenuCell:self contextMenuItemClicked:WDKContextMenuItemCopy withSender:self];
        }
    }
    else {
        // Default action
        [UIPasteboard generalPasteboard].string = self.textLabel.text;
    }
}

- (void)shareAction:(id)sender {
    if (self.allowCustomActionContextMenuItems & WDKContextMenuItemShare) {
        if ([self.delegate respondsToSelector:@selector(contextMenuCell:contextMenuItemClicked:withSender:)]) {
            [self.delegate contextMenuCell:self contextMenuItemClicked:WDKContextMenuItemShare withSender:self];
        }
    }
    else {
        // Default action
        // do nothing here
    }
}

- (void)propertyAction:(id)sender {
    if (self.allowCustomActionContextMenuItems & WDKContextMenuItemProperty) {
        if ([self.delegate respondsToSelector:@selector(contextMenuCell:contextMenuItemClicked:withSender:)]) {
            [self.delegate contextMenuCell:self contextMenuItemClicked:WDKContextMenuItemProperty withSender:self];
        }
    }
    else {
        // Default action
        // do nothing here
    }
}

- (void)favoriteAction:(id)sender {
    if (self.allowCustomActionContextMenuItems & WDKContextMenuItemFavorite) {
        if ([self.delegate respondsToSelector:@selector(contextMenuCell:contextMenuItemClicked:withSender:)]) {
            [self.delegate contextMenuCell:self contextMenuItemClicked:WDKContextMenuItemFavorite withSender:self];
        }
    }
    else {
        // Default action
        // do nothing here
    }
}

- (void)deleteAction:(id)sender {
    if (self.allowCustomActionContextMenuItems & WDKContextMenuItemDeletion) {
        if ([self.delegate respondsToSelector:@selector(contextMenuCell:contextMenuItemClicked:withSender:)]) {
            [self.delegate contextMenuCell:self contextMenuItemClicked:WDKContextMenuItemDeletion withSender:self];
        }
    }
    else {
        // Default action
        // do nothing here
    }
}

#pragma mark - NSNotification

- (void)handleMenuControllerDidHideMenuNotification:(NSNotification *)notification {
//    NSLog(@"_cmd: %@", NSStringFromSelector(_cmd));
    [self resignFirstResponder];
}

#pragma mark - Handle long press gestures

- (void)cellLongPressed:(UILongPressGestureRecognizer *)recognizer {
    // @see http://nshipster.com/uimenucontroller/
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"_cmd: %@", NSStringFromSelector(_cmd));
        CGPoint location = [recognizer locationInView:recognizer.view];
        
        [recognizer.view becomeFirstResponder];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setMenuItems:[self customMenuItems]];
        // show menu in cener
        if (self.showContextMenuAlwaysCenetered) {
            [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
        }
        else {
            // show menu on tapping point
            // @see http://stackoverflow.com/questions/1146587/how-to-get-uimenucontroller-work-for-a-custom-view
            [menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:recognizer.view];
        }
        
        [menuController setMenuVisible:YES animated:YES];
        
        // Prevent - tableView:didSelectRowAtIndexPath: called after long pressed
        recognizer.cancelsTouchesInView = YES;
    }
}

@end
