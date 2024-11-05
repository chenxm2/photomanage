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
#import "Compress/Compresser.h"

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
@property (strong, nonatomic) NSString *compressAlbumName;
@property (strong, nonatomic) Compresser *compresser;
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
    self.title = [NSString localizedStringWithName:@"handle_compress"];

    
    WEAK_SELF
    [self.orgData loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
        STRONG_SELF
        strongSelf.compressedData = [[VideoDataManager sharedManager] assetDataByLocalIdentifier:bindData.compressedlocalIdentifier];
        if (strongSelf.compressedData != nil) {
            strongSelf.compressedContainer.hidden = false;
            [strongSelf.compressedImageView setImageWithAsset:strongSelf.compressedData.asset];
            strongSelf.compressedSizeLabel.text = [NSString fileSizeStringWithNumber:strongSelf.compressedData.fileSize];
            
            [strongSelf.compressedData loadBindData:^(AssetBindData * _Nonnull compressBindData, AssetData * _Nonnull data) {
                strongSelf.compressQualityLabel.text = [compressBindData getQualityString];
                [strongSelf updateCompressButton];
                [strongSelf updateSaveButton];
            }];
            
        }
        
        strongSelf.qualityLabel.text = [bindData getQualityString];
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
        [STOTE_MANAGER getTotalVirtualCurrencyWithCompletion:^(NSUInteger value) {
            if (value < kOnePhotoCost) {
                [self.view showToastWithMessage:[NSString localizedStringWithName:@"coins_not_enough"]];
            } else {
                [self createAlbumAndSaveCompressed:self.compressedURL];
            }
        }];
        
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
        if (confirmed) {
            [ScreenUility setForceScreenOn:YES];
            [[VideoDataManager sharedManager] checkIfVideoIsOnlyInCloud:data.asset callback:^(BOOL result) {
                if (strongSelf) {
                    if (result) {
                        [strongSelf showNetWorkConfirm:data preset:preset];
                    } else {
                        [strongSelf handleCompressVideoWithAsset:data preset:preset isInCloud:NO];
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
            if (confirmed) {
                [strongSelf handleCompressVideoWithAsset:data preset:preset isInCloud:YES];
            }
        }
    }];
}

- (void)handleCompressVideoWithAsset:(AssetData *)data preset:(NSString *)preset isInCloud:(BOOL)isInCloud {
    WEAK_SELF
    self.compresser = [[Compresser alloc] init];
    if (isInCloud) {
        MBProgressHUD *hud = [ProgressHUDWrapper showProgressToView:self.view withString:[NSString localizedStringWithName:@"downloading"]];
        [self.compresser setDownloadProgress:^(double progress, BOOL finished, NSError * _Nonnull error) {
            if (finished || error) {
                [hud hideAnimated:YES];
            } else {
                hud.progress = progress;
            }
        }];
    }
    

    __block MBProgressHUD *beginCompressHUD = nil;
    [self.compresser setBeginCompressCallBack:^{
        beginCompressHUD = [ProgressHUDWrapper showProgressToView:self.view withString:[NSString localizedStringWithName:@"compressing"]];
    }];
    
    [self.compresser setCompressProgress:^(double progress, BOOL finished, NSError * _Nonnull error) {
        if (finished || error) {
            [beginCompressHUD hideAnimated:YES];
        } else {
            beginCompressHUD.progress = progress;
        }
    }];
    
    
    [self.compresser compressVideoWithAsset:data.asset preset:preset completion:^(BOOL succeed, NSURL * _Nullable fileURL, NSString * _Nonnull errMsg) {
        STRONG_SELF
        if (succeed) {
            NSData *compressedData = [NSData dataWithContentsOfURL:fileURL];
            CGFloat compressedSizeMB = compressedData.length / (1024.0 * 1024.0);
            strongSelf.compressedContainer.hidden = false;
            [strongSelf.compressedImageView setImageWithAsset:strongSelf.orgData.asset];
            strongSelf.compressedSizeLabel.text = [NSString fileSizeStringWithNumber:[NSNumber numberWithFloat:compressedSizeMB]];
            strongSelf.compressedURL = fileURL;
            strongSelf.compressedData = nil;
            [strongSelf updateCompressButton];
            [strongSelf updateSaveButton];
            strongSelf.compressQualityLabel.text = preset;
        } else {
            [strongSelf.view showToastWithMessage:@""];
        }
        
        [ScreenUility setForceScreenOn:NO];
    }];
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
        if (success) {
            [strongSelf.orgData loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
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
            
            [STOTE_MANAGER subVirtualCurrency:kOneVideoCost completion:^(BOOL result) {
                if (!result) {
                    LogInfo(@"subVirtualCurrency fail");
                }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
