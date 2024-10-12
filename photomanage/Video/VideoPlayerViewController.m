//
//  VideoPlayerViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import "VideoPlayerViewController.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>

@interface VideoPlayerViewController ()
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
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
    self.playerViewController.showsPlaybackControls = YES;
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    
    [self.playerViewController didMoveToParentViewController:self];
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
- (void)playVideoWithAsset:(PHAsset *)asset {
    if (asset.mediaType != PHAssetMediaTypeVideo) {
        NSLog(@"This PHAsset is not a video.");
        return;
    }
    
    [self loadViewIfNeeded];
    
    // 获取 PHAsset 的视频资源 URL
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES; // 允许从iCloud下载视频
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
            NSURL *url = [(AVURLAsset *)avAsset URL];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playVideoWithURL:url]; // 使用 URL 播放视频
            });
        }
    }];
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
