#import "MRPhoto.h"
#import "MKNetworkEngine.h"

@interface MRPhoto ()

@property (nonatomic, strong) MKNetworkOperation *operation;
@property (nonatomic, strong) UIImage *image;

@end

@implementation MRPhoto {
    __strong NSString *_urlString;
    __weak MKNetworkEngine *_engine;
}

- (void)dealloc {
    [self cancelNetworkOperation];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (id)initWithUrl:(NSString *)urlString engine:(MKNetworkEngine *)engine {
    self = [super init];
    if (self) {
        _urlString = [urlString copy];
        _engine = engine;
    }
    return self;
}

- (void)cancelNetworkOperation {
    if (self.operation) {
        [self.operation cancel];
        self.operation = nil;
    }
}

- (void)loadImageWithBlock:(MRPhotoResultBlock)block {
    if (self.image) {
        [self handleResult:YES block:block];
        return;
    }

    [self cancelNetworkOperation];
    NSURL *url = [[NSURL alloc] initWithString:_urlString];

    __weak MRPhoto *myself = self;
    self.operation = [_engine imageAtURL:url
                       completionHandler:^(UIImage *fetchedImage, NSURL *currentUrl, BOOL isInCache) {
                                if ([url.absoluteString isEqualToString:currentUrl.absoluteString]) {
                                    myself.image = fetchedImage;
                                    [myself handleResult:YES block:block];
                                } else {
                                    [myself handleResult:NO block:block];
                                }
                          } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                                [myself handleResult:NO block:block];
                          }];

    [self.operation start];
}

- (void)handleResult:(BOOL)isSuccess block:(MRPhotoResultBlock)block {
    if (block) {
        block(isSuccess);
    }
}
@end