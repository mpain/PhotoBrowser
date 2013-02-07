#import <Foundation/Foundation.h>

typedef void (^MRPhotoResultBlock)(BOOL isSuccess);

@interface MRPhoto : NSObject

- (UIImage *)image;
- (void)loadImageWithBlock:(MRPhotoResultBlock)block;

@end