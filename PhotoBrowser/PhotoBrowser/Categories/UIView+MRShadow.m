#import <QuartzCore/QuartzCore.h>
#import "UIView+MRShadow.h"


@implementation UIView (MRShadow)

- (void)dropShadowWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius opacity:(CGFloat)opacity {
    CALayer *layer = self.layer;
    layer.masksToBounds = NO;
    layer.shadowOpacity = opacity;
    layer.shadowColor = color.CGColor;
    layer.shadowRadius = radius;
    layer.shadowOffset = offset;
}
@end