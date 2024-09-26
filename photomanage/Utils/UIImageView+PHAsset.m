//
//  UIImage+PHAsset.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "UIImageView+PHAsset.h"
#import "GCDUtility.h"

const CGSize smallSize = {300.0, 300.0};

@implementation UIImageView (PHAsset)
- (void)setImageWithAsset:(PHAsset *)asset
{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    // 设置图片请求选项
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;

    WEAK_SELF
    // 异步请求图片
    [imageManager requestImageForAsset:asset
                           targetSize:CGSizeZero
                       contentMode:PHImageContentModeAspectFit
                          options:options
                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                         if (result) {
                             NSLog(@"result +++");
                             [GCDUtility executeOnMainThread:^{
                                 STRONG_SELF
                                 if (strongSelf) {
                                     [strongSelf setImage:result];
                                 }
                             }];
                         } else {
                             NSLog(@"requestImageForAsset fail");
                         }
                     }];
}

- (void)setSmallImageWithAsset:(PHAsset *)asset
{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    // 设置图片请求选项
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;

    WEAK_SELF
    // 异步请求图片
    [imageManager requestImageForAsset:asset
                           targetSize:smallSize
                       contentMode:PHImageContentModeAspectFit
                          options:options
                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                         if (result) {
                             [GCDUtility executeOnMainThread:^{
                                 STRONG_SELF
                                 if (strongSelf) {
                                     [strongSelf setImage:result];
                                 }
                             }];
                         } else {
                             NSLog(@"requestImageForAsset fail");
                         }
                     }];
}
@end
