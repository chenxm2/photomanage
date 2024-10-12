//
//  VideoCompressViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "VideoCompressViewController.h"
#import "../Utils/String+FileSize.h"
#import "VideoPlayerViewController.h"
#import "VideoDataManager.h"

static NSString * const kLogTag = @"VideoCompressViewController";

@interface VideoCompressViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressedSizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *orgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *compressedImageView;
@property (strong, nonatomic) AssetData *orgData;
@property (strong, nonatomic) AssetData *compressedData;
@property (weak, nonatomic) IBOutlet UIPickerView *qualityPickerView;
@property (nonatomic, strong) NSArray *qualityOptions; // 存储视频预设的选项
@property (nonatomic, strong) NSString *selectedPreset; // 记录用户选择的预设
@property (strong, nonatomic) NSURL *compressedURL;
@property (weak, nonatomic) IBOutlet UIView *compressedContainer;
@property (weak, nonatomic) IBOutlet StyledButton *compressButton;
@property (weak, nonatomic) IBOutlet StyledButton *saveToAlbumButton;
@property (strong, nonatomic) AVAssetReader *reader;
@property (strong, nonatomic) AVAssetWriter *writer;
@property (strong, nonatomic) NSString *compressAlbumName;
@end


@implementation VideoCompressViewController

