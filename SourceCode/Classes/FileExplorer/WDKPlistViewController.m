//
//  WDKPlistViewController.m
//  Pods
//
//  Created by wesley chen on 17/4/8.
//
//

#import "WDKPlistViewController.h"
#import "WDKContextMenuCell.h"
#import "UIAlertView+WDK.h"
#import "WDKMobileProvisionTool.h"
#import "WDKTextEditViewController.h"

#ifndef IOS8_OR_LATER
#define IOS8_OR_LATER          ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)
#endif

#define STATUS_BAR_H            (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))
#define NAV_BAR_H               (CGRectGetHeight(self.navigationController.navigationBar.frame))

#pragma mark -

#define kChangeInfoNewKey   @"kChangeInfoNewKey"
#define kChangeInfoNewValue @"kChangeInfoNewValue"

typedef NS_ENUM(NSUInteger, WCPlistEditViewControllerMode) {
    WCPlistEditViewControllerModeEdit,      /**< 编辑模式 */
    WCPlistEditViewControllerModeReadonly,  /**< 只读模式 */
    WCPlistEditViewControllerModeCreate,    /**< 创建模式 */
};

@interface WCPlistEditViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, assign) WCPlistEditViewControllerMode mode;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *textViewKey;
@property (nonatomic, strong) UITextView *textViewValue;
@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) void (^completion)(NSDictionary *changeInfo, BOOL isChanged);
@property (nonatomic, strong) UIBarButtonItem *setItem;
@property (nonatomic, strong) UILabel *labelKeyPath;
@property (nonatomic, strong) UILabel *labelValueObjectType;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerViewData;
@end

@implementation WCPlistEditViewController

- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath completion:(void (^)(NSDictionary *changeInfo, BOOL isChanged))completion {
    self = [super init];
    if (self) {
        _object = object;
        _keyPath = keyPath;
        _completion = completion;
        
        _pickerViewData = @[@"YES", @"NO"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self loadObject];
    [self registerNotifications];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        CGFloat keyboardHeight = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

- (void)loadObject {
    self.textField.text = [[self.keyPath componentsSeparatedByString:@"."] lastObject];
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
    }
    else if ([self.object isKindOfClass:[NSArray class]]) {
    }
    else if ([self.object isKindOfClass:[NSDate class]]) {
        self.textViewValue.text = [[self.class dateFormatterForNSDate] stringFromDate:self.object];
    }
    else if ([self.object isKindOfClass:[NSData class]]) {
        self.textViewValue.text = [NSString stringWithFormat:@"%@", self.object];
        self.textViewValue.textColor = [UIColor lightGrayColor];
        self.textViewValue.editable = NO;
        
        self.setItem.enabled = NO;
    }
    else if ([self.object isKindOfClass:[NSNumber class]]) {
        NSString *className = NSStringFromClass([self.object class]);
        if ([className isEqualToString:@"__NSCFBoolean"]) {
            // bools
            self.textViewValue.hidden = YES;
            self.pickerView.hidden = NO;
            
            NSString *boolString = [self.object boolValue] ? @"YES" : @"NO";
            NSInteger row = [self.pickerViewData indexOfObject:boolString];
            [self.pickerView selectRow:row inComponent:0 animated:NO];
        }
        else {
            // numbers
            self.textViewValue.text = [NSString stringWithFormat:@"%@", self.object];
        }
    }
    else if ([self.object isKindOfClass:[NSString class]]) {
        self.textViewValue.text = [self.object copy];
    }
    else {
        self.textViewValue.text = @"(unknown)";
    }
}

- (void)setup {
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.scrollView];
    
    self.navigationItem.rightBarButtonItem = self.setItem;
}

#pragma mark - Utility

+ (NSDateFormatter *)dateFormatterForNSDate {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    });
    
    return dateFormatter;
}

#pragma mark - Getters

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat margin = 10.0f;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_H + NAV_BAR_H, screenSize.width, screenSize.height - STATUS_BAR_H - NAV_BAR_H)];
        [scrollView addSubview:self.labelKeyPath];
        [scrollView addSubview:self.textField];
        [scrollView addSubview:self.labelValueObjectType];
        [scrollView addSubview:self.textViewValue];
        [scrollView addSubview:self.pickerView];
        scrollView.contentSize = CGSizeMake(screenSize.width, CGRectGetMaxY(self.textViewValue.frame) + margin);
        
        _scrollView = scrollView;
    }
    
    return _scrollView;
}

