#import "MRPhotoBrowser.h"
#import "MRZoomingScrollView.h"
#import "MKNetworkEngine.h"

#define kECPadding 10

#define kECPageTagBase   0xbeaf
#define ECPageIndex(page) ((page).tag - kECPageTagBase)


@implementation MRPhotoBrowser {
    __strong UIScrollView *_pagingScrollView;
    __strong NSArray *_photos;

    __strong NSMutableSet *_visiblePages;
    __strong NSMutableSet *_recycledPages;
    NSUInteger _currentPageIndex;
    NSUInteger _pageIndexBeforeRotation;

    __strong MKNetworkEngine *_networkEngine;
}

- (id)init {
    self = [super init];
    if (self) {
        _visiblePages = [NSMutableSet new];
        _recycledPages = [NSMutableSet new];
    }
    return self;
}

- (void)viewDidLoad {
    [self createPagingScrollView];
    [super viewDidLoad];

    _networkEngine = [MKNetworkEngine new];
    [_networkEngine useCache];
}

- (void)viewDidUnload {
    [self cleanup];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [self cleanup];
    [super didReceiveMemoryWarning];
}

- (void)cleanup {
    _networkEngine = nil;
}
- (void)createPagingScrollView {
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:self.pagingScrollViewFrame];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.backgroundColor = UIColor.blackColor;
    _pagingScrollView.contentSize = self.pagingScrollViewContentSize;
    [self.view addSubview:_pagingScrollView];
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

	// Flag
	_performingLayout = YES;

	// Toolbar
	_toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];

	NSUInteger indexPriorToLayout = _currentPageIndex;

	_pagingScrollView.frame = self.pagingScrollViewFrame;
	_pagingScrollView.contentSize = self.pagingScrollViewContentSize;

	for (MRZoomingScrollView *page in _visiblePages) {
        NSInteger index = ECPageIndex(page);
		page.frame = [self frameForPageAtIndex:index];
        page.captionView.frame = [self frameForCaptionView:page.captionView atIndex:index];
		[page setMaxMinZoomScalesForCurrentBounds];
	}

	// Adjust contentOffset to preserve page location based on values collected prior to location
	_pagingScrollView.contentOffset = [self pagingScrollViewContentOffsetForPageAtIndex:indexPriorToLayout];
	[self didStartViewingPageAtIndex:_currentPageIndex]; // initial

	// Reset
	_currentPageIndex = indexPriorToLayout;
	_performingLayout = NO;

}

- (void)updatePagesVisibility {
	CGRect bounds = _pagingScrollView.bounds;
	NSInteger first = (NSInteger)floorf((CGRectGetMinX(bounds) + kECPadding * 2) / CGRectGetWidth(bounds));
    first = MIN(MAX(first, 0), _photos.count - 1);

    NSInteger last = (NSInteger)floorf((CGRectGetMaxX(bounds) - kECPadding * 2 - 1) / CGRectGetWidth(bounds));
    last = MIN(MAX(last, 0), _photos.count - 1);

    for (MRZoomingScrollView *page in _visiblePages) {
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
            MRZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[MRZoomingScrollView alloc] initWithPhotoBrowser:self];
			}
			[self configurePage:page forIndex:index];
			[_visiblePages addObject:page];
			[_pagingScrollView addSubview:page];
		}
	}

}

- (void)configurePage:(MRZoomingScrollView *)page forIndex:(NSInteger)index {
	page.frame = [self frameForPageAtIndex:index];
    page.tag = kECPageTagBase + index;
    page.photo = [self photoAtIndex:index];
}

- (MRZoomingScrollView *)dequeueRecycledPage {
    MRZoomingScrollView *page = [_recycledPages anyObject];
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
@end