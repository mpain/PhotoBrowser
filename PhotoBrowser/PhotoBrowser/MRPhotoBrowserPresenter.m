#import <CoreGraphics/CoreGraphics.h>
#import "MRPhotoBrowserPresenter.h"
#import "MRImageHolder.h"
#import "MRPhotoBrowser.h"

@interface MRPhotoBrowserPresenter ()

@property (nonatomic, strong) MRImageHolder *imageHolder;
@property (nonatomic, strong) MRPhotoBrowser *photoBrowser;
@property (nonatomic, weak) UIView *mainView;
@property (nonatomic, assign) BOOL savedStatusBarHiddenStatus;

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

- (void)presentPhotoBrowserWithImage:(UIImage *)image fromView:(UIView *)view constrainedToView:(UIView *)mainView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];

    CGRect frame = [view convertRect:view.bounds toView:mainView];

    _mainView = mainView;

    _imageHolder = [[MRImageHolder alloc] initWithFrame:frame];
    _imageHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_imageHolder];

    _imageHolder.image = image;

    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    [self moveImageHolder];



}

#pragma mark - Transitions

- (void)moveImageHolder {
    CGSize statusBarFrame = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = MIN(statusBarFrame.width, statusBarFrame.height);

    [self hideStatusBar];
    self.frame = [UIScreen mainScreen].applicationFrame;
    CGRect holderFrame = self.imageHolder.frame;
    holderFrame.origin.y += statusBarHeight;
    self.imageHolder.frame = holderFrame;

    __weak MRPhotoBrowserPresenter *myself = self;

    [UIView animateWithDuration:0.3 animations:^{
        myself.mainView.transform = CGAffineTransformScale(myself.mainView.transform, 0.9, 0.9);
        myself.mainView.alpha = 0.0;

        CGRect holderFrame = myself.imageHolder.frame;
        CGSize size = myself.actualSize;

        holderFrame.origin.x = 0;
        holderFrame.origin.y = (size.height - holderFrame.size.height) / 2;
        holderFrame.size.width = size.width;
        myself.imageHolder.frame = holderFrame;
        [myself.imageHolder relayout];
    } completion:^(BOOL finished) {
        [myself resizeImageHolder];
    }];
}

- (void)resizeImageHolder {
    __weak MRPhotoBrowserPresenter *myself = self;

    [UIView animateWithDuration:0.3 animations:^{
        CGRect holderFrame = myself.imageHolder.frame;
        holderFrame.size.height = myself.imageHolder.imageHolder.bounds.size.height;
        holderFrame.origin.y = (myself.actualSize.height - holderFrame.size.height) / 2;
        myself.imageHolder.frame = holderFrame;
        [myself.imageHolder relayout];
    } completion:^(BOOL finished1) {
        if (myself.appearBlock) {
            myself.appearBlock();
        }
        [myself showPhotoBrowser];
    }];
}

- (void)dismissFromView:(UIView *)mainView block:(void (^)())completionBlock {
    CGAffineTransform old = mainView.transform;

    mainView.transform = CGAffineTransformScale(old, 0.9, 0.9);
    [UIView animateWithDuration:0.3 animations:^{
        mainView.transform = old;
        mainView.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - StatusBar

- (void)hideStatusBar {
    self.savedStatusBarHiddenStatus = [UIApplication sharedApplication].isStatusBarHidden;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)restoreStatusBar {
    [UIApplication sharedApplication].statusBarHidden = self.savedStatusBarHiddenStatus;
    self.mainView.frame = [UIScreen mainScreen].applicationFrame;
}

#pragma mark - PhotoBrowser

- (UIViewController *)rootViewController {
    return UIApplication.sharedApplication.keyWindow.rootViewController;
}

- (void)showPhotoBrowser {
    _photoBrowser = [MRPhotoBrowser new];
    _photoBrowser.photos = self.galleryPhotos;
    _photoBrowser.startPageIndex = self.startGalleryIndex;

    __weak MRPhotoBrowserPresenter *myself = self;
    _photoBrowser.block = ^(MRPhotoBrowser *browser) {
        [myself hidePhotoBrowser];
    };

    UIViewController *rootViewController = self.rootViewController;
    [rootViewController presentViewController:_photoBrowser animated:NO completion:^() {
        NSLog(@"A photo gallery is presented.");
        myself.hidden = YES;

        [myself.imageHolder removeFromSuperview];
        myself.imageHolder = nil;
    }];
}

- (void)hidePhotoBrowser {
    __weak MRPhotoBrowserPresenter *myself = self;
    UIViewController *rootViewController = self.rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:^{
        myself.photoBrowser = nil;
        [myself restoreStatusBar];

        [myself dismissFromView:myself.mainView block:^{
            [myself removeFromSuperview];
            if (myself.dismissBlock) {
                myself.dismissBlock();
            }
        }];
    }];
}
#pragma mark - Orientation stuff

- (CGSize)actualSize {
    CGSize size = self.frame.size;
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {
    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle = [MRPhotoBrowserPresenter interfaceOrientationAngleOfOrientation:statusBarOrientation];
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

+ (CGFloat)interfaceOrientationAngleOfOrientation:(UIInterfaceOrientation)orientation {
    double angle;

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

    return (CGFloat)angle;
}
@end