- (UIBarButtonItem *)setItem {
    if (!_setItem) {
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(setItemClicked:)];
        barItem.enabled = (self.mode == WCPlistEditViewControllerModeReadonly ? NO : YES);
        
        _setItem = barItem;
    }
    
    return _setItem;
}

- (UILabel *)labelKeyPath {
    if (!_labelKeyPath) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat margin = 10.0f;
        CGFloat width = screenSize.width - 2 * margin;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, width, 0)];
        label.numberOfLines = 0;
        label.text = _keyPath;
        label.font = [UIFont systemFontOfSize:14.0f];
        
        CGRect textRect = [label.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:nil];
        
        CGRect frame = label.frame;
        frame.size.height = ceil(textRect.size.height);
        label.frame = frame;
        
        _labelKeyPath = label;
    }
    
    return _labelKeyPath;
}

- (UITextView *)textViewKey {
    if (!_textViewKey) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat margin = 10.0f;
        CGFloat width = screenSize.width - 2 * margin;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.labelKeyPath.frame) + margin, width, 0)];
        textView.backgroundColor = [UIColor whiteColor];
        textView.layer.borderColor = [UIColor blackColor].CGColor;
        textView.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        textView.font = [UIFont systemFontOfSize:15.0f];
        textView.returnKeyType = UIReturnKeyNext;
        
        NSString *lastComponent = [[self.keyPath componentsSeparatedByString:@"."] lastObject];
        if (self.mode == WCPlistEditViewControllerModeReadonly || ([lastComponent hasPrefix:@"["] && [lastComponent hasSuffix:@"]"])) {
            textView.editable = NO;
            textView.textColor = [UIColor lightGrayColor];
        }
        else {
            textView.editable = YES;
            textView.textColor = [UIColor blackColor];
        }
        
        _textViewKey = textView;
    }
    
    return _textViewKey;
}

- (UITextField *)textField {
    if (!_textField) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat margin = 10.0f;
        CGFloat width = screenSize.width - 2 * margin;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.labelKeyPath.frame) + margin, width, 30)];
        textField.backgroundColor = [UIColor whiteColor];
        textField.layer.borderColor = [UIColor blackColor].CGColor;
        textField.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        textField.font = [UIFont systemFontOfSize:15.0f];
        textField.returnKeyType = UIReturnKeyNext;
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 30)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        NSString *lastComponent = [[self.keyPath componentsSeparatedByString:@"."] lastObject];
        if (self.mode == WCPlistEditViewControllerModeReadonly || ([lastComponent hasPrefix:@"["] && [lastComponent hasSuffix:@"]"])) {
            textField.enabled = NO;
            textField.textColor = [UIColor lightGrayColor];
        }
        else {
            textField.enabled = YES;
            textField.textColor = [UIColor blackColor];
        }
        
        _textField = textField;
    }
    
    return _textField;
}

- (UILabel *)labelValueObjectType {
    if (!_labelValueObjectType) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat margin = 10.0f;
        CGFloat width = screenSize.width - 2 * margin;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.textField.frame) + margin, width, 0)];
        label.numberOfLines = 0;
        label.text = NSStringFromClass([_object class]);
        label.font = [UIFont systemFontOfSize:14.0f];
        
        CGRect textRect = [label.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:nil];
        
        CGRect frame = label.frame;
        frame.size.height = ceil(textRect.size.height);
        label.frame = frame;
        
        _labelValueObjectType = label;
    }
    
    return _labelValueObjectType;
}

- (UITextView *)textViewValue {
    if (!_textViewValue) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat margin = 10.0f;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.labelValueObjectType.frame) + margin, screenSize.width - 2 * margin, 300)];
        textView.layer.borderColor = [UIColor blackColor].CGColor;
        textView.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        textView.font = [UIFont systemFontOfSize:15.0f];
        
        if (self.mode == WCPlistEditViewControllerModeReadonly) {
            textView.editable = NO;
            textView.textColor = [UIColor lightGrayColor];
        }
        
        _textViewValue = textView;
    }
    
    return _textViewValue;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat navBarHeight = 64;
        
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.hidden = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        CGRect frame = pickerView.bounds;
        frame.size.width = screenSize.width;
        frame.origin.x = 0;
        frame.origin.y = screenSize.height - CGRectGetHeight(pickerView.bounds) - navBarHeight;
        pickerView.frame = frame;

        _pickerView = pickerView;
    }
    
    return _pickerView;
}

