#import <Foundation/Foundation.h>
#import "MRTapImageView.h"


@interface MRZoomingScrollView : UIScrollView<UIScrollViewDelegate, MRTapImageViewDelegate>

- (void)prepareForReuse;

@end