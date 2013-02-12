#import <Foundation/Foundation.h>

typedef void (^MRPhotoResultBlock)(BOOL isSuccess);

@class MRPhoto;
@class MKNetworkEngine;

@protocol MRPhotoDelegate<NSObject>
@required
- (MKNetworkEngine *)networkEngineForPhoto:(MRPhoto *)photo;
@end

@interface MRPhoto : NSObject

- (UIImage *)image;

- (void)unloadImage;
- (void)loadImageWithBlock:(MRPhotoResultBlock)block;

+ (id)photoWithImage:(UIImage *)image;
+ (id)photoWithUrl:(NSString *)urlString delegate:(id<MRPhotoDelegate>)delegate;

@end