#pragma mark - Actions

- (void)setItemClicked:(id)sender {
    NSString *key = [[self.keyPath componentsSeparatedByString:@"."] lastObject];
    NSString *newKey = [self.textField.text copy];
    
    if ([self.object isKindOfClass:[NSDictionary class]]) {
        // impossible
    }
    else if ([self.object isKindOfClass:[NSArray class]]) {
        // impossible
    }
    else if ([self.object isKindOfClass:[NSDate class]]) {
        NSDate *newDate = [[self.class dateFormatterForNSDate] dateFromString:[self.textViewValue.text copy]];
        
        if (newDate) {
            NSMutableDictionary *changeDict = [NSMutableDictionary dictionary];
            BOOL changed = NO;
            if (![newDate isEqualToDate:self.object]) {
                changed = YES;
                changeDict[kChangeInfoNewValue] = newDate;
            }
            if (![newKey isEqualToString:key]) {
                changed = YES;
                changeDict[kChangeInfoNewKey] = newKey;
            }
            
            !self.completion ?: self.completion(changeDict, changed);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"保存出错" message:@"日期时间格式不对" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
    }
    else if ([self.object isKindOfClass:[NSData class]]) {
        // can't set
    }
    else if ([self.object isKindOfClass:[NSNumber class]]) {
        
        NSString *className = NSStringFromClass([self.object class]);
        if ([className isEqualToString:@"__NSCFBoolean"]) {
            // bools
            NSString *yesOrNo = self.pickerViewData[[self.pickerView selectedRowInComponent:0]];
            NSNumber *newBool = [NSNumber numberWithBool:([yesOrNo isEqualToString:@"YES"] ? YES : NO)];
            
            NSMutableDictionary *changeDict = [NSMutableDictionary dictionary];
            BOOL changed = NO;
            if ([newBool boolValue] != [self.object boolValue]) {
                changed = YES;
                changeDict[kChangeInfoNewValue] = newBool;
            }
            if (![newKey isEqualToString:key]) {
                changed = YES;
                changeDict[kChangeInfoNewKey] = newKey;
            }
            
            !self.completion ?: self.completion(changeDict, changed);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            // numbers
            NSNumber *newNumber = @([self.textViewValue.text integerValue]);
            
            NSMutableDictionary *changeDict = [NSMutableDictionary dictionary];
            BOOL changed = NO;
            if (![newNumber isEqualToNumber:self.object]) {
                changed = YES;
                changeDict[kChangeInfoNewValue] = newNumber;
            }
            if (![newKey isEqualToString:key]) {
                changed = YES;
                changeDict[kChangeInfoNewKey] = newKey;
            }
            
            !self.completion ?: self.completion(changeDict, changed);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if ([self.object isKindOfClass:[NSString class]]) {
        NSString *newString = [self.textViewValue.text copy];
        
        NSMutableDictionary *changeDict = [NSMutableDictionary dictionary];
        BOOL changed = NO;
        if (![newString isEqualToString:self.object]) {
            changed = YES;
            changeDict[kChangeInfoNewValue] = newString;
        }
        if (![newKey isEqualToString:key]) {
            changed = YES;
            changeDict[kChangeInfoNewKey] = newKey;
        }
        
        !self.completion ?: self.completion(changeDict, changed);
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        // unexpected
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerViewData count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerViewData[row];
}

@end

#pragma mark - WDKPlistViewController

// keys for fileInfoDict
#define kFilePath           @"kFilePath"
#define kFileReadonly       @"kFileReadonly"
#define kRootObject         @"kRootObject"
#define kPlistFileFormat    @"kPlistFileFormat"
#define kFileType           @"kFileType"

typedef NS_ENUM(NSInteger, WDKPlistViewController_PlistFileFormat) {
    WDKPlistViewController_PlistFileFormatUnknown,
    WDKPlistViewController_PlistFileFormatOpenStepFormat = NSPropertyListOpenStepFormat,
    WDKPlistViewController_PlistFileFormatXMLFormat_v1_0 = NSPropertyListXMLFormat_v1_0,
    WDKPlistViewController_PlistFileFormatBinaryFormat_v1_0 = NSPropertyListBinaryFormat_v1_0,
};

@interface WDKPlistViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate>
@property (nonatomic, assign) NSPropertyListFormat plistFileFormat;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *actionsItem;
@property (nonatomic, strong) NSError *errorOfReadingFile;
@property (nonatomic, strong) id currentObj;
@property (nonatomic, copy) NSArray<NSString *> *currentPathComponents;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
+ (NSMutableDictionary *)fileInfoDict;
@end

@implementation WDKPlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.errorOfReadingFile) {
        NSError *error = self.errorOfReadingFile;
        NSString *filePath = [[[self class] fileInfoDict] objectForKey:kFilePath];
        NSString *title = [NSString stringWithFormat:@"不能读取文件%@", [filePath lastPathComponent]];
        NSString *msg = [NSString stringWithFormat:@"code: %ld, %@", (long)error.code, error.localizedDescription];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Public Methods

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _currentPathComponents = @[@"root"];
        
        NSError *error = nil;
        id rootObject = nil;
        WDKPlistViewController_FileType fileType;
        [[self class] isSupportedFileWithFilePath:filePath fileType:&fileType rootObject:&rootObject error:&error plistType:&_plistFileFormat];
        _currentObj = rootObject;
        
        [[[self class] fileInfoDict] removeAllObjects]; // Note: reset file info
        
        if (_currentObj && !error) {
            BOOL fileIsReadonly = ![[NSFileManager defaultManager] isWritableFileAtPath:filePath];
            
            [[[self class] fileInfoDict] setObject:filePath forKey:kFilePath];
            [[[self class] fileInfoDict] setObject:@(fileIsReadonly) forKey:kFileReadonly];
            [[[self class] fileInfoDict] setObject:_currentObj forKey:kRootObject];
            [[[self class] fileInfoDict] setObject:@(fileType) forKey:kFileType];
            [[[self class] fileInfoDict] setObject:@(_plistFileFormat) forKey:kPlistFileFormat];
        }
        else {
            self.errorOfReadingFile = error;
            
            [[[self class] fileInfoDict] setObject:@(WDKPlistViewController_FileTypeUnsupported) forKey:kFileType];
        }
    }
    return self;
}

- (void)dealloc {
    [[[self class] fileInfoDict] removeAllObjects]; // Note: reset file info
}

+ (BOOL)isSupportedFileWithFilePath:(NSString *)filePath fileType:(WDKPlistViewController_FileType * _Nullable)fileType rootObject:(id * _Nullable)rootObject {
    return [self isSupportedFileWithFilePath:filePath fileType:fileType rootObject:rootObject error:nil plistType:nil];
}

#pragma mark - Internal Methods


+ (BOOL)isSupportedFileWithFilePath:(NSString *)filePath fileType:(WDKPlistViewController_FileType * _Nullable)fileType rootObject:(id * _Nullable)rootObject error:(NSError * _Nullable * _Nullable)error plistType:(NSPropertyListFormat * _Nullable)plistType {
#define ReturnNotSupportedFile(errorL, plistTypeL) \
if (fileType != NULL) { \
    *fileType = WDKPlistViewController_FileTypeUnsupported; \
} \
if (rootObject != NULL) { \
    *rootObject = nil; \
} \
if (error != NULL) { \
    *error = errorL; \
} \
if (plistType != NULL) { \
    *plistType = plistTypeL; \
} \
return NO;
    
#define ReturnSupportedFile(type, object, errorL, plistTypeL) \
if (fileType != NULL) { \
    *fileType = type; \
} \
if (rootObject != NULL) { \
    *rootObject = object; \
} \
if (error != NULL) { \
    *error = errorL; \
} \
if (plistType != NULL) { \
    *plistType = plistTypeL; \
} \
return YES;
    
    if (![filePath isKindOfClass:[NSString class]]) {
        ReturnNotSupportedFile(nil, 0)
    }
    
    if ([[filePath lastPathComponent] isEqualToString:@"embedded.mobileprovision"]) {
        NSDictionary *dict = [WDKMobileProvisionTool mobileprovisionInfo];
        if (dict) {
            ReturnSupportedFile(WDKPlistViewController_FileTypePlist, dict, nil, 0)
        }
    }
    
    NSError *errorL;
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        ReturnNotSupportedFile(nil, 0)
    }
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:&errorL];
    if (JSONObject) {
        ReturnSupportedFile(WDKPlistViewController_FileTypeJSON, JSONObject, nil, 0)
    }
    
    NSPropertyListFormat format;
    
    id plistObject = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:&format error:&errorL];
    if (plistObject) {
        if ([plistObject isKindOfClass:[NSString class]]) {
            NSString *JSONString = (NSString *)plistObject;
            NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
            if (JSONData) {
                id JSONObject2 = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:&errorL];
                if (JSONObject2) {
                    ReturnSupportedFile(WDKPlistViewController_FileTypeJSONString, JSONObject2, nil, 0)
                }
            }
        }
        else {
            ReturnSupportedFile(WDKPlistViewController_FileTypePlist, plistObject, nil, format)
        }
    }
    
    NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([JSONString isKindOfClass:[NSString class]]) {
        NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONData) {
            id JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
            if (JSONObject) {
                ReturnSupportedFile(WDKPlistViewController_FileTypeJSONString, JSONObject, nil, 0)
            }
        }
    }
    
    ReturnNotSupportedFile(errorL, 0)
}

