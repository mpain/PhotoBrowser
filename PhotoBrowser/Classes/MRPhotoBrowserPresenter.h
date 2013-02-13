#import <Foundation/Foundation.h>

typedef void (^MRPhotoBrowserPresenterBlock)();

@interface MRPhotoBrowserPresenter : UIView

@property (nonatomic, copy) MRPhotoBrowserPresenterBlock block;

- (void)animateForView:(UIView *)mainView;
- (void)animateImage:(UIImage *)image withFrame:(CGRect)frame forView:(UIView *)mainView;
- (void)dismissFromView:(UIView *)mainView block:(void (^)())completionBlock;
@end