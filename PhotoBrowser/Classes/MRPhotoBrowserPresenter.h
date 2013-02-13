#import <Foundation/Foundation.h>

typedef void (^MRPhotoBrowserPresenterBlock)();

@interface MRPhotoBrowserPresenter : UIView

@property (nonatomic, copy) MRPhotoBrowserPresenterBlock block;

- (void)animateForView:(UIView *)mainView;
- (void)animateImage:(UIImage *)image fromView:(UIView *)view constraintToView:(UIView *)mainView;
- (void)dismissFromView:(UIView *)mainView block:(void (^)())completionBlock;
@end