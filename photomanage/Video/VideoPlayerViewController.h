//
//  VideoPlayerViewController.h
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerViewController : BaseViewController
- (void)playVideoWithURL:(NSURL *)url;
// 播放 PHAsset 视频
- (void)playVideoWithAsset:(PHAsset *)asset;
@end

NS_ASSUME_NONNULL_END