- (instancetype)initWithAssetData:(AssetData *)data
{
    self = [super init];
    if (self) {
        self.orgData = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.compressAlbumName = [NSString localizedStringWithName:@"compress_album_name"];
    self.orgSizeLabel.text = [NSString fileSizeStringWithNumber:self.orgData.fileSize];
    [self.orgImageView setImageWithAsset:_orgData.asset];
    [self.compressedImageView setImageWithAsset:_orgData.asset];
    [self initPickerView];

    
    WEAK_SELF
    [self.orgData loadBindData:^(AssetBindData * _Nonnull bindData) {
        STRONG_SELF
        if (strongSelf) {
            strongSelf.compressedData = [[VideoDataManager sharedManager] assetDataByLocalIdentifier:bindData.compressedlocalIdentifier];
            if (strongSelf.compressedData != nil) {
                strongSelf.compressedContainer.hidden = false;
                [strongSelf.compressedImageView setImageWithAsset:strongSelf.compressedData.asset];
                strongSelf.compressedSizeLabel.text = [NSString fileSizeStringWithNumber:strongSelf.compressedData.fileSize];
                
                [strongSelf.compressedData loadBindData:^(AssetBindData * _Nonnull compressBindData) {
                    strongSelf.compressQualityLabel.text = [compressBindData getQualityString];
                    [strongSelf updateCompressButton];
                    [strongSelf updateSaveButton];
                }];
                
            }
            
            strongSelf.qualityLabel.text = [bindData getQualityString];
        }
        
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)updateCompressButton {
    if (self.compressedContainer.hidden) {
        [self.compressButton setTitle:[NSString localizedStringWithName:@"compress"] forState:UIControlStateNormal];
    } else {
        [self.compressButton setTitle:[NSString localizedStringWithName:@"re_compress"]  forState:UIControlStateNormal];
    }
}

- (void)updateSaveButton {
    if (self.compressedData != nil) {
        [self.saveToAlbumButton setTitle:[NSString localizedStringWithName:@"saved"] forState:UIControlStateNormal];
    } else {
        [self.saveToAlbumButton setTitle:[NSString localizedStringWithName:@"save_to_album"] forState:UIControlStateNormal];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ScreenUility setForceScreenOn:NO];
}

- (void)initPickerView {
    // 初始化视频清晰度选项数组
    self.qualityOptions = @[
        kQualityHigh,
        kQualityMiddle,
        kQualityLow,
    ];
    
    // 初始化 UIPickerView
    
    self.qualityPickerView.delegate = self;
    self.qualityPickerView.dataSource = self;
    
    // 设置初始选择值
    self.selectedPreset = kQualityHigh;
}

- (IBAction)beginCompressClicked:(id)sender {
    [self showConfirmationAlertWithData:self.orgData preset:self.selectedPreset];
}


- (IBAction)playOrgVideoClicked:(id)sender {
    VideoPlayerViewController *controller = [[VideoPlayerViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller playVideoWithAsset:self.orgData.asset];
}


- (IBAction)playCompressedVideoClicked:(id)sender {
    if (self.compressedURL != nil) {
        VideoPlayerViewController *controller = [[VideoPlayerViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller playVideoWithURL:self.compressedURL];
    } else if (self.compressedData != nil) {
        VideoPlayerViewController *controller = [[VideoPlayerViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller playVideoWithAsset:self.compressedData.asset];
    }
}

- (IBAction)saveToAlbum:(id)sender {
    if (self.compressedURL != nil) {
        [self createAlbumAndSaveCompressed:self.compressedURL];
    } else {
        [self.view showToastWithMessage:[NSString localizedStringWithName:@"already_in_album"]];
    }
}


- (IBAction)onLowClicked:(id)sender {
    [self showConfirmationAlertWithData:self.orgData preset:AVAssetExportPresetLowQuality];
}


- (void)showConfirmationAlertWithData:(AssetData *)data preset:(NSString *)preset {
    WEAK_SELF
    [AlertUtility showConfirmationAlertInViewController:self withTitle:[NSString localizedStringWithName:@"compress_album_name"] message:[NSString localizedStringWithName:@"compress_sure"] confirmButtonTitle:[NSString localizedConfirm] cancelButtonTitle:[NSString localizedCancel] completionHandler:^(BOOL confirmed) {
        STRONG_SELF
        if (strongSelf && confirmed) {
            [ScreenUility setForceScreenOn:YES];
            // 确认操作的处理代码
            [ActivityIndicatorUtility showActivityIndicatorInView:strongSelf.view];
            
            [[VideoDataManager sharedManager] checkIfVideoIsOnlyInCloud:data.asset callback:^(BOOL result) {
                if (strongSelf) {
                    [ActivityIndicatorUtility hideActivityIndicatorInView:strongSelf.view];
                    if (result) {
                        [strongSelf showNetWorkConfirm:data preset:preset];
                    } else {
                        [strongSelf handleCompressVideoWithAsset:data preset:preset];
                    }
                }
            }];
        }
    }];
}

- (void)showNetWorkConfirm:(AssetData *)data preset:(NSString *)preset {
    WEAK_SELF
    [AlertUtility showConfirmationAlertInViewController:self withTitle:@"压缩视频" message:@"您的视频在仅在icloud中，需要访问网络，才能压缩~" confirmButtonTitle:@"确认" cancelButtonTitle:@"取消" completionHandler:^(BOOL confirmed) {
        if (confirmed) {
            STRONG_SELF
            if (strongSelf) {
                if (confirmed) {
                    [strongSelf handleCompressVideoWithAsset:data preset:preset];
                }
            }
        }
    }];
}

- (void)handleCompressVideoWithAsset:(AssetData *)data preset:(NSString *)preset {
    WEAK_SELF
    [ActivityIndicatorUtility showActivityIndicatorInView:weakSelf.view];
    [self compressVideoWithAsset:data.asset preset:preset completion:^(NSURL *compressedURL, CGFloat compressedSizeMB) {
        [ScreenUility setForceScreenOn:NO];
        STRONG_SELF
        if (strongSelf) {
            [ActivityIndicatorUtility hideActivityIndicatorInView:strongSelf.view];
            strongSelf.compressedContainer.hidden = false;
            [strongSelf.compressedImageView setImageWithAsset:strongSelf.orgData.asset];
            strongSelf.compressedSizeLabel.text = [NSString fileSizeStringWithNumber:[NSNumber numberWithFloat:compressedSizeMB]];
            strongSelf.compressedURL = compressedURL;
            strongSelf.compressedData = nil;
            [strongSelf updateCompressButton];
            [strongSelf updateSaveButton];
            strongSelf.compressQualityLabel.text = preset;
        }
        NSLog(@"Video originalSizeMB: %.2f MB,  compressedSizeMB: %.2f", data.fileSize.floatValue, compressedSizeMB);
    }];
}

- (void)compressVideoWithAsset:(PHAsset *)asset preset:(NSString *)preset completion:(void (^)(NSURL *compressedURL, CGFloat compressedSizeMB))completion {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.networkAccessAllowed = true;
    
    [self requestAVAssetForVideo:asset options:options preset:preset completion:completion];
    
}

- (void)requestAVAssetForVideo:(PHAsset *)asset options:(PHVideoRequestOptions *)options preset:(NSString *)preset completion:(void (^)(NSURL *compressedURL, CGFloat compressedSizeMB))completion {
    WEAK_SELF
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        // 检查 avAsset 是否为 nil
        if (avAsset) {
            STRONG_SELF
            if (strongSelf) {
                [strongSelf finalCompressActionWithAsset:avAsset preset:preset completion:completion];
            }
        } else {
            // 视频下载失败，检查 info 字典
            [GCDUtility executeOnMainThread:^{
                NSError *error = info[PHImageErrorKey];
                if (error) {
                    NSLog(@"视频下载失败，错误信息：%@", error.localizedDescription);
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

- (void)callOnMainThreadCompletion:(void (^)(NSURL *compressedURL, CGFloat compressedSizeMB))completion compressURL:(NSURL *)url size:(CGFloat)compressedSizeMB {
    [GCDUtility executeOnMainThread:^{
        completion(url, compressedSizeMB);
    }];
}

- (void)finalCompressActionWithAsset:(AVAsset *)asset preset:(NSString *)preset completion:(void (^)(NSURL *compressedURL, CGFloat compressedSizeMB))completion {
        
    // 定义输出路径
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"compressedVideo.mp4"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        NSError *removeError;
        if (![[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil]) {
            NSLog(@"Failed to remove old file: %@", removeError.localizedDescription);
        }
    }
    
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    NSError *error = nil;
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        completion(nil, 0);
        return;
    }
    
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    // 获取原始码率
    CGAffineTransform videoTransform = videoTrack.preferredTransform;  // 获取变换矩阵
    CGFloat originalBitRate = [self calculateBitRateForVideoTrack:videoTrack];
    
    // 设置压缩参数，按比例压缩码率
    NSDictionary *videoSettings = [self videoSettingsForPreset:preset videoTrack:videoTrack originalBitRate:originalBitRate];
    
    // 创建视频写入
    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    videoWriterInput.expectsMediaDataInRealTime = NO;
    videoWriterInput.transform = videoTransform;  // 关键代码，保留视频方向
    
    // 获取视频轨道
    // 添加视频输入到写入器
    if ([assetWriter canAddInput:videoWriterInput]) {
        [assetWriter addInput:videoWriterInput];
    } else {
        [self callOnMainThreadCompletion:completion compressURL:nil size:0];
        return;
    }
    
    
    self.writer = assetWriter;
    
    // 创建音频写入输入
    AVAssetWriterInput *audioWriterInput = nil;
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
        AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        NSDictionary *audioSettings = @{
            AVFormatIDKey: @(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: @(audioTrack.formatDescriptions.count),
            AVSampleRateKey: @(44100),
            AVEncoderBitRateKey: @(128000)
        };
        audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        if ([assetWriter canAddInput:audioWriterInput]) {
            [assetWriter addInput:audioWriterInput];
        } else {
        }
    }
    
    // 启动写入过程
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    // 使用 AVAssetReader 读取数据
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if (error) {
        [self callOnMainThreadCompletion:completion compressURL:nil size:0];
        return;
    }
    
    self.reader = assetReader;
    
    // 视频读取输入
    if (!videoTrack) {
        
    }
    NSDictionary *videoReaderOutputSettings = @{
        (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),  // YUV 格式
        (id)kCVPixelBufferWidthKey: @(videoTrack.naturalSize.width),  // 视频宽度
        (id)kCVPixelBufferHeightKey: @(videoTrack.naturalSize.height),  // 视频高度
    };
    AVAssetReaderTrackOutput *videoReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:videoReaderOutputSettings];
    if ([assetReader canAddOutput:videoReaderOutput]) {
        [assetReader addOutput:videoReaderOutput];
    } else {
        [self callOnMainThreadCompletion:completion compressURL:nil size:0];
        return;
    }
    
    NSDictionary *audioReaderOutputSettings = @{
        AVFormatIDKey: @(kAudioFormatLinearPCM),
        AVLinearPCMBitDepthKey: @(16),
        AVLinearPCMIsNonInterleaved: @(NO),
        AVLinearPCMIsFloatKey: @(NO),
        AVLinearPCMIsBigEndianKey: @(NO)
    };
    // 音频读取输入
    AVAssetReaderTrackOutput *audioReaderOutput = nil;
    if (audioWriterInput) {
        AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
         audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioReaderOutputSettings];
        if ([assetReader canAddOutput:audioReaderOutput]) {
            [assetReader addOutput:audioReaderOutput];
        } else {
        }
    }
    
    // 开始读取数据并写入
    [assetReader startReading];
    
    // 创建一个 dispatch group
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t videoCompressQueue = dispatch_queue_create("video.compress.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t audioCompressQueue = dispatch_queue_create("audio.compress.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_enter(group); // 手动进入 group
    [videoWriterInput requestMediaDataWhenReadyOnQueue:videoCompressQueue usingBlock:^{
        while ([videoWriterInput isReadyForMoreMediaData]) {
            CMSampleBufferRef sampleBuffer = [videoReaderOutput copyNextSampleBuffer];
            if (sampleBuffer) {
                [videoWriterInput appendSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
            } else {
                [videoWriterInput markAsFinished];
                dispatch_group_leave(group); // 任务 1 完成，离开 group
                break;
            }
        }
    }];
    
    dispatch_group_enter(group); // 手动进入 group
    [audioWriterInput requestMediaDataWhenReadyOnQueue:audioCompressQueue usingBlock:^{
            while ([audioWriterInput isReadyForMoreMediaData]) {
                CMSampleBufferRef sampleBuffer = [audioReaderOutput copyNextSampleBuffer];
                if (sampleBuffer) {
                    // 解码音频样本并转换为PCM格式
                    [audioWriterInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                } else {
                    [audioWriterInput markAsFinished];
                    dispatch_group_leave(group); // 任务 1 完成，离开 group
                    break;
                }
            }
    }];
    
    
    // 等待所有任务完成后执行某个操作
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"All tasks finished");
        if ([assetReader status] == AVAssetReaderStatusReading) {
            NSLog(@"cancelReading");
            [assetReader cancelReading];
        }
        
        [assetWriter finishWritingWithCompletionHandler:^{
            if (assetWriter.status == AVAssetWriterStatusCompleted) {
                
                NSData *compressedData = [NSData dataWithContentsOfURL:outputURL];
                CGFloat compressedSizeMB = compressedData.length / (1024.0 * 1024.0);
                NSLog(@"file finish compressedSizeMB = %f", compressedSizeMB);
                [self callOnMainThreadCompletion:completion compressURL:outputURL size:compressedSizeMB];
            } else {
                [self callOnMainThreadCompletion:completion compressURL:nil size:0];
            }
        }];
    });
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


- (CGFloat)calculateBitRateForVideoTrack:(AVAssetTrack *)videoTrack {
    CGSize videoSize = videoTrack.naturalSize;
    CMTime duration = videoTrack.timeRange.duration;
    float videoDurationInSeconds = CMTimeGetSeconds(duration);    
    // 用视频大小和持续时间估算码率
    float estimatedSize = videoTrack.totalSampleDataLength;
    CGFloat bitRate = (estimatedSize * 8) / videoDurationInSeconds; // bitRate = 文件大小 * 8 / 时间 (bps)
    
    return bitRate;
}

// 等待视频下载完成
- (void)waitForAssetToDownload:(PHAsset *)asset options:(PHVideoRequestOptions *)options preset:(NSString *)preset completion:(void (^)(NSURL *compressedURL, CGFloat compressedSizeMB))completion {
    // 使用一个简单的定时器，每隔一段时间重新检查下载状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestAVAssetForVideo:asset options:options preset:preset completion:completion];
    });
}

- (void)createAlbumAndSaveCompressed:(NSURL *)compressedURL {
    __block PHAssetCollection *createdCollection = nil;
    
    // 查找自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:self.compressAlbumName]) {
            createdCollection = collection;
            break;
        }
    }

    // 如果相册不存在，创建一个
    if (!createdCollection) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:self.compressAlbumName];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"Custom album created.");
                [GCDUtility executeOnMainThread:^{
                    [self saveCompressedVideo:compressedURL];
                }];
            }
        }];
    } else {
        [self saveCompressedVideo:compressedURL];
    }
}

