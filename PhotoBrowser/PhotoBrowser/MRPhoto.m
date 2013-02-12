#import "MRPhoto.h"
#import "MKNetworkEngine.h"

@interface MRPhoto ()

@property (nonatomic, strong) MKNetworkOperation *operation;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *actualImage;
@end

@implementation MRPhoto {
    __strong NSString *_urlString;
    __weak id<MRPhotoDelegate> _delegate;
}

- (void)dealloc {
    [self cancelNetworkOperation];
}

+ (id)photoWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

+ (id)photoWithUrl:(NSString *)urlString delegate:(id<MRPhotoDelegate>)delegate {
    return [[self alloc] initWithUrl:urlString delegate:delegate];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (id)initWithUrl:(NSString *)urlString delegate:(id<MRPhotoDelegate>)delegate {
    self = [super init];
    if (self) {
        _urlString = [urlString copy];
        _delegate = delegate;
    }
    return self;
}

- (void)cancelNetworkOperation {
    if (self.operation) {
        [self.operation cancel];
        self.operation = nil;
    }
}

- (UIImage *)image {
    return _actualImage;
}

- (void)unloadImage {
    _actualImage = nil;
}

- (void)loadImageWithBlock:(MRPhotoResultBlock)block {
    if (_image) {
        _actualImage = _image;
        [self handleResult:YES block:block];
        return;
    }

    NSLog(@"Loading image at url: %@", _urlString);
    [self cancelNetworkOperation];
    NSURL *url = [[NSURL alloc] initWithString:_urlString];

    MKNetworkEngine *engine = [_delegate networkEngineForPhoto:self];

    __weak MRPhoto *myself = self;
    self.operation = [engine imageAtURL:url
                       completionHandler:^(UIImage *fetchedImage, NSURL *currentUrl, BOOL isInCache) {
                                if ([url.absoluteString isEqualToString:currentUrl.absoluteString]) {
                                    myself.actualImage = fetchedImage;
                                    [myself handleResult:YES block:block];
                                } else {
                                    [myself handleResult:NO block:block];
                                }
                          } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                                [myself handleResult:NO block:block];
                          }];
}

- (void)handleResult:(BOOL)isSuccess block:(MRPhotoResultBlock)block {
    if (block) {
        block(isSuccess);
    }
}
@end