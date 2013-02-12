#import <Foundation/Foundation.h>
#import "MRPhotoTapImageView.h"

@class MRPhoto;

@protocol MRPhotoZoomingScrollViewControlsDelegate <NSObject>
- (void)toggleControls;
- (void)hideControls;
- (void)cancelControlsOperations;
@end

@interface MRPhotoZoomingScrollView : UIScrollView<UIScrollViewDelegate, MRTapImageViewDelegate>

@property (nonatomic, strong) MRPhoto *photo;
@property (nonatomic, weak) id<MRPhotoZoomingScrollViewControlsDelegate> controlsDelegate;

- (void)prepareForReuse;
- (void)setupZoomScales;

@end