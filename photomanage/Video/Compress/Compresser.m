//
//  Compresser.m
//  photomanage
//
//  Created by chenxianming on 2024/10/15.
//

#import "Compresser.h"
#import "../AssetData.h"

@interface Compresser ()
@property (strong, nonatomic) AVAssetReader *reader;
@property (strong, nonatomic) AVAssetWriter *writer;
@property (strong, nonatomic) AVAssetWriterInput *videoWriterInput;
@property (strong, nonatomic) AVAssetReaderTrackOutput *videoReaderOutput;
@property (strong, nonatomic) AVAssetWriterInput *audioWriterInput;
@property (strong, nonatomic) AVAssetReaderTrackOutput *audioReaderOutput;
@property (assign, nonatomic) float progress;
@end

@implementation Compresser
- (void)compressVideoWithAsset:(PHAsset *)asset preset:(NSString *)preset completion:(CompressResultCallBack)completion {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.networkAccessAllowed = true;
    WEAK_SELF
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        [GCDUtility executeOnMainThread:^{
           STRONG_SELF
            if (strongSelf.downloadProgress != nil) {
                if (error) {
                    strongSelf.downloadProgress(progress, YES, error);
                } else {
                    strongSelf.downloadProgress(progress, NO, nil);
                }
            }
        }];
    };
    [self requestAVAssetForVideo:asset options:options preset:preset completion:completion];
}

- (void)requestAVAssetForVideo:(PHAsset *)asset options:(PHVideoRequestOptions *)options preset:(NSString *)preset completion:(CompressResultCallBack)completion {
    WEAK_SELF
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        // 检查 avAsset 是否为 nil
        if (avAsset) {
            STRONG_SELF
            [strongSelf finalCompressActionWithAsset:avAsset preset:preset completion:completion];
            [GCDUtility executeOnMainThread:^{
                STRONG_SELF
                
                if (strongSelf.downloadProgress != nil) {
                    strongSelf.downloadProgress(1.0, YES, nil);
                }
                
                if (strongSelf.beginCompressCallBack != nil) {
                    strongSelf.beginCompressCallBack();
                }
            }];
            
        } else {
            // 视频下载失败，检查 info 字典
            [GCDUtility executeOnMainThread:^{
                NSError *error = info[PHImageErrorKey];
                STRONG_SELF
                if (error) {
                    strongSelf.downloadProgress(0, YES, error);
                } else {
                    // 视频尚未下载或正在下载中
                    NSLog(@"视频尚未下载，正在等待...");
                    // 可以使用递归请求的方法，等待直到下载完成
                    [self waitForAssetToDownload:asset options:options preset:preset completion:completion];
                }
            }];
        }
    }];
}

- (BOOL)configAVAssetWriter:(NSURL *)outputURL {
    BOOL res = YES;
    NSError *error = nil;
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        res = NO;
    }
    
    self.writer = assetWriter;
    return res;
}

- (BOOL)configAVAssetReader:(AVAsset *)asset {
    BOOL res = YES;
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if (error) {
        res = NO;
    }
    self.reader = assetReader;
    return res;
}

- (BOOL)configVideoWriterInputWithAsset:(AVAsset *)asset preset:(NSString *)preset {
    BOOL res = YES;

    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    // 获取原始码率
    CGAffineTransform videoTransform = videoTrack.preferredTransform;  // 获取变换矩阵
    CGFloat originalBitRate = [self calculateBitRateForVideoTrack:videoTrack];
    // 设置压缩参数，按比例压缩码率
    NSDictionary *videoSettings = [self videoSettingsForPreset:preset videoTrack:videoTrack originalBitRate:originalBitRate];
    
    // 创建视频写入
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    self.videoWriterInput.expectsMediaDataInRealTime = NO;
    self.videoWriterInput.transform = videoTransform;  // 关键代码，保留视频方向
    
    // 获取视频轨道
    // 添加视频输入到写入器
    if ([self.writer canAddInput:self.videoWriterInput]) {
        [self.writer addInput:self.videoWriterInput];
    } else {
        res = NO;
    }
    
    return res;
}

- (BOOL)configVideoReaderOutputWithAsset:(AVAsset *)asset {
    BOOL res = YES;
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    // 视频读取输入
    if (!videoTrack) {
        res = NO;
    } else {
        NSDictionary *videoReaderOutputSettings = @{
            (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),  // YUV 格式
            (id)kCVPixelBufferWidthKey: @(videoTrack.naturalSize.width),  // 视频宽度
            (id)kCVPixelBufferHeightKey: @(videoTrack.naturalSize.height),  // 视频高度
        };
         self.videoReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:videoReaderOutputSettings];
        if ([self.reader canAddOutput:self.videoReaderOutput]) {
            [self.reader addOutput:self.videoReaderOutput];
        } else {
            res = NO;
        }
    }
    
    return res;
}

