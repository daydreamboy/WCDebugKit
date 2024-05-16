//
//  WDKImageBrowserViewController.m
//  Pods
//
//  Created by wesley chen on 17/1/6.
//
//

#import "WDKImageBrowserViewController.h"
#import "WDKImageZoomView.h"

@interface WDKImageBrowserViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableSet *recycledPages;
@property (nonatomic, strong) NSMutableSet *visiblePages;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSUInteger firstShowedIndex;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, strong) UIScrollView *pagingScrollView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@end

@implementation WDKImageBrowserViewController

- (instancetype)initWithImages:(NSArray<UIImage *> *)images index:(NSUInteger)index {
    self = [super init];
    if (self) {
        _images = images;
        _firstShowedIndex = index;
        
        [self setup];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pagingScrollViewSingleTapped:)];
    singleTap.numberOfTapsRequired = 1;
    self.singleTap = singleTap;
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * [self imageCount], pagingScrollViewFrame.size.height);
    scrollView.delegate = self;
    [scrollView addGestureRecognizer:singleTap];
    [self.view addSubview:scrollView];
    self.pagingScrollView = scrollView;
 
    [self scrollToPage:_firstShowedIndex animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark

- (void)setup {
    _recycledPages = [NSMutableSet set];
    _visiblePages = [NSMutableSet set];
    _currentIndex = _firstShowedIndex;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.title = [NSString stringWithFormat:@"%ld / %ld", (long)(_currentIndex + 1), (long)_images.count];
}

- (NSUInteger)imageCount {
    return [self.images count];
}

- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated {
    
    NSAssert(page >= 0 && page < [self imageCount], @"page %lu out of bounds[0...%lu]", (unsigned long)page, (unsigned long)[self imageCount]);
    
    if (page) {
        CGRect rect = CGRectMake(page * CGRectGetWidth(self.pagingScrollView.bounds), 0, CGRectGetWidth(self.pagingScrollView.bounds), CGRectGetHeight(self.pagingScrollView.bounds));
        [self.pagingScrollView scrollRectToVisible:rect animated:animated];
    }
    else {
        [self tilePages];
    }
}

- (void)tilePages {
    CGRect visibleBounds = self.pagingScrollView.bounds;
    
    NSInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSInteger lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds));
    
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    for (WDKImageZoomView *page in self.visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [self.recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [self.visiblePages minusSet:self.recycledPages];
    
    for (NSUInteger index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            WDKImageZoomView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[WDKImageZoomView alloc] init];
            }
            // configure page's frame and image
            [self configurePage:page forIndex:index];
            [self.pagingScrollView addSubview:page];
            [self.visiblePages addObject:page];
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (WDKImageZoomView *page in self.visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (WDKImageZoomView *)dequeueRecycledPage {
    WDKImageZoomView *page = [self.recycledPages anyObject];
    if (page) {
        [self.recycledPages removeObject:page];
    }
    return page;
}

- (void)configurePage:(WDKImageZoomView *)page forIndex:(NSUInteger)index {
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    
    [page displayImage:self.images[index]];
    [self.singleTap requireGestureRecognizerToFail:page.doubleTapGesture];
}

- (NSUInteger)currentPageIndexWithScrollView:(UIScrollView *)scrollView {
    CGFloat pagingScrollViewWidth = scrollView.frame.size.width;
    NSUInteger index = floor((scrollView.contentOffset.x - pagingScrollViewWidth / 2.0) / pagingScrollViewWidth) + 1;
    
    index = MAX(index, 0);
    index = MIN(index, [self imageCount] - 1);
    
    return index;
}

#pragma mark - Frame Calculation

#define PADDING  10

- (CGRect)frameForPagingScrollView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}
                  
- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    CGRect pageFrame = pagingScrollViewFrame;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = pagingScrollViewFrame.size.width * index + PADDING;
    
    return pageFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
    
    NSUInteger pageIndex = [self currentPageIndexWithScrollView:self.pagingScrollView];
    _currentIndex = pageIndex;
    self.title = [NSString stringWithFormat:@"%ld / %ld", (long)(_currentIndex + 1), (long)_images.count];
}

#pragma mark - Actions

- (void)pagingScrollViewSingleTapped:(UITapGestureRecognizer *)recognizer {
    if (!self.navigationController.navigationBar.hidden) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.navigationController.navigationBar.alpha = 0;
            self.view.backgroundColor = [UIColor blackColor];
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        } completion:^(BOOL finished) {
            self.navigationController.navigationBar.hidden = YES;
        }];
    }
    else {
        self.navigationController.navigationBar.alpha = 0;
        self.navigationController.navigationBar.hidden = NO;
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.navigationController.navigationBar.alpha = 1;
            self.view.backgroundColor = [UIColor whiteColor];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        } completion:nil];
    }
}

@end
