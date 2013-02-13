#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MRPhotoBrowserPresenter.h"
#import "MRImageHolder.h"

@interface MRPhotoBrowserPresenter ()
@property (nonatomic, strong) MRImageHolder *imageHolder;
@end

@implementation MRPhotoBrowserPresenter {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupControl];
    }
    return self;
}

- (void)setupControl {
    self.backgroundColor = UIColor.clearColor;
    self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)animateForView:(UIView *)mainView {
    __weak MRPhotoBrowserPresenter *myself = self;


    [UIView animateWithDuration:0.3 animations:^{
        mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        mainView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            mainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            mainView.alpha = 1.0;
        } completion:^(BOOL finished1) {

            if (myself.block) {
                myself.block();
            }
        }];
    }];
}

- (void)animateImage:(UIImage *)image withFrame:(CGRect)frame forView:(UIView *)mainView {

    _imageHolder = [[MRImageHolder alloc] initWithFrame:frame];
    _imageHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _imageHolder.image = image;
    [self addSubview:_imageHolder];

    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];

    __weak MRPhotoBrowserPresenter *myself = self;

    [UIView animateWithDuration:2.0 animations:^{
        mainView.transform = CGAffineTransformScale(mainView.transform, 0.9, 0.9);
        mainView.alpha = 0.0;

        CGRect holderFrame = myself.imageHolder.frame;
        CGSize size = myself.size;

        holderFrame.origin.x = 0;
        holderFrame.origin.y = (size.height - holderFrame.size.height) / 2 - [UIApplication sharedApplication].statusBarFrame.size.height;
        holderFrame.size.width = size.width;
        myself.imageHolder.frame = holderFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.0 animations:^{
            CGRect holderFrame = myself.imageHolder.frame;
            holderFrame.size.height = myself.imageHolder.imageHolder.bounds.size.height;
            holderFrame.origin.y = (myself.size.height - holderFrame.size.height) / 2 - [UIApplication sharedApplication].statusBarFrame.size.height;
            myself.imageHolder.frame = holderFrame;
        } completion:^(BOOL finished1) {
            if (myself.block) {
                myself.block();
            }
        }];
    }];
}

- (CGSize)size {
    CGSize size = self.frame.size;
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        [_imageHolder removeFromSuperview];
        _imageHolder = nil;
    }
}

- (void)dismissFromView:(UIView *)mainView block:(void (^)())completionBlock {
    [UIView animateWithDuration:0.3 animations:^{
        mainView.transform = CGAffineTransformScale(mainView.transform, 1.0, 1.0);
        mainView.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {
    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle = UIInterfaceOrientationAngleOfOrientation(statusBarOrientation);
    CGFloat statusBarHeight = [[self class] getStatusBarHeight];

    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGRect frame = [[self class] rectInWindowBounds:self.window.bounds statusBarOrientation:statusBarOrientation statusBarHeight:statusBarHeight];

    [self setIfNotEqualTransform:transform frame:frame];
}

- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame {
    if (!CGAffineTransformEqualToTransform(self.transform, transform)) {
        self.transform = transform;
    }

    if(!CGRectEqualToRect(self.frame, frame)) {
        self.frame = frame;
    }
}

+ (CGFloat)getStatusBarHeight {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return [UIApplication sharedApplication].statusBarFrame.size.width;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

+ (CGRect)rectInWindowBounds:(CGRect)windowBounds statusBarOrientation:(UIInterfaceOrientation)statusBarOrientation statusBarHeight:(CGFloat)statusBarHeight {
    CGRect frame = windowBounds;
    frame.origin.x += statusBarOrientation == UIInterfaceOrientationLandscapeLeft ? statusBarHeight : 0;
    frame.origin.y += statusBarOrientation == UIInterfaceOrientationPortrait ? statusBarHeight : 0;
    frame.size.width -= UIInterfaceOrientationIsLandscape(statusBarOrientation) ? statusBarHeight : 0;
    frame.size.height -= UIInterfaceOrientationIsPortrait(statusBarOrientation) ? statusBarHeight : 0;
    return frame;
}

CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
    CGFloat angle;

    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }

    return angle;
}

UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation) {
    return 1 << orientation;
}
@end