#import "MRPhotoBrowser.h"
#import "MRPhoto.h"
#import "MRPhotoPassThroughView.h"
#import "MRPhotoGrayButton.h"
#import "UIView+MRShadow.h"

#define kECButtonCloseSize CGSizeMake(90, 40)

#define kECPadding 10

#define kECPageTagBase   0xbeaf
#define ECPageIndex(page) ((page).tag - kECPageTagBase)
#define isECSystemVersionLessThan(version)  ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending)

@interface MRPhotoBrowser ()
@property (nonatomic, weak) MRPhotoPassThroughView *controlsView;
@end

@implementation MRPhotoBrowser {
    __strong UIScrollView *_pagingScrollView;

    __strong NSMutableSet *_visiblePages;
    __strong NSMutableSet *_recycledPages;

    NSUInteger _savedPageIndex;
    NSUInteger _currentPageIndex;

    BOOL _previousStatusBarHidden;

    BOOL _rotating;
}

- (id)init {
    self = [super init];
    if (self) {
        _visiblePages = [NSMutableSet new];
        _recycledPages = [NSMutableSet new];
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [self createPagingScrollView];
    [self createControlsView];
    [super viewDidLoad];

    _currentPageIndex = self.startPageIndex;
    [self reloadData];
}

- (void)viewDidUnload {
    [self cleanup];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [self cleanup];
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (isECSystemVersionLessThan(@"5")) {
        [self viewWillLayoutSubviews];
    }

    if (self.wantsFullScreenLayout) {
        _previousStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(hideControls) withObject:nil afterDelay:5.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if (self.wantsFullScreenLayout) {
        [[UIApplication sharedApplication] setStatusBarHidden:_previousStatusBarHidden withAnimation:UIStatusBarAnimationFade];
    }

	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	_savedPageIndex = _currentPageIndex;
    _rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _currentPageIndex = _savedPageIndex;

	if (isECSystemVersionLessThan(@"5")) {
        [self viewWillLayoutSubviews];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	_rotating = NO;
}

- (void)cleanup {

}

- (void)createControlsView {
    MRPhotoPassThroughView *controls = [[MRPhotoPassThroughView alloc] initWithFrame:self.view.bounds];
    controls.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    controls.backgroundColor = UIColor.clearColor;

    [self.view addSubview:controls];

    MRPhotoGrayButton *button = [[MRPhotoGrayButton alloc] initWithFrame:(CGRect) {
        .origin = CGPointMake(CGRectGetWidth(controls.bounds) - kECButtonCloseSize.width - kECPadding, kECPadding),
        .size = kECButtonCloseSize
    }];

    button.backgroundColor = [UIColor clearColor];
    [button setTitle:NSLocalizedString(@"Закрыть", nil) forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    [button.titleLabel setTextColor:UIColor.whiteColor];
    [button.titleLabel setHighlightedTextColor:UIColor.darkGrayColor];

    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [button.titleLabel dropShadowWithColor:UIColor.blackColor offset:CGSizeMake(0, -1) radius:1.0f opacity:0.8];
    [button addTarget:self action:@selector(didTouchCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [controls addSubview:button];


    UIView *toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(controls.bounds) - 44, CGRectGetWidth(controls.bounds), 44)];
    toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolbarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    [controls addSubview:toolbarView];
    _controlsView = controls;
}

- (void)createPagingScrollView {
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:self.pagingScrollViewFrame];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.backgroundColor = [UIColor colorWithWhite:(51.0 / 255.0) alpha:1.0];
    _pagingScrollView.contentSize = self.pagingScrollViewContentSize;
    [self.view addSubview:_pagingScrollView];
}

- (void)reloadData {
    [self relayout];

    if (isECSystemVersionLessThan(@"5")) {
        [self viewWillLayoutSubviews];
    } else {
        [self.view setNeedsLayout];
    }
}

- (CGRect)pagingScrollViewFrame {
    return CGRectInset(self.view.bounds, -kECPadding, 0);
}

- (CGSize)pagingScrollViewContentSize {
    CGRect frame = _pagingScrollView.bounds;
    return CGSizeMake(frame.size.width * _photos.count, frame.size.height);
}

- (CGPoint)pagingScrollViewContentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = _pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (void)relayout {
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];

    _pagingScrollView.contentOffset = [self pagingScrollViewContentOffsetForPageAtIndex:_currentPageIndex];
    [self updatePagesVisibility];
}

- (void)viewWillLayoutSubviews {
    if ([super respondsToSelector:@selector(viewWillLayoutSubviews)]) {
        [super viewWillLayoutSubviews];
    }

	NSUInteger indexPriorToLayout = _currentPageIndex;

	_pagingScrollView.frame = self.pagingScrollViewFrame;
	_pagingScrollView.contentSize = self.pagingScrollViewContentSize;

	for (MRPhotoZoomingScrollView *page in _visiblePages) {
        NSInteger index = ECPageIndex(page);
		page.frame = [self frameForPageAtIndex:index];
        [page setupZoomScales];
	}

	_pagingScrollView.contentOffset = [self pagingScrollViewContentOffsetForPageAtIndex:indexPriorToLayout];
	[self didStartViewingPageAtIndex:_currentPageIndex];

	_currentPageIndex = indexPriorToLayout;
}

- (void)updatePagesVisibility {
	CGRect bounds = _pagingScrollView.bounds;
	NSInteger current = (NSInteger)floorf((CGRectGetMinX(bounds) + kECPadding * 2) / CGRectGetWidth(bounds));
    current = MIN(MAX(current, 0), _photos.count - 1);

    NSInteger first = MIN(MAX(current - 1, 0), _photos.count - 1);
    NSInteger last = MIN(MAX(current + 1, 0), _photos.count - 1);

    for (MRPhotoZoomingScrollView *page in _visiblePages) {
        NSInteger pageIndex = ECPageIndex(page);
		if (pageIndex < first || pageIndex > last) {
			[_recycledPages addObject:page];
            [page prepareForReuse];
			[page removeFromSuperview];
		}
	}

	[_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) {
        [_recycledPages removeObject:[_recycledPages anyObject]];
    }

	for (NSInteger index = first; index <= last; index++) {
		if (![self isDisplayingPageForIndex:index]) {
            MRPhotoZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [MRPhotoZoomingScrollView new];
			}

            page.controlsDelegate = self;
            NSLog(@"Configuring a page at index: %d", index);
			[self configurePage:page forIndex:index];
			[_visiblePages addObject:page];
			[_pagingScrollView addSubview:page];
		}
	}

}


- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (MRPhotoZoomingScrollView *page in _visiblePages) {
		if (ECPageIndex(page) == index) {
            return YES;
        }
    }
	return NO;
}