- (void)saveCompressedVideo:(NSURL *)compressedURL {
    // 获取自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    PHAssetCollection *customAlbum = nil;
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:self.compressAlbumName]) {
            customAlbum = collection;
            break;
        }
    }
    __block NSString *tempLocalIdentifier = nil;
    [ActivityIndicatorUtility showActivityIndicatorInView:self.view];
    WEAK_SELF
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 将压缩后的视频添加到相册
        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:customAlbum];
        PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:compressedURL];

        [albumChangeRequest addAssets:@[[creationRequest placeholderForCreatedAsset]]];
        tempLocalIdentifier = creationRequest.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError *error) {
        STRONG_SELF
        if (strongSelf && success) {
            [strongSelf.orgData loadBindData:^(AssetBindData * _Nonnull bindData) {
                bindData.isCompress = @(YES);
                bindData.compressedlocalIdentifier = tempLocalIdentifier;
                [[VideoDataManager sharedManager] onCompressedVideoSaveToAlblum:tempLocalIdentifier  compressQuality:strongSelf.selectedPreset callBack:^(AssetData * _Nonnull assetData) {
                    NSLog(@"onCompressedVideoSaveToAlblum %@", assetData);
                    strongSelf.compressedData = assetData;
                    strongSelf.compressedURL = nil;
                    [strongSelf updateSaveButton];
                }];
                
            }];
            [GCDUtility executeOnMainThread:^{
                [ActivityIndicatorUtility hideActivityIndicatorInView:strongSelf.view];
                [strongSelf showHintAlert];
            }];

        }else {
            NSLog(@"Error adding videos to album: %@", error);
        }
    }];
}

