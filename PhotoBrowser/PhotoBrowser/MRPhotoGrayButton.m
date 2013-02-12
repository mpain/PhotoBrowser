#import "MRPhotoGrayButton.h"

#define MRHalfDimension(dimension) (roundf(dimension / 2 - 1))

@implementation MRPhotoGrayButton {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;

        UIImage *image = [UIImage imageNamed:@"MRPhotoBrowser.bundle/button-gray.png"];
        CGSize imageSize = image.size;
        UIEdgeInsets insets = UIEdgeInsetsMake(MRHalfDimension(imageSize.height),
                MRHalfDimension(imageSize.width),
                MRHalfDimension(imageSize.height),
                MRHalfDimension(imageSize.width));
        
        image = [image resizableImageWithCapInsets:insets];
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
    return self;
}
@end