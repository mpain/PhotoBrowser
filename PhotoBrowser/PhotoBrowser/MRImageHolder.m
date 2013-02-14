#import "MRImageHolder.h"


@implementation MRImageHolder {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupControl];
    }
    return self;
}

- (void)setupControl {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    _imageHolder = imageView;
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        _imageHolder.image = image;
        [self relayout];
    }
}

- (void)layoutSubviews {
    [self relayout];
}

- (void)relayout {
    CGSize imageSize = _image.size;
    CGSize size = self.frame.size;

    CGFloat factorX = (imageSize.width > size.width) ? size.width / imageSize.width : 1.0f;

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat height = ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight ||
            [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft) ? screenSize.width : screenSize.height;
    CGFloat factorY = (imageSize.height > height) ? height / imageSize.height : 1.0f;
    NSLog(@"Holder height: %f", height);

    CGFloat factor = MIN(factorX, factorY);
    imageSize = (CGSize) {
            imageSize.width * factor,
            imageSize.height * factor
    };

    NSLog(@"Image size: %@", NSStringFromCGSize(imageSize));

    CGPoint origin = (CGPoint) {
        .x = (imageSize.width < size.width) ? (size.width - imageSize.width) / 2 : 0,
        .y = (imageSize.height > size.height) ? (size.height - imageSize.height) / 2 : 0
    };
    NSLog(@"Origin: %@", NSStringFromCGPoint(origin));

    _imageHolder.frame = (CGRect) {
        .origin = origin,
        .size = imageSize
    };

}
@end