- (void)showHintAlert {
    [AlertUtility showConfirmationAlertInViewController:self withTitle:@"删除原视频" message:@"压缩过的视频已经保存到自定义的《压缩相册》中，建议您删除原视频" confirmButtonTitle:@"删除" cancelButtonTitle:@"取消" completionHandler:^(BOOL confirmed) {
        if (confirmed) {
            [self deleteVideoAsset:self.orgData.asset completionHandler:^(BOOL success, NSError * _Nullable error) {
                [GCDUtility executeOnMainThread:^{
                }];
            }];
        }
    }];
}

- (void)deleteVideoAsset:(PHAsset *)asset completionHandler:(void(^)(BOOL success, NSError * _Nullable error))completion {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 请求删除指定的 PHAsset
        [PHAssetChangeRequest deleteAssets:@[asset]];
        // 如果你需要删除视频，你可以使用以下代码行
        // PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideo:asset];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (completion) {
            completion(success, error);
        }
    }];
}

#pragma mark - PickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // 只需要一列
}

// UIPickerView 的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.qualityOptions.count;
}

// UIPickerView 每行显示的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.qualityOptions[row];
}

// 选择某行时触发
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectedQuality = self.qualityOptions[row];
    NSLog(@"用户选择了: %@", selectedQuality);
    self.selectedPreset = selectedQuality;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.text = self.qualityOptions[row];
    label.textColor = [UIColor whiteColor]; // 设置文字颜色
    label.font = [UIFont systemFontOfSize:16]; // 设置文字大小
    return label;
}

- (void)checkIfVideoIsInICloud:(PHAsset *)asset {
    // 检查资源类型是否为视频
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = NO; // 不允许从网络下载，直接检查本地是否有资源
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (avAsset) {
                // 视频在本地
            } else {
                // 视频不在本地（可能在 iCloud 中）
            }
        }];
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
