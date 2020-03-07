//
//  WDKDebugPanelCell.m
//  Pods
//
//  Created by wesley chen on 16/8/27.
//
//

#import "WDKDebugPanelCell.h"

#define UICOLOR_RGB(color)       [UIColor colorWithRed: (((color) >> 16) & 0xFF) / 255.0 green: (((color) >> 8) & 0xFF) / 255.0 blue: ((color) & 0xFF) / 255.0 alpha: 1.0]

@interface WDKDebugPanelCell ()
@property (nonatomic, assign) WDKDebugPanelCellType type;
@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelSubtitle;

@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, strong) void (^toggleAction)(WDKDebugPanelCell *cell, BOOL toggleOn);
@end

static NSString *WDK_sIdentifierForCellDefault  = @"WDK_sIdentifierForCellDefault";
static NSString *WDK_sIdentifierForCellValue1   = @"WDK_sIdentifierForCellValue1";
static NSString *WDK_sIdentifierForCellValue2   = @"WDK_sIdentifierForCellValue2";
static NSString *WDK_sIdentifierForCellSubtitle = @"WDK_sIdentifierForCellSubtitle";
static NSString *WDK_sIdentifierForCellCellTypeSwitch = @"WDK_sIdentifierForCellCellTypeSwitch";

@implementation WDKDebugPanelCell

