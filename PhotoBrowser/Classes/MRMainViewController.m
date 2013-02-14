#import "MRMainViewController.h"
#import "MKNetworkEngine.h"
#import "MRImageHolder.h"
#import "MRPhotoBrowserPresenter.h"

static NSString *const kMRPhotoAlbumBaseUrl = @"http://content.foto.mail.ru/mail/kidnappersouls/1";

@interface MRMainViewController ()
@property (nonatomic, strong) MRPhotoBrowserPresenter *presenter;
@property (nonatomic, weak) MRImageHolder *holder;
@end

@implementation MRMainViewController {
    __strong MKNetworkEngine *_engine;
    __strong UIImage *_image;
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

    NSURL *url = [[NSURL alloc] initWithString:[kMRPhotoAlbumBaseUrl stringByAppendingPathComponent:@"i-2393.jpg"]];
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

    _holder.hidden = YES;

    _presenter = [[MRPhotoBrowserPresenter alloc] initWithFrame:window.rootViewController.view.bounds];
    _presenter.startGalleryIndex = 2;
    _presenter.galleryPhotos = @[
        [self photoWithName:@"i-1929.jpg"],
        [self photoWithName:@"i-2392.jpg"],
        [MRPhoto photoWithImage:_image],
        [self photoWithName:@"i-2394.jpg"],
        [self photoWithName:@"i-2406.jpg"],
        [self photoWithName:@"i-2407.jpg"],
        [self photoWithName:@"i-2422.jpg"]
    ];

    __weak MRMainViewController *myself = self;
    _presenter.appearBlock = ^() {
        myself.holder.hidden = NO;
    };

    _presenter.dismissBlock = ^() {
        myself.presenter = nil;
    };
    [_presenter presentPhotoBrowserWithImage:_holder.image fromView:_holder constrainedToView:window.rootViewController.view];

}

- (void)cleanup {
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