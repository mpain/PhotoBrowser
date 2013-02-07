#import "MRZoomingScrollView.h"


@implementation MRZoomingScrollView {
    __strong MRTapImageView *_tapView;
    __strong MRTapImageView *_imageTapView;

    __strong UIActivityIndicatorView *_spinner;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupControl];
    }
    return self;
}

- (void)setupControl {
    _tapView = [[MRTapImageView alloc] initWithFrame:self.bounds];
    _tapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tapView.userInputDelegate = self;
    _tapView.backgroundColor = UIColor.clearColor;
    [self addSubview:_tapView];

    _imageTapView = [[MRTapImageView alloc] initWithFrame:CGRectZero];
    _imageTapView.userInputDelegate = self;
    _imageTapView.backgroundColor = UIColor.clearColor;
    _imageTapView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageTapView];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.hidesWhenStopped = YES;
    _spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_spinner];

    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)layoutSubviews {
	_tapView.frame = self.bounds;

	if (!_spinner.hidden) {
        _spinner.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }

	[super layoutSubviews];

    CGSize size = self.bounds.size;
    CGRect photoFrame = _imageTapView.frame;

    photoFrame.origin.x = (photoFrame.size.width < size.width) ? floorf((size.width - photoFrame.size.width) / 2.0) : 0;
    photoFrame.origin.y = (photoFrame.size.height < size.height) ? floorf((size.height - photoFrame.size.height) / 2.0) : 0;

	if (!CGRectEqualToRect(_imageTapView.frame, photoFrame)) {
        _imageTapView.frame = photoFrame;
    }

}

- (void)prepareForReuse {
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageTapView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_photoBrowser hideControlsAfterDelay];
}

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:view];

    [NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];

    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }

    [_photoBrowser hideControlsAfterDelay];
}


@end