- (instancetype)initWithType:(WDKDebugPanelCellType)type {
    
    NSString *reuseIdentifier = [[self class] reuseIdentifierForType:type];
    
    if (type > WDKDebugPanelCellTypeSubtitle) {
        self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    else {
        self = [super initWithStyle:(UITableViewCellStyle)type reuseIdentifier:reuseIdentifier];
    }
    
    if (self) {
        self.type = type;
        
        // TODO: add more type here
        /*
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat cellHeight = [[self class] heightForCellType:type];
        if (self.type == WDKDebugPanelCellTypeDefault) {
            CGFloat spaceL = 15.0f;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(spaceL, 0, screenSize.width - spaceL, cellHeight)];
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.textColor = UICOLOR_RGB(0x1fbad6);
            [self addSubview:label];
            self.labelTitle = label;
        }
         */
    }
    
    return self;
}

+ (WDKDebugPanelCell *)dequeueReusableCellWithTableView:(UITableView *)tableView type:(WDKDebugPanelCellType)type {
    NSString *reuseIdentifier = [[self class] reuseIdentifierForType:type];
    
    WDKDebugPanelCell *cell = (WDKDebugPanelCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    return cell;
}

- (void)configureCellWithItem:(WDKDebugPanelCellItem *)item {
    switch (item.cellType) {
        case WDKDebugPanelCellTypeDefault: {
            [self configureDefaultCell:item];
            break;
        }
        case WDKDebugPanelCellTypeValue1: {
            [self configureValue1Cell:item];
            break;
        }
        case WDKDebugPanelCellTypeValue2: {
            [self configureValue2Cell:item];
            break;
        }
        case WDKDebugPanelCellTypeSubtitle: {
            [self configureSubtitleCell:item];
            break;
        }
        case WDKDebugPanelCellTypeSwitch: {
            [self configureSwitchCell:item];
        }
    }
}

+ (CGFloat)heightForCellType:(WDKDebugPanelCellType)type {
    /*
    switch (type) {
        case WDKDebugPanelCellTypeDefault: {
            return 44.0f;
        }
        case WDKDebugPanelCellTypeSubtitleWithIcon: {
            return 44.0f;
        }
    }
     */
    return 44.0f;
}

+ (NSString *)reuseIdentifierForType:(WDKDebugPanelCellType)type {
    switch (type) {
        case WDKDebugPanelCellTypeDefault: {
            return WDK_sIdentifierForCellDefault;
        }
        case WDKDebugPanelCellTypeValue1: {
            return WDK_sIdentifierForCellValue1;
        }
        case WDKDebugPanelCellTypeValue2: {
            return WDK_sIdentifierForCellValue2;
        }
        case WDKDebugPanelCellTypeSubtitle: {
            return WDK_sIdentifierForCellSubtitle;
        }
        case WDKDebugPanelCellTypeSwitch: {
            return WDK_sIdentifierForCellCellTypeSwitch;
        }
        default: {
            NSAssert(NO, @"unknown type: %ld", (long)type);
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectIntersectsRect([self.textLabel frame], [self.detailTextLabel frame])) {
        // adjust textLabel's width, let detailTextLabel stay its width
        CGRect frame = self.textLabel.frame;
        frame.size.width = CGRectGetMinX(self.detailTextLabel.frame) - CGRectGetMinX(self.textLabel.frame);
        self.textLabel.frame = frame;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumFontSize = 10.0f;
    }
    else {
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
}

#pragma mark - Public Methods

- (void)startLoading {
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loading.hidesWhenStopped = YES;
    [loading startAnimating];
    
    self.accessoryView = loading;
}

- (void)stopLoading {
    UIActivityIndicatorView *loading = (UIActivityIndicatorView *)self.accessoryView;
    if ([loading isKindOfClass:[UIActivityIndicatorView class]]) {
        [loading stopAnimating];
    }
    
    self.accessoryView = self.toggle;
}

- (void)setToggleOn:(BOOL)on {
    UIActivityIndicatorView *loading = (UIActivityIndicatorView *)self.accessoryView;
    if ([loading isKindOfClass:[UIActivityIndicatorView class]]) {
        [loading stopAnimating];
    }
    
    self.toggle.on = on;
    self.accessoryView = self.toggle;
}

#pragma mark - Configuration Methods

- (void)configureDefaultCell:(WDKDebugPanelCellItem *)item {
    [self configureGeneralCellWithItem:item];
}

- (void)configureValue1Cell:(WDKDebugPanelCellItem *)item {
    [self configureGeneralCellWithItem:item];
}

- (void)configureValue2Cell:(WDKDebugPanelCellItem *)item {
    [self configureGeneralCellWithItem:item];
}

- (void)configureSubtitleCell:(WDKDebugPanelCellItem *)item {
    [self configureGeneralCellWithItem:item];
}

- (void)configureSwitchCell:(WDKDebugPanelCellItem *)item {
    [self configureGeneralCellWithItem:item];
    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.on = item.toggleOn;
    [toggle addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    self.accessoryView = toggle;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    self.toggle = toggle;
    self.toggleAction = item.toggleAction;
}

- (void)configureGeneralCellWithItem:(WDKDebugPanelCellItem *)item {
    self.textLabel.text = item.title;
    self.detailTextLabel.text = item.subtitle;
    
    self.textLabel.textColor = item.titleColor ? item.titleColor : [UIColor blackColor];
    self.detailTextLabel.textColor = item.subtitleColor ? item.subtitleColor: [UIColor colorWithRed:142 / 255.0 green:142 / 255.0 blue:147 / 255.0 alpha:1];
    
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.selectionStyle = (item.alertMessage || item.accessoryType == WDKDebugPanelCellAccessoryTypeDisclosureIndicator) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    self.accessoryView = nil;
    self.accessoryType = (UITableViewCellAccessoryType)item.accessoryType;
}

#pragma mark - Actions

- (void)switchToggled:(UISwitch *)toggle {
    if (self.toggleAction) {
        self.toggleAction(self, toggle.on);
    }
}

#pragma mark - Utility

- (UIImage *)podImageNamed:(NSString *)name {
    NSString *podBundle = [NSString stringWithFormat:@"%@.bundle", @"UCar"];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", podBundle, name];
    
    UIImage *image = [UIImage imageNamed:imagePath];
    
#if DEBUG
    NSAssert(image, @"Can't find image at path: %@", imagePath);
#endif
    
    return image;
}

@end

