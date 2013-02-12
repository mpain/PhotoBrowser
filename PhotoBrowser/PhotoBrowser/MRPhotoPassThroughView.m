#import "MRPhotoPassThroughView.h"


@implementation MRPhotoPassThroughView {

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden &&
                view.userInteractionEnabled &&
                [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

@end