- (instancetype)initWithCurrentObject:(id)currentObject {
    self = [super init];
    if (self) {
        if ([currentObject isKindOfClass:[NSDictionary class]] || [currentObject isKindOfClass:[NSArray class]]) {
            _currentObj = currentObject;
        }
        else {
            NSError *error = [NSError errorWithDomain:@"WDKPlistViewController" code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"当前对象不是NSDictionary或者NSArray"}];
            
            self.errorOfReadingFile = error;
        }
    }
    return self;
}

- (void)setup {
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
    
    NSDictionary *attrs = @{
                            NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0f],
                            NSForegroundColorAttributeName: [UIColor darkTextColor],
                            //                            NSParagraphStyleAttributeName: paragraphStyle
                            };
    
    NSString *filePath = [[[self class] fileInfoDict] objectForKey:kFilePath];
    self.title = [filePath lastPathComponent];
    
    if ([[[self.class fileInfoDict] objectForKey:kFileReadonly] boolValue]) {
        self.title = [self.title stringByAppendingString:@" (只读)"];
    }
    
    self.navigationController.navigationBar.titleTextAttributes = attrs;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = self.actionsItem;
}

- (void)gotoPlistEditViewControllerWithIndex:(NSIndexPath *)indexPath {
    NSString *key = [self keyStringWithIndexPath:indexPath];
    id valueObject = [self valueObjectWithIndexPath:indexPath];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:key style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.currentPathComponents];
    [arrM addObject:key];
    NSString *keyPath = [arrM componentsJoinedByString:@"."];
    
    __weak typeof(self) weak_self = self;
    WCPlistEditViewController *vc = [[WCPlistEditViewController alloc] initWithObject:valueObject keyPath:keyPath completion:^(NSDictionary *changeInfo, BOOL isChanged) {
        if (isChanged) {
            
            NSString *keyForCheck = changeInfo[kChangeInfoNewKey];
            if (keyForCheck && [self.currentObj isKindOfClass:[NSDictionary class]]) {
                NSArray *allKeys = [self.currentObj allKeys];
                if ([allKeys containsObject:keyForCheck]) {
                    
                    NSString *title = [NSString stringWithFormat:@"`%@`键已存在", keyForCheck];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"是否重新输入" cancelButtonTitle:@"重试" otherButtonTitles:@"取消", nil];
                    [alert setHandler:^(UIAlertView *alert, NSInteger buttonIndex) {
                        [weak_self gotoPlistEditViewControllerWithIndex:indexPath];
                    } forButtonAtIndex:0];
                    
                    [alert show];
                    
                    return ;
                }
            }
            
            [self mutateValueObjectWithIndexPath:indexPath newObject:changeInfo[kChangeInfoNewValue]];
            [self mutateValueObjectWithIndexPath:indexPath newKey:changeInfo[kChangeInfoNewKey]];
            
            [self syncToFile];
        }
    }];
    vc.title = self.title;
    vc.mode = [[[self.class fileInfoDict] objectForKey:kFileReadonly] boolValue] ? WCPlistEditViewControllerModeReadonly : WCPlistEditViewControllerModeEdit;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Utility

