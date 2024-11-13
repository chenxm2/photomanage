//
//  ICloudVideoDownloader.h
//  photomanage
//
//  Created by chenxianming on 2024/11/13.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICloudVideoDownloader : NSObject

// 开始下载视频
- (void)downloadVideoFromICloud:(PHAsset *)asset
                progressHandler:(void (^)(double progress))progressHandler
               completionHandler:(void (^)(AVAsset * _Nullable avAsset, NSError * _Nullable error))completionHandler;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END

