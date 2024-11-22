//
//  VideoCompressViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "VideoCompressViewController.h"
#import "../Utils/String+Bussiness.h"
#import "VideoPlayerViewController.h"
#import "VideoDataManager.h"
#import "Compress/Compresser.h"
#import "ICloudVideoDownloader.h"
#import "StoreManager.h"

static NSString * const kLogTag = @"VideoCompressViewController";

@interface VideoCompressViewController () <UIPickerViewDelegate, UIPickerViewDataSource, CustomButtonViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressedSizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *orgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *compressedImageView;
@property (strong, nonatomic) AssetData *orgData;
@property (strong, nonatomic) AssetData *compressedData;
@property (nonatomic, strong) NSArray *qualityOptions; // 存储视频预设的选项
@property (strong, nonatomic) NSURL *compressedURL;
@property (weak, nonatomic) IBOutlet UIView *compressedContainer;
@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (strong, nonatomic) NSString *compressAlbumName;
@property (strong, nonatomic) Compresser *compresser;
@property (nonatomic, strong) ICloudVideoDownloader *downloader;
@property (nonatomic, strong) NSString *selectedPreset; // 记录用户选择的预设
@property (weak, nonatomic) IBOutlet CustomButtonView *highQuqlityCompressButton;
@property (weak, nonatomic) IBOutlet CustomButtonView *midQuqlityCompressButton;
@property (weak, nonatomic) IBOutlet CustomButtonView *lowQuqlityCompressButton;
@property (weak, nonatomic) IBOutlet CustomButtonView *playOrgVideoButton;
@property (weak, nonatomic) IBOutlet CustomButtonView *playCompressVideoButton;
@property (weak, nonatomic) IBOutlet CustomButtonView *saveToAlbumButton;
@property (weak, nonatomic) IBOutlet UIImageView *iCloudTagImageView;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
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
    self.sizeLabel.text = [NSString fileSizeStringWithNumber:self.orgData.fileSize];
    [self.orgImageView setImageWithAsset:_orgData.asset];
    [self.compressedImageView setImageWithAsset:_orgData.asset];
    [self initPickerView];
    self.title = [NSString localizedStringWithName:@"handle_compress"];
    
    self.topContainer.clipsToBounds = YES;
    self.topContainer.layer.cornerRadius = 8;
    
    self.compressedContainer.clipsToBounds = YES;
    self.compressedContainer.layer.cornerRadius = 8;
    
    if (self.orgData.asset.isFavorite){
        self.heartImageView.hidden = NO;
    } else {
        self.heartImageView.hidden = YES;
    }
    
    WEAK_SELF
    [VIDEO_DATA_MANAGER checkIfVideoIsOnlyInCloud:self.orgData.asset callback:^(AVAsset * _Nullable result) {
        STRONG_SELF
         strongSelf.iCloudTagImageView.hidden = (result != nil);
    }];

    
    [self.orgData loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
        STRONG_SELF
        strongSelf.compressedData = [[VideoDataManager sharedManager] assetDataByLocalIdentifier:bindData.compressedlocalIdentifier];
        if (strongSelf.compressedData != nil) {
            strongSelf.compressedContainer.hidden = false;
            [strongSelf.compressedImageView setImageWithAsset:strongSelf.orgData.asset];
            strongSelf.compressedSizeLabel.text = [NSString fileSizeStringWithNumber:strongSelf.compressedData.fileSize];
            
            [strongSelf.compressedData loadBindData:^(AssetBindData * _Nonnull compressBindData, AssetData * _Nonnull data) {
                strongSelf.compressQualityLabel.text = [compressBindData getQualityString];
            }];
            
        }
        
        strongSelf.qualityLabel.text = [bindData getQualityString];
    }];
    
    self.highQuqlityCompressButton.delegate = self;
    self.midQuqlityCompressButton.delegate = self;
    self.lowQuqlityCompressButton.delegate = self;
    self.playOrgVideoButton.delegate = self;
    self.playCompressVideoButton.delegate = self;
    self.saveToAlbumButton.delegate = self;
    // Do any additional setup after loading the view from its nib.
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
}

-(void)onButtonTap:(CustomButtonView *)view {
    if (view == self.highQuqlityCompressButton) {
        self.selectedPreset = kQualityHigh;
        [self showConfirmationAlertWithData:self.orgData preset:self.selectedPreset];
    } else if (view == self.midQuqlityCompressButton) {
        self.selectedPreset = kQualityMiddle;
        [self showConfirmationAlertWithData:self.orgData preset:self.selectedPreset];
        
    } else if (view == self.lowQuqlityCompressButton) {
        self.selectedPreset = kQualityLow;
        [self showConfirmationAlertWithData:self.orgData preset:self.selectedPreset];
    } else if (view == self.playOrgVideoButton) {
        [self playOrgVideoClicked];
    } else if (view == self.playCompressVideoButton) {
        [self playCompressedVideoClicked];
    } else if (view == self.saveToAlbumButton) {
        [self saveToAlbum];
    }
}

