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

static NSString * const kCompressedAlbum = @"压缩相册";

static NSString * const kQualityLow = @"低清晰度";
static NSString * const kQualityStandar480P = @"标清 (480P)";
static NSString * const kQualityMiddle = @"标准清晰度";
static NSString * const kQualityHigh720P = @"高清 (720p)";
static NSString * const kQualityHigh1080p = @"超高清 (1080p)";

@interface VideoCompressViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *orgSizeLabel;
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
            }
        }
        
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ScreenUility setForceScreenOn:NO];
}

- (void)initPickerView {
    // 初始化视频清晰度选项数组
    self.qualityOptions = @[
        
//        kQualityStandar480P,
        kQualityMiddle,
        kQualityLow,
//        kQualityHigh720P,
//        kQualityHigh1080p
    ];
    
    // 初始化 UIPickerView
    
    self.qualityPickerView.delegate = self;
    self.qualityPickerView.dataSource = self;
    
    
    // 设置初始选择值
    self.selectedPreset = AVAssetExportPresetMediumQuality;
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
    [self createAlbumAndSaveCompressed:self.compressedURL];
}


- (IBAction)onLowClicked:(id)sender {
    [self showConfirmationAlertWithData:self.orgData preset:AVAssetExportPresetLowQuality];
}


- (void)showConfirmationAlertWithData:(AssetData *)data preset:(NSString *)preset {
    
    [AlertUtility showConfirmationAlertInViewController:self withTitle:@"压缩视频" message:@"您确定要进行压缩？" confirmButtonTitle:@"确认" cancelButtonTitle:@"取消" completionHandler:^(BOOL confirmed) {
        if (confirmed) {
            WEAK_SELF
            // 确认操作的处理代码
            [ActivityIndicatorUtility showActivityIndicatorInView:self.view];
            [self compressVideoWithAsset:data.asset preset:preset completion:^(NSURL *compressedURL, CGFloat compressedSizeMB) {
                [GCDUtility executeOnMainThread:^{
                    STRONG_SELF
                    if (strongSelf) {
                        [ActivityIndicatorUtility hideActivityIndicatorInView:strongSelf.view];
                        strongSelf.compressedContainer.hidden = false;
                        [strongSelf.compressedImageView setImageWithAsset:strongSelf.orgData.asset];
                        strongSelf.compressedSizeLabel.text = [NSString fileSizeStringWithNumber:[NSNumber numberWithFloat:compressedSizeMB]];
                        strongSelf.compressedURL = compressedURL;
                    }
                }];
                NSLog(@"Video originalSizeMB: %.2f MB,  compressedSizeMB: %.2f", data.fileSize.floatValue, compressedSizeMB);
            }];
        }
    }];
}

- (void)compressVideoWithAsset:(PHAsset *)asset preset:(NSString *)preset completion:(void (^)(NSURL *compressedURL, CGFloat compressedSizeMB))completion {
    NSLog(@"compressVideoWithAsset preset = %@", preset);
    [ScreenUility setForceScreenOn:YES];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    // 获取视频文件路径
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        [GCDUtility executeOnSerialQueue:^{
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:preset];
            exportSession.outputFileType = AVFileTypeMPEG4;
            
            // 定义输出路径
            NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"compressedVideo.mp4"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                NSError *removeError;
                if (![[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil]) {
                    NSLog(@"Failed to remove old file: %@", removeError.localizedDescription);
                }
            }
            
            NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
            exportSession.outputURL = outputURL;
            
            // 执行压缩
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                NSLog(@"compressVideoWithAsset complete statsu = %ld", (long)exportSession.status);
                if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                    // 获取原始大小
                    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                    PHAssetResource *videoResource = resources.firstObject;
                    unsigned long long originalSize = [[videoResource valueForKey:@"fileSize"] unsignedLongLongValue];
                    CGFloat originalSizeMB = originalSize / (1024.0 * 1024.0);
                    
                    // 获取压缩后的视频大小
                    NSData *compressedData = [NSData dataWithContentsOfURL:outputURL];
                    CGFloat compressedSizeMB = compressedData.length / (1024.0 * 1024.0);
                    [ScreenUility setForceScreenOn:NO];
                    // 返回结果
                    if (completion) {
                        completion(outputURL, compressedSizeMB);
                    }
                } else {
                    [ScreenUility setForceScreenOn:NO];
                    if (completion) {
                        completion(outputURL, 0);
                    }
                    NSLog(@"Video compression failed: %@", exportSession.error.localizedDescription);
                }
            }];
        }];
    }];
}

- (void)createAlbumAndSaveCompressed:(NSURL *)compressedURL {
    __block PHAssetCollection *createdCollection = nil;
    
    // 查找自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:kCompressedAlbum]) {
            createdCollection = collection;
            break;
        }
    }

    // 如果相册不存在，创建一个
    if (!createdCollection) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kCompressedAlbum];
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
        if ([collection.localizedTitle isEqualToString:kCompressedAlbum]) {
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
                [[VideoDataManager sharedManager] onCompressedVideoSaveToAlblum:tempLocalIdentifier];
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
    self.selectedPreset = [self presetWithQuality:selectedQuality];
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

- (NSString *)presetWithQuality:(NSString *)quality {
    NSString *result = AVAssetExportPresetMediumQuality;
    if ([quality isEqualToString:kQualityLow]) {
        result = AVAssetExportPresetLowQuality;
    } else if ([quality isEqualToString:kQualityStandar480P]) {
        result = AVAssetExportPreset640x480;
    } else if ([quality isEqualToString:kQualityMiddle]) {
        result = AVAssetExportPresetMediumQuality;
    } else if ([quality isEqualToString:kQualityHigh720P]) {
        result = AVAssetExportPreset1280x720;
    } else if ([quality isEqualToString:kQualityHigh1080p]) {
        result = AVAssetExportPreset1920x1080;
    }
    
    return result;
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
