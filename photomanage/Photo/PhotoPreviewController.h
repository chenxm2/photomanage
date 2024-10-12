//
//  PhotoPreviewController.h
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@protocol PhotoPreviewControllerDelegate <NSObject>
@optional
- (void)didPhotoPreviewSelectPHAsset:(PHAsset *)asset;
- (void)didPhotoPreviewDeleteCountChange;
@end

@interface PhotoPreviewController : UIViewController
@property (weak) id<PhotoPreviewControllerDelegate> delegate;
+ (instancetype)viewControllerWithParameter:(NSMutableArray<PHAsset *> *)assetsArray
                                 deleteArray:(NSMutableArray<PHAsset *> *)deleteArray selectAsset:(PHAsset *)selectAsset; // 类方法声明
- (void)updateWithAsset:(PHAsset *)selectAsset;
@end

NS_ASSUME_NONNULL_END
