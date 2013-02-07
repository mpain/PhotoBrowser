#import <Foundation/Foundation.h>

@protocol MRTapImageViewDelegate;

@interface MRTapImageView : UIImageView

@property (nonatomic, weak) id<MRTapImageViewDelegate> userInputDelegate;

@end

@protocol MRTapImageViewDelegate <NSObject>

@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end