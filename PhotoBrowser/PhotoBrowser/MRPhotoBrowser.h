#import <Foundation/Foundation.h>
#import "MRPhotoZoomingScrollView.h"
@class MRPhotoBrowser;

typedef void (^MRPhotoBrowserCompletionBlock)(MRPhotoBrowser *browser);

@interface MRPhotoBrowser : UIViewController<UIScrollViewDelegate, MRPhotoZoomingScrollViewControlsDelegate>

@property (nonatomic, assign) NSInteger startPageIndex;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, copy) MRPhotoBrowserCompletionBlock block;

@end