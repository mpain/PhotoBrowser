#import "MRPhotoZoomingScrollView.h"
#import "MRPhoto.h"

@interface MRPhotoZoomingScrollView ()

@property (nonatomic, strong) MRPhoto *photo;
@property (nonatomic, weak) UIActivityIndicatorView *spinner;
@property (nonatomic, weak) MRTapImageView *tapView;
@property (nonatomic, weak) MRTapImageView *photoView;

@end

@implementation MRPhotoZoomingScrollView {

}

- (id)init {
    self = [super init];
    if (self) {
        [self setupControl];
    }
    return self;
}

- (void)setupControl {
    MRTapImageView *tapView = [[MRTapImageView alloc] initWithFrame:self.bounds];
    tapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tapView.userInputDelegate = self;
    tapView.backgroundColor = UIColor.clearColor;
    [self addSubview:tapView];
    _tapView = tapView;

    MRTapImageView *photoView = [[MRTapImageView alloc] initWithFrame:CGRectZero];
    photoView.userInputDelegate = self;
    photoView.backgroundColor = UIColor.clearColor;
    photoView.contentMode = UIViewContentModeCenter;
    [self addSubview:photoView];
    _photoView = photoView;

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.hidesWhenStopped = YES;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:spinner];
    _spinner = spinner;

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
    CGRect photoFrame = _photoView.frame;

    photoFrame.origin.x = (photoFrame.size.width < size.width) ? floorf((size.width - photoFrame.size.width) / 2.0) : 0;
    photoFrame.origin.y = (photoFrame.size.height < size.height) ? floorf((size.height - photoFrame.size.height) / 2.0) : 0;

	if (!CGRectEqualToRect(_photoView.frame, photoFrame)) {
        _photoView.frame = photoFrame;
    }

}

- (void)setPhoto:(MRPhoto *)photo {
    _photoView.image = nil;
    if (_photo != photo) {
        _photo = photo;
    }
    [self displayImage];
}

- (void)displayImage {
	if (!_photo || _photoView.image) {
        return;
    }

    self.contentSize = CGSizeMake(0, 0);

    if (!self.photo.image) {
        [self.spinner startAnimating];
    }

    __weak MRPhotoZoomingScrollView *myself = self;
    [self.photo loadImageWithBlock:^(BOOL isSuccess) {
        [myself.spinner stopAnimating];
        myself.photoView.image = myself.photo.image;

        CGRect frame = (CGRect) {
            .size = myself.photo.image.size
        };

        myself.photoView.frame = frame;
        myself.contentSize = frame.size;

        [myself setupZoomScales];
    }];

    [self setNeedsLayout];
}

- (void)setupZoomScales {
	self.maximumZoomScale = 1.0;
	self.minimumZoomScale = 1.0;
	self.zoomScale = 1.0;

	if (!_photoView.image) {
        return;
    }

    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoView.frame.size;

    CGFloat scaleX = boundsSize.width / imageSize.width;
    CGFloat scaleY = boundsSize.height / imageSize.height;
    CGFloat scaleMin = MIN(scaleX, scaleY);

	if (scaleX > 1 && scaleY > 1) {
		scaleMin = 1.0;
	}

	CGFloat scaleMax = 2.0;

	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		scaleMax = scaleMax / UIScreen.mainScreen.scale;
	}

	self.maximumZoomScale = scaleMax;
	self.minimumZoomScale = scaleMin;
	self.zoomScale = scaleMin;

	_photoView.frame = (CGRect) {
        .size = _photoView.frame.size
    };
	[self setNeedsLayout];

}

- (void)prepareForReuse {
    _photo = nil;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoView;
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