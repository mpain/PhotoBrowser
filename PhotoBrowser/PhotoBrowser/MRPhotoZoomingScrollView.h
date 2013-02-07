#import <Foundation/Foundation.h>
#import "MRTapImageView.h"

@class MRPhoto;


@interface MRPhotoZoomingScrollView : UIScrollView<UIScrollViewDelegate, MRTapImageViewDelegate>

- (void)prepareForReuse;
- (void)setPhoto:(MRPhoto *)photo;
@end