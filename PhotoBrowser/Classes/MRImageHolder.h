#import <Foundation/Foundation.h>


@interface MRImageHolder : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak, readonly) UIImageView *imageHolder;

- (void)relayout;
@end