- (void)playOrgVideoClicked {
    VideoPlayerViewController *controller = [[VideoPlayerViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller playVideoWithAsset:self.orgData];
}


- (void)playCompressedVideoClicked {
    if (self.compressedURL != nil) {
        VideoPlayerViewController *controller = [[VideoPlayerViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller playVideoWithURL:self.compressedURL];
    } else if (self.compressedData != nil) {
        VideoPlayerViewController *controller = [[VideoPlayerViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller playVideoWithAsset:self.compressedData];
    }
}

- (void)saveToAlbum {
    if (self.compressedURL != nil) {
        WEAK_SELF
        [STORE_MANAGER getTotalVirtualCurrencyWithCompletion:^(NSUInteger value) {
            STRONG_SELF
            if (value < [strongSelf caculateCostCoins]) {
                [self.view showToastWithMessage:[NSString localizedStringWithName:@"coins_not_enough"]];
            } else {
                [self showSaveToAlbumAlert];
            }
        }];
        
    } else {
        [self.view showToastWithMessage:[NSString localizedStringWithName:@"already_in_album"]];
    }
}

- (NSInteger)caculateCostCoins {
    CGFloat orgSize = [self.orgData.fileSize floatValue];
    CGFloat compressSize = [self fileSizeWithURL:self.compressedURL];
    NSInteger optSize = floor(orgSize - compressSize);

    return optSize;
}

- (void)showSaveToAlbumAlert {
    WEAK_SELF
    CGFloat orgSize = [self.orgData.fileSize floatValue];
    CGFloat compressSize = [self fileSizeWithURL:self.compressedURL];
    NSInteger optSize = floor(orgSize - compressSize);
    
    if (optSize < 0) {
        optSize = 0;
    }
    
    NSString *message = [NSString localizedStringWithFormat:[NSString localizedStringWithName:@"save_to_album_message"], compressSize, orgSize, optSize, optSize];
    
    [AlertUtility showConfirmationAlertInViewController:self withTitle:[NSString localizedStringWithName:@"save_to_album"] message:message confirmButtonTitle:[NSString localizedConfirm] cancelButtonTitle:[NSString localizedCancel] completionHandler:^(BOOL confirmed) {
        STRONG_SELF
        if (confirmed) {
            [self createAlbumAndSaveCompressed:self.compressedURL cost:optSize];
        }
    }];
}


- (IBAction)onLowClicked:(id)sender {
    [self showConfirmationAlertWithData:self.orgData preset:AVAssetExportPresetLowQuality];
}


- (void)showConfirmationAlertWithData:(AssetData *)data preset:(NSString *)preset {
    WEAK_SELF
    [AlertUtility showConfirmationAlertInViewController:self withTitle:[NSString localizedStringWithName:@"compress_album_name"] message:[NSString localizedStringWithName:@"compress_sure"] confirmButtonTitle:[NSString localizedConfirm] cancelButtonTitle:[NSString localizedCancel] completionHandler:^(BOOL confirmed) {
        STRONG_SELF
        if (confirmed) {
            [[VideoDataManager sharedManager] checkIfVideoIsOnlyInCloud:data.asset callback:^(AVAsset * _Nullable result) {
                STRONG_SELF
                if (result == nil) {
                    [strongSelf showNetWorkConfirm:data preset:preset];
                } else {
                    //todo:
                    [strongSelf compressVideoWithAsset:data avAsset:result preset:preset];
                }
            }];
        }
    }];
}

- (void)showNetWorkConfirm:(AssetData *)data preset:(NSString *)preset {
    WEAK_SELF
    [AlertUtility showConfirmationAlertInViewController:self withTitle:[NSString localizedStringWithName:@"compress_album_name"] message:[NSString localizedStringWithName:@"download_to_compress"] confirmButtonTitle:[NSString localizedConfirm] cancelButtonTitle:[NSString localizedCancel] completionHandler:^(BOOL confirmed) {
        STRONG_SELF
        if (confirmed) {
            [ScreenUility setForceScreenOn:YES];
            strongSelf.downloader = [[ICloudVideoDownloader alloc] init];
            __block MBProgressHUD *hud = [ProgressHUDWrapper showProgressToView:strongSelf.view withString:[NSString localizedStringWithName:@"downloading"]];
            [strongSelf.downloader downloadVideoFromICloud:data.asset progressHandler:^(double progress) {
                STRONG_SELF
                hud.progress = progress;
            } completionHandler:^(AVAsset * _Nullable avAsset, NSError * _Nullable error) {
                STRONG_SELF
                [ScreenUility setForceScreenOn:NO];
                strongSelf.downloader = nil;
                [hud hideAnimated:YES];
                if (avAsset != nil) {
                    [strongSelf compressVideoWithAsset:data avAsset:avAsset preset:preset];
                } else {
                    [strongSelf.view showToastWithMessage:[NSString localizedStringWithName:@"download_fail"]];
                }
            }];
        }
    }];
}

- (void)compressVideoWithAsset:(AssetData *)data avAsset:(AVAsset *)avAsset preset:(NSString *)preset {
    if (self.compresser != nil) {
        [self.view showToastWithMessage:[NSString localizedStringWithName:@"not_dupliacte"]];
        return;
    }
    
    self.compresser = [[Compresser alloc] init];
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
    
    
    [ScreenUility setForceScreenOn:YES];
    WEAK_SELF
    [self.compresser compressVideoWithAsset:avAsset preset:preset completion:^(BOOL succeed, NSURL * _Nullable fileURL, NSString * _Nonnull errMsg) {
        [beginCompressHUD hideAnimated:YES];
        [ScreenUility setForceScreenOn:NO];
        STRONG_SELF
        strongSelf.compresser = nil;
        if (succeed) {
            NSData *compressedData = [NSData dataWithContentsOfURL:fileURL];
            CGFloat compressedSizeMB = compressedData.length / (1024.0 * 1024.0);
            strongSelf.compressedContainer.hidden = false;
            [strongSelf.compressedImageView setImageWithAsset:strongSelf.orgData.asset];
            strongSelf.compressedSizeLabel.text = [NSString fileSizeStringWithNumber:[NSNumber numberWithFloat:compressedSizeMB]];
            strongSelf.compressedURL = fileURL;
            strongSelf.compressedData = nil;
            strongSelf.compressQualityLabel.text = preset;
        } else {
            [strongSelf.view showToastWithMessage:@""];
        }
    }];
}

- (CGFloat)fileSizeWithURL:(NSURL *)fileURL {
    CGFloat fizeSize = 0;
    if (fileURL != nil) {
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
        fizeSize = fileData.length / (1024.0 * 1024.0);
    }
    
    return fizeSize;
}

- (void)createAlbumAndSaveCompressed:(NSURL *)compressedURL cost:(NSInteger)costCoins {
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
                    [self saveCompressedVideo:compressedURL cost:costCoins];
                }];
            }
        }];
    } else {
        [self saveCompressedVideo:compressedURL cost:costCoins];
    }
}

