#import "MRMainViewController.h"
#import "MRPhotoBrowser.h"
#import "MKNetworkEngine.h"

static NSString *const kMRPhotoAlbumBaseUrl = @"http://content.foto.mail.ru/mail/kidnappersouls/1";

@implementation MRMainViewController {
    __strong MRPhotoBrowser *_photoBrowser;
    __strong MKNetworkEngine *_engine;

    BOOL _initialized;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _engine = [MKNetworkEngine new];
    [_engine useCache];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!_initialized) {
        _initialized = YES;
        _photoBrowser = [MRPhotoBrowser new];
        NSArray *photos = @[
            [self photoWithName:@"i-1929.jpg"],
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

        [self presentViewController:_photoBrowser animated:YES completion:^() {
            NSLog(@"A photo gallery is presented.");
        }];
    }
}

- (void)hidePhotoBrowser {
    __weak MRMainViewController *myself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [myself cleanup];
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