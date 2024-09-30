//
//  ViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import "PhotoManageViewController.h"
#import "UIKit/UICollectionView.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoPreviewController.h"
#import "AllPhotoView.h"
#import "Masonry.h"
#import "PhotoPreviewController.h"
#import "ConfirmDeleteController.h"

@interface PhotoManageViewController () <AllPhotoViewDelegate, PhotoPreviewControllerDelegate, ConfirmDeleteControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
@property (weak, nonatomic) IBOutlet UIButton *deletedButton;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *originAssetsArray;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *deleteAssetsArray;
@property (assign) Boolean isShow;
@property (nonatomic, strong) PHAsset *selectAsset;
@property (nonatomic, strong) AllPhotoView *allShowView;
@property (nonatomic, strong) PhotoPreviewController *photoPreviewController;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@end

@implementation PhotoManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShow = NO;
    self.navigationItem.title = @"相册";
    self.title = @"相册";
    self.tabBarController.title = @"相册";
    self.originAssetsArray = [[NSMutableArray alloc] init];
    self.deleteAssetsArray = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.originAssetsArray count] == 0) {
        [self getAuth];
    } else {
        
    }
}

//- (void)viewSafeAreaInsetsDidChange {
//    [super viewSafeAreaInsetsDidChange];
//    // 根据safeAreaInsets调整视图布局
//    self.vi.frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)getAuth {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        // 用户尚未做出选择，可以请求权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
            if (newStatus == PHAuthorizationStatusAuthorized) {
                // 用户授予权限，可以访问相册
                [self fetchAssets];
            } else {
                // 用户拒绝权限，可以在这里提示用户去设置中开启权限
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        // 权限已被授予，可以访问相册
        [self fetchAssets];
    }
}

- (void)fetchAssets {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    // 可以根据需要设置options，例如过滤图片
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:options];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
        // 对每个PHAsset对象进行操作
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [self.originAssetsArray addObject:asset];
        }
    }];
    
    NSLog(@"fetchAssets end");
    
    if ([self.originAssetsArray count] == 0) {
        return;
    }
    
    self.selectAsset = [self.originAssetsArray objectAtIndex:0];
    
    NSLog(@"fetchAssets count = %lu", (unsigned long)fetchResult.count);
    [self initPhotoPreviewController];

}

- (void)initPhotoPreviewController
{
    if (self.photoPreviewController != nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    // 获取当前时间
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));

    // 指定延时执行的队列，这里使用主队列来更新UI
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 执行延时任务
    dispatch_after(popTime, queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.photoPreviewController == nil) {
                strongSelf.photoPreviewController = [PhotoPreviewController viewControllerWithParameter:strongSelf.originAssetsArray deleteArray:strongSelf.deleteAssetsArray selectAsset:strongSelf.selectAsset];
                [strongSelf addChildViewController:strongSelf.photoPreviewController];
                strongSelf.photoPreviewController.delegate = strongSelf;
                [strongSelf.view addSubview:strongSelf.photoPreviewController.view];
                [strongSelf.photoPreviewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(strongSelf.view.mas_left);
                    make.top.equalTo(strongSelf.bottomBar.mas_bottom);
                    make.right.mas_equalTo(strongSelf.view.mas_right);
//                    make.bottom.mas_equalTo(strongSelf.view.mas_bottom);
                    make.bottom.equalTo(self.view.mas_bottom).offset(-self.tabBarController.tabBar.frame.size.height); // 与 UITabBar 的底部对齐
                }];
            }
            [strongSelf updateNumberLabel];
        }
    });
}

- (IBAction)showOrHide:(id)sender {
    _isShow = !_isShow;
    if (_isShow) {
        if (self.allShowView == nil) {
            self.allShowView = [AllPhotoView viewWithParameter:[self getExsitArray] selectAsset:self.selectAsset frame:self.view.frame];
            self.allShowView.delegate = self;
            [self.view addSubview:self.allShowView];
            
            [self.allShowView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view.mas_left);
                make.top.equalTo(self.bottomBar.mas_bottom).offset(10);
                make.right.mas_equalTo(self.view.mas_right);
                make.bottom.mas_equalTo(self.view.mas_bottom).offset(-60);
            }];
        }
    } else {
        if (self.allShowView != nil) {
            [self dismissAllPhotoView];
        }
    }
    
    [self updateShowButtonText];
}

- (NSMutableArray<PHAsset *> *)getExsitArray
{
    NSMutableArray<PHAsset *> * res = [[NSMutableArray alloc] init];
    [self.originAssetsArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [res addObject:obj];
    }];
    [res removeObjectsInArray:self.deleteAssetsArray];
    return res;
}

- (void)updateShowButtonText
{
    if (_isShow) {
        [self.showHideButton setImage:[UIImage imageNamed:@"icon_group_prev"] forState:UIControlStateNormal];
        [self.showHideButton setTitle:@"收起" forState:UIControlStateNormal];
    } else {
        [self.showHideButton setImage:[UIImage imageNamed:@"icon_group_next"] forState:UIControlStateNormal];
        [self.showHideButton setTitle:@"展开" forState:UIControlStateNormal];
    }
}

- (void)didSelect:(PHAsset *)asset {
    [self.allShowView removeFromSuperview];
    self.allShowView = nil;
    self.isShow = NO;
    [self updateShowButtonText];
    self.selectAsset = asset;
    [self.photoPreviewController updateWithAsset:asset];
}

- (void)dismissAllPhotoView {
    [self.allShowView removeFromSuperview];
    self.allShowView = nil;
}

- (IBAction)hasDeleted:(id)sender {
    [self.allShowView removeFromSuperview];
    self.allShowView = nil;
    self.isShow = NO;
    ConfirmDeleteController *confirm = [[ConfirmDeleteController alloc] init];
    confirm.deleteAssetsArray = self.deleteAssetsArray;
    confirm.delegate = self;
    [self updateShowButtonText];
    [self.navigationController pushViewController:confirm animated:YES];
}

- (void)didPhotoPreviewSelectPHAsset:(PHAsset *)asset 
{
    self.selectAsset = asset;
}

- (void)didPhotoPreviewDeleteCountChange {
    NSString *deleteText = [NSString stringWithFormat:@"%lu", (unsigned long)[self.deleteAssetsArray count]];
    [self.deletedButton setTitle:deleteText forState:UIControlStateNormal];
    [self updateNumberLabel];
}

- (void)confirmDelete:(NSMutableArray<PHAsset *> *)array {
    [self.originAssetsArray removeObjectsInArray:array];
    [self updateNumberLabel];
}

- (void)updateNumberLabel
{
    long sum = self.originAssetsArray.count - self.deleteAssetsArray.count;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", sum];
}
@end