+ (NSMutableDictionary *)fileInfoDict {
    static NSMutableDictionary *infoDict;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infoDict = [NSMutableDictionary dictionary];
    });
    
    return infoDict;
}

- (UIColor *)colorWithValueObject:(id)valueObject {
    if ([valueObject isKindOfClass:[NSDictionary class]]) {
        return [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    }
    else if ([valueObject isKindOfClass:[NSArray class]]) {
        return [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    }
    else if ([valueObject isKindOfClass:[NSDate class]]) {
        return [UIColor brownColor];
    }
    else if ([valueObject isKindOfClass:[NSData class]]) {
        return [UIColor blueColor];
    }
    else if ([valueObject isKindOfClass:[NSNumber class]]) {
        
        NSString *className = NSStringFromClass([valueObject class]);
        if ([className isEqualToString:@"__NSCFBoolean"]) {
            // bools
            return [UIColor magentaColor];
        }
        else {
            // numbers
            return [UIColor purpleColor];
        }
    }
    else if ([valueObject isKindOfClass:[NSString class]]) {
        return [UIColor orangeColor];
    }
    else {
        return [UIColor redColor];
    }
}

- (NSString *)stringForValueObject:(id)valueObject {
    if ([valueObject isKindOfClass:[NSDictionary class]]) {
        NSUInteger count = [(NSDictionary *)valueObject count];
        return [NSString stringWithFormat:@"(%ld %@)", (long)count, count == 1 ? @"pair" : @"pairs"];
    }
    else if ([valueObject isKindOfClass:[NSArray class]]) {
        NSUInteger count = [(NSArray *)valueObject count];
        return [NSString stringWithFormat:@"(%ld %@)", (long)count, count == 1 ? @"item" : @"items"];
    }
    else if ([valueObject isKindOfClass:[NSDate class]]) {
        return [(NSDate *)valueObject descriptionWithLocale:[NSLocale currentLocale]];
    }
    else if ([valueObject isKindOfClass:[NSData class]]) {
        return [NSString stringWithFormat:@"%@", valueObject];
    }
    else if ([valueObject isKindOfClass:[NSNumber class]]) {
        
        NSString *className = NSStringFromClass([valueObject class]);
        if ([className isEqualToString:@"__NSCFBoolean"]) {
            // bools
            return [NSString stringWithFormat:@"%@", [valueObject boolValue] ? @"YES" : @"NO"];
        }
        else {
            // numbers
            return [NSString stringWithFormat:@"%@", valueObject];
        }
    }
    else if ([valueObject isKindOfClass:[NSString class]]) {
        return valueObject;
    }
    else {
        return @"(unknow)";
    }
}

- (UITableViewCellAccessoryType)cellAccessoryTypeForValueObject:(id)valueObject {
    if ([valueObject isKindOfClass:[NSDictionary class]] ||
        [valueObject isKindOfClass:[NSArray class]]) {
        return UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        return UITableViewCellAccessoryNone;
    }
}

- (void)syncToFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id rootObject = [[self.class fileInfoDict] objectForKey:kRootObject];
        WDKPlistViewController_FileType fileType = [[[self.class fileInfoDict] objectForKey:kFileType] integerValue];
        NSString *filePath = [[self.class fileInfoDict] objectForKey:kFilePath];
        switch (fileType) {
            case WDKPlistViewController_FileTypePlist: {
                if ([rootObject isKindOfClass:[NSDictionary class]] || [rootObject isKindOfClass:[NSArray class]]) {
                    [rootObject writeToFile:filePath atomically:YES];
                }
                break;
            }
            case WDKPlistViewController_FileTypeJSON: {
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:rootObject options:kNilOptions error:&error];
                NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (JSONString) {
                    NSError *error = nil;
                    [JSONString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[[UIAlertView alloc] initWithTitle:@"保存出错" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                        });
                    }
                }
                break;
            }
            case WDKPlistViewController_FileTypeJSONString: {
                NSError *error;
                NSData *data = [NSJSONSerialization dataWithJSONObject:rootObject options:kNilOptions error:&error];
                NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (JSONString) {
                    
                    NSDictionary *container = @{@"key": JSONString};
                    NSError *error = nil;
                    
                    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:container options:kNilOptions error:&error];
                    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
                    NSMutableString *JSONStringM = [NSMutableString stringWithString:JSONString];
                    
                    [JSONStringM deleteCharactersInRange:NSMakeRange(JSONString.length - 1, @"}".length)];
                    [JSONStringM deleteCharactersInRange:NSMakeRange(0, @"{\"key\":".length)];
                    
                    if (!error) {
                        [JSONStringM writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    }
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[[UIAlertView alloc] initWithTitle:@"保存出错" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                        });
                    }
                }
                break;
            }
            default:
                break;
        }
    });
}

