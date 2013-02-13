#import "UIApplication+WindowOverlay.h"


@implementation UIApplication (WindowOverlay)

-(UIView *)baseWindowView{
    if (self.keyWindow.subviews.count > 0) {
        return self.keyWindow.subviews[0];
    }
    return nil;
}

-(void)addWindowOverlay:(UIView *)view {
    [self.baseWindowView addSubview:view];
}

@end