- (void)saveCompressedVideo:(NSURL *)compressedURL cost:(NSInteger)costCoins {
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
                }];
                
            }];
            [GCDUtility executeOnMainThread:^{
                [ActivityIndicatorUtility hideActivityIndicatorInView:strongSelf.view];
                [strongSelf showHintAlert];
            }];
            
            [STORE_MANAGER subVirtualCurrency:costCoins completion:^(BOOL result) {
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
    WEAK_SELF
    [AlertUtility showConfirmationAlertInViewController:self withTitle:[NSString localizedStringWithName:@"save_success"] message:[NSString localizedStringWithName:@"save_success_tip"] confirmButtonTitle:[NSString localizedStringWithName:@"delete"] cancelButtonTitle:[NSString localizedStringWithName:@"not_delete"]  completionHandler:^(BOOL confirmed) {
        STRONG_SELF
        if (confirmed) {
            [VIDEO_DATA_MANAGER deleteVideoAsset:self.orgData completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [[[UIApplication sharedApplication] keyWindow] showToastWithMessage:[NSString localizedStringWithName:@"delete_succees_detail"]];
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    [strongSelf.view showToastWithMessage:[NSString localizedStringWithName:@"move_to_todelete"]];
                }
            }];
        } else {
            [strongSelf.view showToastWithMessage:[NSString localizedStringWithName:@"move_to_todelete"]];
        }
    }];
}

- (void)deleteVideoAsset:(PHAsset *)asset completionHandler:(void(^)(BOOL success, NSError * _Nullable error))completion {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 请求删除指定的 PHAsset
        [PHAssetChangeRequest deleteAssets:@[asset]];
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

- (void)leftButtonTapped {
    if ([self.compresser isCompressing]) {
        [self.view showToastWithMessage:[NSString localizedStringWithName:@"back_block_by_compressing"]];
    } else {
        if (self.downloader != nil) {
            [self.downloader cancel];
        }
        [super leftButtonTapped];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.compresser isCompressing]) {
        return NO;
    } else if (self.downloader) {
        return NO;
    } else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
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