#pragma mark > from indexPath

- (id)valueObjectWithIndexPath:(NSIndexPath *)indexPath {
    
    id valueObject = nil;
    if ([self.currentObj isKindOfClass:[NSDictionary class]]) {
        NSArray *sortedKeys = [[(NSDictionary *)self.currentObj allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        valueObject = [(NSDictionary *)self.currentObj objectForKey:sortedKeys[indexPath.row]];
    }
    else if ([self.currentObj isKindOfClass:[NSArray class]]) {
        valueObject = [(NSArray *)self.currentObj objectAtIndex:indexPath.row];
    }
    
    return valueObject;
}

- (NSString *)keyStringWithIndexPath:(NSIndexPath *)indexPath {
    NSString *key = @"";
    if ([self.currentObj isKindOfClass:[NSDictionary class]]) {
        NSArray *sortedKeys = [[(NSDictionary *)self.currentObj allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        key = sortedKeys[indexPath.row];
    }
    else if ([self.currentObj isKindOfClass:[NSArray class]]) {
        key = [NSString stringWithFormat:@"[%ld]", indexPath.row];
    }
    
    return key;
}

- (void)mutateValueObjectWithIndexPath:(NSIndexPath *)indexPath newObject:(id)newObject {
    
    if (!newObject) {
        return;
    }
    
    if ([self.currentObj isKindOfClass:[NSDictionary class]]) {
        NSArray *sortedKeys = [[(NSMutableDictionary *)self.currentObj allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSString *key = sortedKeys[indexPath.row];
        
        NSMutableDictionary *dictM = (NSMutableDictionary *)self.currentObj;
        dictM[key] = newObject;
        
        [self.tableView reloadData];
    }
    else if ([self.currentObj isKindOfClass:[NSArray class]]) {
        NSMutableArray *arrM = (NSMutableArray *)self.currentObj;
        arrM[indexPath.row] = newObject;

        [self.tableView reloadData];
    }
}

- (void)mutateValueObjectWithIndexPath:(NSIndexPath *)indexPath newKey:(NSString *)newKey {
    
    if (!newKey) {
        return;
    }
    
    if ([self.currentObj isKindOfClass:[NSDictionary class]]) {
        NSArray *sortedKeys = [[(NSMutableDictionary *)self.currentObj allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSString *key = sortedKeys[indexPath.row];
        
        NSMutableDictionary *dictM = (NSMutableDictionary *)self.currentObj;
        dictM[newKey] = dictM[key];
        [dictM removeObjectForKey:key];
        
        [self.tableView reloadData];
    }
}

- (void)deleteKeyValueWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.currentObj isKindOfClass:[NSDictionary class]]) {
        NSArray *sortedKeys = [[(NSMutableDictionary *)self.currentObj allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSString *key = sortedKeys[indexPath.row];
        
        NSMutableDictionary *dictM = (NSMutableDictionary *)self.currentObj;
        [dictM removeObjectForKey:key];
    }
    else if ([self.currentObj isKindOfClass:[NSArray class]]) {
        NSMutableArray *arrM = (NSMutableArray *)self.currentObj;
        [arrM removeObjectAtIndex:indexPath.row];
    }
}

#pragma mark > Attrs

- (NSDictionary *)attrsOfCurrentPath {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 18.0f;
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:14.0f];
    attrs[NSParagraphStyleAttributeName] = paragraphStyle;
    
    return attrs;
}

- (NSDictionary *)attrsOfLink {
    return @{ NSUnderlineStyleAttributeName:@(YES), NSForegroundColorAttributeName: [UIColor blueColor] };
}

#pragma mark - Getters

- (UIBarButtonItem *)actionsItem {
    if (!_actionsItem) {
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionsItemClicked:)];
        
        _actionsItem = barItem;
    }
    
    return _actionsItem;
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_H + NAV_BAR_H, screenSize.width, screenSize.height - STATUS_BAR_H - NAV_BAR_H) style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        _tableView = tableView;
    }
    
    return _tableView;
}

#pragma mark - Actions

- (void)actionsItemClicked:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"常用操作", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"添加节点", nil) style:UIAlertActionStyleDefault handler:nil]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"导出文件", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *filePath = [[[self class] fileInfoDict] objectForKey:kFilePath];
        
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.documentController.UTI = @"public.data";
        [self.documentController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"以文本内容显示", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *filePath = [[[self class] fileInfoDict] objectForKey:kFilePath];
        
        WDKTextEditViewController *vc = [[WDKTextEditViewController alloc] initWithFilePath:filePath];
        [self.navigationController pushViewController:vc animated:YES];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numOfRows = 0;
    if ([self.currentObj isKindOfClass:[NSDictionary class]]
        || [self.currentObj isKindOfClass:[NSArray class]]) {
        numOfRows = [self.currentObj count];
    }
    
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sCellIdentifier = @"Cell";
    
    WDKContextMenuCell *cell = (WDKContextMenuCell *)[tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (cell == nil) {
        cell = [[WDKContextMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }
    
    cell.textLabel.text = [self keyStringWithIndexPath:indexPath];
    
    id valueObject = [self valueObjectWithIndexPath:indexPath];
    cell.detailTextLabel.text = [self stringForValueObject:valueObject];
    cell.detailTextLabel.textColor = [self colorWithValueObject:valueObject];
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.accessoryType = [self cellAccessoryTypeForValueObject:valueObject];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteKeyValueWithIndexPath:indexPath];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self syncToFile];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[self.class fileInfoDict] objectForKey:kFileReadonly] boolValue]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate

