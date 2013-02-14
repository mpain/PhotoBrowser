#import <Foundation/Foundation.h>

typedef void (^MRPhotoBrowserPresenterBlock)();

@interface MRPhotoBrowserPresenter : UIView

@property (nonatomic, copy) MRPhotoBrowserPresenterBlock appearBlock;
@property (nonatomic, copy) MRPhotoBrowserPresenterBlock dismissBlock;

@property (nonatomic, assign) NSInteger startGalleryIndex;
@property (nonatomic, strong) NSArray *galleryPhotos;

- (void)presentPhotoBrowserWithImage:(UIImage *)image fromView:(UIView *)view constrainedToView:(UIView *)mainView;
@end