- (void)configurePage:(MRPhotoZoomingScrollView *)page forIndex:(NSInteger)index {
	page.frame = [self frameForPageAtIndex:index];
    page.tag = kECPageTagBase + index;
    if (!page.photo.image) {
        page.photo = _photos[index];
    }
    [page setupZoomScales];
}

- (MRPhotoZoomingScrollView *)dequeueRecycledPage {
    MRPhotoZoomingScrollView *page = [_recycledPages anyObject];
	if (page) {
		[_recycledPages removeObject:page];
	}
	return page;
}

- (CGRect)frameForPageAtIndex:(NSInteger)index {
    CGRect bounds = _pagingScrollView.bounds;

    CGRect frame = bounds;
    frame.size.width -= (2 * kECPadding);
    frame.origin.x = (bounds.size.width * index) + kECPadding;
    return frame;
}

- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    if (index > 0) {
        for (NSUInteger i = 0; i < index - 1; i++) {
            [((MRPhoto *)_photos[i]) unloadImage];
        }
    }

    if (index < _photos.count - 1) {
        for (NSUInteger i = index + 2; i < _photos.count; i++) {
            [((MRPhoto *)_photos[i]) unloadImage];
        }
    }

    MRPhoto *current = _photos[index];
    if (current.image) {
        [self loadAdjacentPhotos:current];
    }
}

- (void)loadAdjacentPhotos:(MRPhoto *)photo {
    MRPhotoZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (!page) {
        return;
    }

    NSUInteger pageIndex = ECPageIndex(page);
    if (_currentPageIndex == pageIndex) {
        if (pageIndex > 0) {
            MRPhoto *previous = _photos[pageIndex - 1];
            if (!previous.image) {
                [self pageDisplayingPhoto:previous].photo = previous;
            }
        }

        if (pageIndex < _photos.count - 1) {
            MRPhoto *next = _photos[pageIndex + 1];
            if (!next.image) {
                [self pageDisplayingPhoto:next].photo = next;
            }
        }
    }

}

- (MRPhotoZoomingScrollView *)pageDisplayingPhoto:(MRPhoto *)photo {
    MRPhotoZoomingScrollView *found = nil;
	for (MRPhotoZoomingScrollView *page in _visiblePages) {
		if (page.photo == photo) {
            found = page;
            break;
		}
	}
	return found;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_rotating) {
        return;
    }

	[self updatePagesVisibility];

	CGRect visibleBounds = _pagingScrollView.bounds;

    int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    index = MIN(MAX(index, 0), _photos.count - 1);

    NSUInteger previous = _currentPageIndex;

	_currentPageIndex = index;

    if (_currentPageIndex != previous) {
        [self didStartViewingPageAtIndex:index];
    }

}

- (void)showControls:(NSNumber *)show {
    BOOL isShow = [show boolValue];

    __weak MRPhotoBrowser *myself = self;
    [UIView animateWithDuration:isShow ? 0.25 : 0.5 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut) animations:^{
        myself.controlsView.alpha = isShow ? 1.0 : 0.0;
    } completion: nil];
}

- (void)toggleControls {
    BOOL show = (self.controlsView.alpha == 0.0);
    [self performSelector:@selector(showControls:) withObject:@(show) afterDelay:0.2];
}

- (void)hideControls {
    BOOL isShown = (self.controlsView.alpha > 0.0);
    if (isShown) {
        [self performSelector:@selector(showControls:) withObject:@(NO) afterDelay:0.2];
    }
}

- (void)cancelControlsOperations {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didTouchCloseButton:(id)sender {
    if (self.block) {
        self.block(self);
    }
}
@end