#define WDKPlistViewController_HeaderViewPadding 15.0f

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat paddingT = WDKPlistViewController_HeaderViewPadding;
    CGFloat paddingL = WDKPlistViewController_HeaderViewPadding;
    
    CGFloat width = ([[UIScreen mainScreen] bounds].size.width - 2 * WDKPlistViewController_HeaderViewPadding);
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(paddingL, paddingT, width, 0)];
    textView.delegate = self;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:15.0f] };
    
    for (NSUInteger i = 0; i < self.currentPathComponents.count; i++) {
        NSString *plainString = self.currentPathComponents[i];
        NSString *url = [NSString stringWithFormat:@"index://%@", @(i)];
        
        NSMutableAttributedString *part = [[NSMutableAttributedString alloc] initWithString:plainString attributes:attrs];
        [part addAttribute:NSLinkAttributeName value:url range:NSMakeRange(0, part.length)];
        
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"/" attributes:attrs]];
        [attrString appendAttributedString:part];
    }
    
    textView.attributedText = attrString;
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, width), newSize.height);
    textView.frame = newFrame;
        
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, CGRectGetHeight(textView.bounds) + 2 * WDKPlistViewController_HeaderViewPadding)];
    [view addSubview:textView];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *headerView = [self tableView:tableView viewForHeaderInSection:section];
    
    return CGRectGetHeight(headerView.bounds);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id valueObject = [self valueObjectWithIndexPath:indexPath];
    if ([valueObject isKindOfClass:[NSDictionary class]] || [valueObject isKindOfClass:[NSArray class]]) {
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        WDKPlistViewController *vc = [[WDKPlistViewController alloc] initWithCurrentObject:valueObject];
        NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.currentPathComponents];
        [arrM addObject:[self keyStringWithIndexPath:indexPath]];
        vc.currentPathComponents = arrM;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [self gotoPlistEditViewControllerWithIndex:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    // http://stackoverflow.com/a/34014655/4794665
    if ([[URL scheme] isEqualToString:@"index"]) {
        NSInteger offsetIndex = [self.currentPathComponents count] - 1 - [[URL host] integerValue];
        
        NSInteger currentIndex = [self.navigationController.viewControllers indexOfObject:self];
        
        UIViewController *toViewController = self.navigationController.viewControllers[currentIndex - offsetIndex];
        [self.navigationController popToViewController:toViewController animated:YES];
        
        return NO;
    }
    return NO;
}

@end