- (BOOL)configAudioReaderOutputWithAsset:(AVAsset *)asset {
    BOOL res = YES;
    NSDictionary *audioReaderOutputSettings = @{
        AVFormatIDKey: @(kAudioFormatLinearPCM),
        AVLinearPCMBitDepthKey: @(16),
        AVLinearPCMIsNonInterleaved: @(NO),
        AVLinearPCMIsFloatKey: @(NO),
        AVLinearPCMIsBigEndianKey: @(NO)
    };
    // 音频读取输入
    AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    self.audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioReaderOutputSettings];
    if ([self.reader canAddOutput:self.audioReaderOutput]) {
        [self.reader addOutput:self.audioReaderOutput];
    } else {
        res = NO;
    }
    
    return res;
}

- (BOOL)configAudioWriterInputWithAsset:(AVAsset *)asset {
    BOOL res = YES;
    // 创建音频写入输入
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
        AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        NSDictionary *audioSettings = @{
            AVFormatIDKey: @(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: @(audioTrack.formatDescriptions.count),
            AVSampleRateKey: @(44100),
            AVEncoderBitRateKey: @(128000)
        };
        self.audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        if ([self.writer canAddInput:self.audioWriterInput]) {
            [self.writer addInput:self.audioWriterInput];
        } else {
            res = NO;
        }
    } else {
        res = NO;
    }
    return res;
}

- (void)finalCompressActionWithAsset:(AVAsset *)asset preset:(NSString *)preset completion:(CompressResultCallBack)completion {
        
    // 定义输出路径
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"compressedVideo.mp4"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        NSError *removeError;
        if (![[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil]) {
            NSLog(@"Failed to remove old file: %@", removeError.localizedDescription);
        }
    }
    
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    if (![self configAVAssetWriter:outputURL]) {
        completion(NO, nil, @"configAVAssetWriter fali");
        return;
    }
    
    
    if (![self configVideoWriterInputWithAsset:asset preset:preset]) {
        [self callOnMainThreadCompletion:completion succeed:NO compressURL:nil errMsg:@"configVideoWriterInputWithAsset fail"];
        return;
    }
    
    if (![self configAudioWriterInputWithAsset:asset]) {
        [self callOnMainThreadCompletion:completion succeed:NO compressURL:nil errMsg:@"configAudioWriterInputWithAsset fail"];
        return;
    }

    if (![self configAVAssetReader:asset]) {
        [self callOnMainThreadCompletion:completion succeed:NO compressURL:nil errMsg:@"configAVAssetReader fail"];
        return;
    }
    
    if (![self configVideoReaderOutputWithAsset:asset]) {
        completion(NO, nil, @"configVideoReaderOutputWithAsset fali");
        return;
    }
    
    if (![self configAudioReaderOutputWithAsset:asset]) {
        completion(NO, nil, @"configAudioReaderOutputWithAsset fali");
        return;
    }
    
    // 启动写入过程
    [self.writer startWriting];
    [self.writer startSessionAtSourceTime:kCMTimeZero];
    // 开始读取数据并写入
    [self.reader startReading];
    
    float totalDuration = [self getTotalDurationWithAsset:asset];
    // 创建一个 dispatch group
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t videoCompressQueue = dispatch_queue_create("video.compress.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t audioCompressQueue = dispatch_queue_create("audio.compress.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_enter(group); // 手动进入 group
    WEAK_SELF
    [self.videoWriterInput requestMediaDataWhenReadyOnQueue:videoCompressQueue usingBlock:^{
        STRONG_SELF
        while ([strongSelf.videoWriterInput isReadyForMoreMediaData]) {
            CMSampleBufferRef sampleBuffer = [strongSelf.videoReaderOutput copyNextSampleBuffer];
            if (sampleBuffer) {
                [strongSelf caculateProgressSample:sampleBuffer totalDuration:totalDuration];
                [strongSelf.videoWriterInput appendSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
            } else {
                [strongSelf.videoWriterInput markAsFinished];
                dispatch_group_leave(group); // 任务 1 完成，离开 group
                break;
            }
        }
    }];
    
    dispatch_group_enter(group); // 手动进入 group
    [self.audioWriterInput requestMediaDataWhenReadyOnQueue:audioCompressQueue usingBlock:^{
        STRONG_SELF
            while ([strongSelf.audioWriterInput isReadyForMoreMediaData]) {
                CMSampleBufferRef sampleBuffer = [strongSelf.audioReaderOutput copyNextSampleBuffer];
                if (sampleBuffer) {
                    // 解码音频样本并转换为PCM格式
                    [strongSelf.audioWriterInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                } else {
                    [strongSelf.audioWriterInput markAsFinished];
                    dispatch_group_leave(group); // 任务 1 完成，离开 group
                    break;
                }
            }
    }];

    
    // 等待所有任务完成后执行某个操作
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        STRONG_SELF
        NSLog(@"All tasks finished");
        if ([strongSelf.reader status] == AVAssetReaderStatusReading) {
            NSLog(@"cancelReading");
            [strongSelf.reader cancelReading];
        }
        
        [strongSelf.writer finishWritingWithCompletionHandler:^{
            STRONG_SELF
            if (strongSelf.writer.status == AVAssetWriterStatusCompleted) {
                [strongSelf callOnMainThreadCompletion:completion succeed:YES compressURL:outputURL errMsg:nil];
            } else {
                [strongSelf callOnMainThreadCompletion:completion succeed:NO compressURL:nil errMsg:@"finishWritingWithCompletionHandler fail"];
            }
            
            [GCDUtility executeOnMainThread:^{
                STRONG_SELF
                if (strongSelf.compressProgress != nil) {
                    strongSelf.compressProgress(1, YES, nil);
                }
            }];
          
        }];
    });
}

- (float)getTotalDurationWithAsset:(AVAsset *)asset {
    float res = 0;
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (videoTrack) {
        res = CMTimeGetSeconds(asset.duration);
    }

    return res;
}

- (void)caculateProgressSample:(CMSampleBufferRef)sampleBuffer totalDuration:(float)totalDuration {
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    // 将时间戳转换为秒数
    float timestampSeconds = CMTimeGetSeconds(presentationTimeStamp);
    float progress = 0;
    if (totalDuration != 0) {
        progress = timestampSeconds / totalDuration;
    }
    WEAK_SELF
    if ((progress - self.progress) * 100 > 1) {
        self.progress = progress;
        [GCDUtility executeOnMainThread:^{
            STRONG_SELF
            if (strongSelf.compressProgress != nil) {
                strongSelf.compressProgress(progress, NO, nil);
                [LogUtil logInfoWithTag:@"progress" message:@" == %d", (int)(progress * 100)];
            }
        }];
    }
    
}

// 等待视频下载完成
- (void)waitForAssetToDownload:(PHAsset *)asset options:(PHVideoRequestOptions *)options preset:(NSString *)preset completion:(CompressResultCallBack)completion {
    WEAK_SELF
    // 使用一个简单的定时器，每隔一段时间重新检查下载状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONG_SELF
        if (strongSelf) {
            [strongSelf requestAVAssetForVideo:asset options:options preset:preset completion:completion];
        }
        
    });
}

