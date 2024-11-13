//
//  VideoPlayerViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import "VideoPlayerViewController.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import "AssetData.h"
#import "VideoDataManager.h"
#import "ICloudVideoDownloader.h"

@interface VideoPlayerViewController ()
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property (nonatomic, strong) AssetData *assetData;
@property (nonatomic, strong) ICloudVideoDownloader *downloader;
@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化 AVPlayerViewController
    self.playerViewController = [[AVPlayerViewController alloc] init];
    self.playerViewController.view.frame = self.view.bounds;
    self.playerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerViewController.showsPlaybackControls = YES;
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    
    [self.playerViewController didMoveToParentViewController:self];
    self.title = [NSString localizedStringWithName:@"play_video"];
    
    [self overwriteRightBarButton];
    
}

- (void)overwriteRightBarButton {
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction)];
    
    // 设置文字颜色
    [deleteButton setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
    
    // 将UIBarButtonItem添加到导航项
    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)deleteAction {
    if (self.assetData == nil) {
        [self.view showToastWithMessage:[NSString localizedStringWithName:@"no_need_delete"]];
    } else {
        if (self.downloader != nil ){
            [self.view showToastWithMessage:[NSString localizedStringWithName:@"delete_downloading"]];
        } else {
            [VIDEO_DATA_MANAGER deleteVideoAsset:self.assetData completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [[[UIApplication sharedApplication] keyWindow] showToastWithMessage:[NSString localizedStringWithName:@"delete_succees"]];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    // do nothing
                }
            }];
        }
    }
}

#pragma mark - Public Methods

// 播放本地 NSURL 视频
- (void)playVideoWithURL:(NSURL *)url {
    [self loadViewIfNeeded];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    self.playerViewController.player = player;
    [self.playerViewController.player play];
}

// 播放 PHAsset 视频
- (void)playVideoWithAsset:(AssetData *)assetData {
    self.assetData = assetData;
    [self loadViewIfNeeded];
    
    WEAK_SELF
    [VIDEO_DATA_MANAGER checkIfVideoIsOnlyInCloud:assetData.asset callback:^(AVAsset * _Nullable result) {
        STRONG_SELF
        if (result != nil) {
            [strongSelf playLocalAsset:result assetData:assetData];
        } else {
            [strongSelf showNetWorkConfirm:assetData];
        }
    }];
    
    [self updateTitleIfNeed];
}

- (void)showNetWorkConfirm:(AssetData *)assetData {
    WEAK_SELF
    [AlertUtility showConfirmationAlertInViewController:self withTitle:[NSString localizedStringWithName:@"play_video"] message:[NSString localizedStringWithName:@"download_to_play"] confirmButtonTitle:[NSString localizedConfirm] cancelButtonTitle:[NSString localizedCancel] completionHandler:^(BOOL confirmed) {
        STRONG_SELF
        if (confirmed) {
            strongSelf.downloader = [[ICloudVideoDownloader alloc] init];
                
            __block MBProgressHUD *hud = [ProgressHUDWrapper showProgressToView:strongSelf.view withString:[NSString localizedStringWithName:@"downloading"]];
            [strongSelf.downloader downloadVideoFromICloud:assetData.asset progressHandler:^(double progress) {
                STRONG_SELF
                hud.progress = progress;
            } completionHandler:^(AVAsset * _Nullable avAsset, NSError * _Nullable error) {
                strongSelf.downloader = nil;
                [hud hideAnimated:YES];
                STRONG_SELF
                if (avAsset != nil) {
                    [strongSelf playLocalAsset:avAsset assetData:assetData];
                } else {
                    [strongSelf.view showToastWithMessage:[NSString localizedStringWithName:@"download_fail"]];
                    }
            }];
        }
    }];
}

- (void)playLocalAsset:(AVAsset *)avAsset assetData:(AssetData *)assetData {
    if (assetData.asset.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate) {
        [self playSlowMotionVideoWithPHAsset:avAsset];
    } else {
        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
            NSURL *url = [(AVURLAsset *)avAsset URL];
            WEAK_SELF
            [GCDUtility executeOnMainThread:^{
                STRONG_SELF
                [strongSelf playVideoWithURL:url]; // 使用 URL 播放视频
            }];
        }
    }
}

- (void)playSlowMotionVideoWithPHAsset:(AVAsset *)avAsset {
    if ([avAsset isKindOfClass:[AVComposition class]]) {
        
        AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        CGSize videoSize = videoTrack.naturalSize;
        LogInfo(@"Video size: %@", NSStringFromCGSize(videoSize));
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
        AVComposition *composition = (AVComposition *)avAsset;
        
        // 获取视频的AVVideoComposition
        AVVideoComposition *videoComposition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:composition];
        
        
        playerItem.videoComposition = videoComposition;
        
        WEAK_SELF
        [GCDUtility executeOnMainThread:^{
            STRONG_SELF
            [strongSelf loadViewIfNeeded];
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
            
            strongSelf.playerViewController.player = player;
            [strongSelf.playerViewController.player play];
        }];
    }
}

- (void)updateTitleIfNeed {
    if (self.assetData != nil) {
        NSDate *creationDate = self.assetData.asset.creationDate;
        // 创建NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式，例如："yyyy年MM月dd日 HH:mm"
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        // 将NSDate对象格式化为字符串
        NSString *formattedDate = [dateFormatter stringFromDate:creationDate];
        self.title = formattedDate;
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
