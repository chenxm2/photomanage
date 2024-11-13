//
//  ICloudVideoDownloader.m
//  photomanage
//
//  Created by chenxianming on 2024/11/13.
//

#import "ICloudVideoDownloader.h"

@interface ICloudVideoDownloader ()
@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, copy) void (^progressHandler)(double);
@property (nonatomic, copy) void (^completionHandler)(AVAsset * _Nullable, NSError * _Nullable);
@property (nonatomic, assign) BOOL isChecking;
@end

@implementation ICloudVideoDownloader

- (void)downloadVideoFromICloud:(PHAsset *)asset
                progressHandler:(void (^)(double progress))progressHandler
               completionHandler:(void (^)(AVAsset * _Nullable avAsset, NSError * _Nullable error))completionHandler {

    if (asset.mediaType != PHAssetMediaTypeVideo) {
        NSError *error = [NSError errorWithDomain:@"ICloudVideoDownloaderErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"The asset is not a video."}];
        completionHandler(nil, error);
        return;
    }

    self.progressHandler = progressHandler;
    self.completionHandler = completionHandler;
    self.isChecking = NO;
    
    WEAK_SELF

    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        STRONG_SELF
        if (error) {
            // 如果下载中出现错误，调用completionHandler返回错误
            NSError *downloadError = [NSError errorWithDomain:@"ICloudVideoDownloaderErrorDomain"
                                code:-2
                                userInfo:@{NSLocalizedDescriptionKey: @"Failed to download video from iCloud.",
                                                                        NSLocalizedFailureReasonErrorKey: error.localizedDescription}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        strongSelf.completionHandler(nil, downloadError);
                    });
            
            [strongSelf.checkTimer invalidate];
            strongSelf.checkTimer = nil;
            return;
        }
        
        
        if (progressHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LogInfo(@"downloadVideoFromICloud progress = %f", progress);
                strongSelf.progressHandler(progress);
            });
        }
    };

    [self checkVideoAssetAvailability:asset options:options];
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(periodicallyCheckAvailability:)
                                                     userInfo:@{@"asset": asset, @"options": options}
                                                      repeats:YES];
}

- (void)checkVideoAssetAvailability:(PHAsset *)asset options:(PHVideoRequestOptions *)options {
    if (self.isChecking) {
        LogInfo(@"checkVideoAssetAvailability return by isChecking");
        return;
    }
    

    self.isChecking = YES;
    WEAK_SELF
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        STRONG_SELF
        strongSelf.isChecking = NO;
        if (avAsset) {
            [strongSelf.checkTimer invalidate];
            strongSelf.checkTimer = nil;

            if (strongSelf.completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.completionHandler(avAsset, nil);
                });
            }
        } else if (info[PHImageErrorKey]) {
            [strongSelf.checkTimer invalidate];
            strongSelf.checkTimer = nil;
            NSError *error = info[PHImageErrorKey];
            if (strongSelf.completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.completionHandler(nil, error);
                });
            }
        }
    }];
}

- (void)periodicallyCheckAvailability:(NSTimer *)timer {
    PHAsset *asset = timer.userInfo[@"asset"];
    PHVideoRequestOptions *options = timer.userInfo[@"options"];
    [self checkVideoAssetAvailability:asset options:options];
}

- (void)cancel {
    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

@end