- (CGFloat)calculateBitRateForVideoTrack:(AVAssetTrack *)videoTrack {
    CGSize videoSize = videoTrack.naturalSize;
    CMTime duration = videoTrack.timeRange.duration;
    float videoDurationInSeconds = CMTimeGetSeconds(duration);
    // 用视频大小和持续时间估算码率
    float estimatedSize = videoTrack.totalSampleDataLength;
    CGFloat bitRate = (estimatedSize * 8) / videoDurationInSeconds; // bitRate = 文件大小 * 8 / 时间 (bps)
    
    return bitRate;
}

- (void)callOnMainThreadCompletion:(CompressResultCallBack)completion succeed:(BOOL) succeed compressURL:(NSURL *)url errMsg:(NSString *)msg {
    [GCDUtility executeOnMainThread:^{
        completion(succeed, url, msg);
    }];
}

- (NSDictionary *)videoSettingsForPreset:(NSString *)preset
                                        videoTrack:(AVAssetTrack *)videoTrack
                                    originalBitRate:(CGFloat)originalBitRate {
    CGSize videoSize = videoTrack.naturalSize;

    CGFloat orgframeRate = videoTrack.nominalFrameRate;
    NSLog(@"视频原帧率为: %.2f fps", orgframeRate);
    
    CGSize outputSize;
    CGFloat videoBitRate = originalBitRate * 0.6; // 默认压缩到 70%
    NSInteger frameRate = 30;
    if ([kQualityHigh isEqual:preset]) {
        videoBitRate = originalBitRate * 0.9; // 高保真，压缩到 90% 原码率
        frameRate = 30; // 高帧率
        outputSize = videoSize;
    } else if ([kQualityMiddle isEqual:preset]) {
        videoBitRate = originalBitRate * 0.6; // 中等质量，压缩到 70% 原码率
        frameRate = 24; // 中等帧率
        outputSize = CGSizeMake(videoSize.width * 0.8, videoSize.height * 0.8); // 减小到 80% 原始分辨率
    } else if ([kQualityLow isEqual:preset]) {
        videoBitRate = originalBitRate * 0.3; // 低质量，压缩到 30% 原码率
        frameRate = 15;
        outputSize = CGSizeMake(videoSize.width * 0.5, videoSize.height * 0.5);
    } else {
        videoBitRate = originalBitRate * 0.7; // 中等质量，压缩到 60% 原码率
        frameRate = 24; // 中等帧率
        outputSize = CGSizeMake(videoSize.width * 0.8, videoSize.height * 0.8); // 减小到 80% 原始分辨率
    }
    
    NSDictionary *compressionSettings = @{
        AVVideoAverageBitRateKey: @(videoBitRate),
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
    };
    
    NSDictionary *videoSettings = @{
        AVVideoCodecKey: AVVideoCodecTypeH264,
        AVVideoWidthKey: @(outputSize.width),
        AVVideoHeightKey: @(outputSize.height),
        AVVideoCompressionPropertiesKey: compressionSettings
    };

    return videoSettings;
}


@end
