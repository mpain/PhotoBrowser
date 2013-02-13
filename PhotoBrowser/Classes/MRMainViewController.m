#import <CoreGraphics/CoreGraphics.h>
#import "MRMainViewController.h"
#import "MRPhotoBrowser.h"
#import "MKNetworkEngine.h"
#import "MRImageHolder.h"
#import "MRPhotoBrowserPresenter.h"

static NSString *const kMRPhotoAlbumBaseUrl = @"http://content.foto.mail.ru/mail/kidnappersouls/1";

@interface MRMainViewController ()
@property (nonatomic, strong) MRPhotoBrowserPresenter *presenter;
@property (nonatomic, strong) MRPhotoBrowser *photoBrowser;
@end

@implementation MRMainViewController {
    __strong MKNetworkEngine *_engine;
    __strong UIImage *_image;
    __weak MRImageHolder *_holder;
    BOOL _initialized;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = NSLocalizedString(@"Photo browser host", @"");

    _engine = [MKNetworkEngine new];
    [_engine useCache];

    [self createHostImageView];
}

- (void)createHostImageView {
    CGRect frame = CGRectInset(self.view.bounds, 20, 0);
    frame.origin.y = 30;
    frame.size.height = 130;

    NSURL *url = [[NSURL alloc] initWithString:[kMRPhotoAlbumBaseUrl stringByAppendingPathComponent:@"i-1929.jpg"]];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    _image = [UIImage imageWithData:imageData];

    MRImageHolder *imageHolderView = [[MRImageHolder alloc] initWithFrame:frame];
    imageHolderView.image = _image;
    imageHolderView.userInteractionEnabled = YES;
    imageHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] init];
    recognizer.numberOfTapsRequired = 1;
    recognizer.numberOfTouchesRequired = 1;
    [recognizer addTarget:self action:@selector(didTapImageHolder:)];

    [imageHolderView addGestureRecognizer:recognizer];

    [self.view addSubview:imageHolderView];
    _holder = imageHolderView;
}

- (void)didTapImageHolder:(id)sender {
    NSLog(@"A touch is handling...");
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _presenter = [[MRPhotoBrowserPresenter alloc] initWithFrame:window.rootViewController.view.bounds];

    __weak MRMainViewController *myself = self;
    _presenter.block = ^() {
        //[presenter removeFromSuperview];
        //presenter = nil;

        [myself showPhotoBrowser];
        //[UIApplication sharedApplication].statusBarHidden = NO;
    };

    [window addSubview:_presenter];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [_presenter animateImage:_holder.image withFrame:[_holder convertRect:_holder.bounds toView:window.rootViewController.view] forView:window.rootViewController.view];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!_initialized) {
        _initialized = YES;
        //[self showPhotoBrowser];
    }
}

- (void)showPhotoBrowser {
    _photoBrowser = [MRPhotoBrowser new];
    NSArray *photos = @[
            [MRPhoto photoWithImage:_image],
            [self photoWithName:@"i-2392.jpg"],
            [self photoWithName:@"i-2393.jpg"],
            [self photoWithName:@"i-2394.jpg"],
            [self photoWithName:@"i-2406.jpg"],
            [self photoWithName:@"i-2407.jpg"],
            [self photoWithName:@"i-2422.jpg"]
    ];

    _photoBrowser.photos = photos;

    __weak MRMainViewController *myself = self;
    _photoBrowser.block = ^(MRPhotoBrowser *browser) {
        [myself hidePhotoBrowser];
    };

    [self presentViewController:_photoBrowser animated:NO completion:^() {
        NSLog(@"A photo gallery is presented.");
        [myself.presenter setHidden:YES];
        //myself.presenter = nil;
    }];
}

- (void)hidePhotoBrowser {
    __weak MRMainViewController *myself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        myself.photoBrowser = nil;
        [myself.presenter dismissFromView:[UIApplication sharedApplication].delegate.window.rootViewController.view block:^{
            myself.presenter = nil;
        }];
    }];
}

- (void)cleanup {
    _photoBrowser = nil;
    _engine = nil;
}

- (void)viewDidUnload {
    [self cleanup];
    [self viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [self cleanup];
    [self didReceiveMemoryWarning];
}

- (MRPhoto *)photoWithName:(NSString *)name {
    return [MRPhoto photoWithUrl:[kMRPhotoAlbumBaseUrl stringByAppendingPathComponent:name] delegate:self];
}

- (MKNetworkEngine *)networkEngineForPhoto:(MRPhoto *)photo {
    return _engine;
}

@end