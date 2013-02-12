#import <Foundation/Foundation.h>

@interface UIView (MRShadow)

- (void)dropShadowWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius opacity:(CGFloat)opacity;
@end