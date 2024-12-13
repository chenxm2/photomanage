//
//  VideoManageViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/9/2.
//

#import "VideoManageViewController.h"
#import "VideoViewCell.h"
#import "VideoCompressViewController.h"
#import "AssetData.h"
#import "VideoDataManager.h"
#import "BaseConfiguration.h"
#import "GoodsViewController.h"
#import "SettingsViewController.h"

NSString * const kSortType = @"VideosortType";

@interface VideoManageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CustomButtonViewDelegate, VideoViewCellDelegate, StoreManagerObserver>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<AssetData *> *showDatas;
@property (nonatomic, assign) Boolean isInitCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmented;
@property (nonatomic, assign) FilterType currentFilterType;
@property (weak, nonatomic) IBOutlet CustomButtonView *sortButton;
@property (nonatomic, assign) SortType curretSortType;
@property (weak, nonatomic) IBOutlet UIButton *testClearCoinsAndState;
@property (weak, nonatomic) IBOutlet UIView *downImageView;
@property (weak, nonatomic) IBOutlet UIView *upImageView;
@end

@implementation VideoManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VideoManageViewController viewDidLoad");
    self.curretSortType = [UserDefaultsManager integerForKey:kSortType];
    [self updateSortButtonByType:self.curretSortType];
    self.currentFilterType = FilterTypeUnCompress;
    self.filterSegmented.selectedSegmentIndex = 0;
    if (@available(iOS 13.0, *)) {
        self.filterSegmented.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    self.collectionView.backgroundColor = [UIColor clearColor];
    self.title = [NSString localizedStringWithName:@"video_compress"];
    // Do any additional setup after loading the view.
    self.sortButton.delegate = self;
    
    [self overwriteLeftBarButton];
    [self configureRightButton];
    
//#ifdef DEBUG
    self.testClearCoinsAndState.hidden = NO;
//#else
//#endif
    
    [STORE_MANAGER addObserver:self];
    WEAK_SELF
    [STORE_MANAGER getTotalVirtualCurrencyWithCompletion:^(NSUInteger value) {
        STRONG_SELF
        [strongSelf updateLeftButtonText:[NSString virtualCurrencyStringWithValue:value]];
    }];
    
    // 创建 UITapGestureRecognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollDown:)];
    [self.downImageView addGestureRecognizer:tapGesture];
    
    // 创建 UITapGestureRecognizer
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollUp:)];
    [self.upImageView addGestureRecognizer:tapGesture];
    
}

- (void)configureRightButton {
    UIImage *buttonImage = [[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];; // 替换为你的图标名称    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTapped)];
}

// 按钮点击事件
- (void)rightBarButtonTapped {
    SettingsViewController *controller = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)overwriteLeftBarButton {
    [self configureLeftButtonText:@"0"
                             image:[BaseConfiguration coinsItemImg]  textColor:[BaseConfiguration darkGrayColor]];
}



- (void)configureLeftButtonText:(NSString *)text
                           image:(UIImage *)image
                       textColor:(UIColor * _Nullable)color {
    if (!color) {
        color = [BaseConfiguration buttonTextColor]; // 使用默认文字颜色
    }
    
    int imageSize = 16;
    int margin = 8; // 标签和图片之间的间距
    int sidePadding = 12; // 左右边距
    int customViewHeight = 26;
    
    // 创建图片视图
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tag = 101; // 给子视图打标签方便查找
    imageView.frame = CGRectMake(sidePadding, (customViewHeight - imageSize) / 2, imageSize, imageSize);
    
    // 创建标签
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [ColorUtility colorWithHexString:@"#FF1A1A1A"];
    label.textAlignment = NSTextAlignmentRight;
    label.tag = 102; // 给子视图打标签方便查找
    [label sizeToFit]; // 自动调整标签的大小以适应文本内容
    
    // 计算自定义视图的宽度
    int customViewWidth = label.frame.size.width + imageSize + margin + (2 * sidePadding);
    
    // 创建自定义视图
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, customViewWidth, customViewHeight)];
    customView.backgroundColor = [UIColor clearColor];
    customView.layer.borderColor = color.CGColor;
    customView.layer.borderWidth = 1.0;
    customView.layer.cornerRadius = customViewHeight / 2;
    customView.layer.masksToBounds = YES;
    
    // 调整标签的位置
    label.frame = CGRectMake(sidePadding + imageSize + margin, 0, label.frame.size.width, customViewHeight);
    
    // 添加图片和标签到自定义视图中
    [customView addSubview:imageView];
    [customView addSubview:label];
    
    // 创建一个 UITapGestureRecognizer，添加到自定义视图
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonClicked:)];
    [customView addGestureRecognizer:tapGesture];
    customView.userInteractionEnabled = YES; // 使自定义视图可交互
    
    // 将自定义视图设置为导航项的左侧按钮
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)updateLeftButtonText:(NSString *)text {
    UIView *customView = self.navigationItem.leftBarButtonItem.customView;
    if (!customView) {
        return;
    }
    
    UILabel *label = [customView viewWithTag:102]; // 找到标签
    UIImageView *imageView = [customView viewWithTag:101]; // 找到图片视图
    if (!label || !imageView) {
        return;
    }
    
    // 更新文本
    label.text = text;
    [label sizeToFit];
    
    // 重新计算布局
    int imageSize = 16;
    int margin = 8; // 标签和图片之间的间距
    int sidePadding = 12; // 左右边距
    int customViewHeight = customView.frame.size.height;
    int customViewWidth = label.frame.size.width + imageSize + margin + (2 * sidePadding);
    
    // 更新视图的宽度
    customView.frame = CGRectMake(0, 0, customViewWidth, customViewHeight);
    
    // 调整子视图的位置
    imageView.frame = CGRectMake(sidePadding, (customViewHeight - imageSize) / 2, imageSize, imageSize);
    label.frame = CGRectMake(sidePadding + imageSize + margin, 0, label.frame.size.width, customViewHeight);
}

- (void)leftButtonClicked:(id)button {
    [GoodsViewController goToGoodsViewController:self.navigationController];
}

- (void)fetchPhotosIfAuthorized {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusAuthorized) {
        // 用户已授权，直接执行相册操作
        [self handleParamChange];
        [self showResumeBuyAlertIfNeed];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        // 请求权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (newStatus == PHAuthorizationStatusAuthorized) {
                    // 用户授予权限，执行相册操作
                    [self handleParamChange];
                } else {
                    // 用户拒绝权限或受限
                    [self handleAuthorizationDenied];
                }
            });
        }];
    } else {
        // 用户已拒绝权限或权限受限
        [self handleAuthorizationDenied];
    }
}

- (void)handleAuthorizationDenied {
    [self.view showToastWithMessage:[NSString localizedStringWithName:@"permission_fail"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCollectionView];
    [self fetchPhotosIfAuthorized];
}

- (void)updateSortButtonByType:(SortType)sortType {
    NSString *showString = nil;
    if (SortTypeBySize == sortType) {
        showString = [NSString localizedStringWithName:@"sort_by_size"];
    } else {
        showString = [NSString localizedStringWithName:@"sort_by_time"];
    }
    
    [self.sortButton setButtonText:showString];
}

-(void)onButtonTap:(CustomButtonView *)view {
    // 创建 UIAlertController 实例，这里以 actionSheet 样式为例
    WEAK_SELF
    NSString *title = [NSString localizedStringWithName:@"sort_option"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加按钮
    
    NSString *byTime = [NSString localizedStringWithName:@"sort_by_time"];
    [alertController addAction:[UIAlertAction actionWithTitle:byTime style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        STRONG_SELF
        strongSelf.curretSortType = SortTypeByTime;
        [strongSelf updateSortButtonByType:strongSelf.curretSortType];
        [strongSelf handleParamChange];
        [UserDefaultsManager setInteger:strongSelf.curretSortType forKey:kSortType];
    }]];
    
    NSString *bySize = [NSString localizedStringWithName:@"sort_by_size"];
    [alertController addAction:[UIAlertAction actionWithTitle:bySize style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        STRONG_SELF
        strongSelf.curretSortType = SortTypeBySize;
        [strongSelf updateSortButtonByType:strongSelf.curretSortType];
        [UserDefaultsManager setInteger:strongSelf.curretSortType forKey:kSortType];
        [strongSelf handleParamChange];
        // 按大小排序的操作
        NSLog(@"Sort by size");
    }]];
    
    // 添加取消按钮
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedCancel] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }]];
    
    // 呈现 UIAlertController
    [self presentViewController:alertController animated:YES completion:nil];
}



- (IBAction)handleFilterChanged:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.currentFilterType = FilterTypeUnCompress;
            break;
        case 1:
            self.currentFilterType = FilterTypeCompressResult;
            break;
        case 2:
            self.currentFilterType = FilterTypeWaitDelete;
            break;
    }
    
    [self handleParamChange];
}

- (void)handleParamChange {
    WEAK_SELF
    __block MBProgressHUD *hud = nil;
    if (self.showDatas == nil || [self.showDatas count] == 0) {
        hud = [ProgressHUDWrapper showLoadingToView:nil withString:[NSString localizedLoading]];
        hud.userInteractionEnabled = YES;
    }
    
    [[VideoDataManager sharedManager] fetchVideosWithSortedType:self.curretSortType filterType:self.currentFilterType middleData:nil completion:^(NSArray<AssetData *> * _Nonnull dataList) {
        STRONG_SELF
        [ProgressHUDWrapper hideHUDForView:nil];
        strongSelf.showDatas = dataList;
        [strongSelf.collectionView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)initCollectionView
{
    if (_isInitCollectionView) {
        return;
    }
    _isInitCollectionView = true;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.view.frame.size.width / 3 - 1, self.view.frame.size.width / 3 - 1); // 根据需要设置cell大小
    layout.minimumInteritemSpacing = 1; // 设置最小列间距
    layout.minimumLineSpacing = 1; // 设置最小行间距
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoViewCell" bundle:nil] forCellWithReuseIdentifier:[VideoViewCell reuseIdentifier]];
    
    [self.collectionView setCollectionViewLayout:layout];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)onDeleteButtonTap:(VideoViewCell *)cell data:(AssetData *)data {
    WEAK_SELF
    [VIDEO_DATA_MANAGER deleteVideoAsset:data completionHandler:^(BOOL success, NSError * _Nullable error) {
        STRONG_SELF
        if (success) {
            [strongSelf.view showToastWithMessage:[NSString localizedStringWithName:@"delete_succees"]];
            [strongSelf handleParamChange];
        }
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.showDatas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VideoViewCell reuseIdentifier] forIndexPath:indexPath];
    cell.delegete = self;
    
    BOOL showDelete = NO;
    if (self.currentFilterType == FilterTypeWaitDelete) {
        showDelete = YES;
    }
    
    BOOL shouldShowViewed = NO;
    if (self.currentFilterType == FilterTypeUnCompress) {
        shouldShowViewed = YES;
    }
    
    [cell updateAssetData:self.showDatas[indexPath.row] showDelete:showDelete shouldShowViewd:shouldShowViewed];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AssetData *data = self.showDatas[indexPath.row];
    VideoCompressViewController *controller = [[VideoCompressViewController alloc] initWithAssetData:data];
    [self.navigationController pushViewController:controller animated:YES];        
}

#pragma mark - StoreManagerObserver
- (void)onVirtualCurrencyUpdate:(NSUInteger)virtualCurrency {
    [self updateLeftButtonText:[NSString virtualCurrencyStringWithValue:virtualCurrency]];
}

- (void)onLastPurchaseInterrupt:(BOOL)isInterrupt {
    if (isInterrupt) {
        [self showResumeBuyAlert];
    }
}

- (void)showResumeBuyAlertIfNeed {
    if ([STORE_MANAGER isLastPurchaseInterrupt]) {
        [self showResumeBuyAlert];
    }
}

- (void)showResumeBuyAlert {
    [AlertUtility showConfirmationAlertInViewController:self.navigationController.topViewController withTitle:[NSString localizedStringWithName:@"buy_resume"] message:[NSString localizedStringWithName:@"buy_resume_message"] confirmButtonTitle:[NSString localizedConfirm] cancelButtonTitle:[NSString localizedCancel] completionHandler:^(BOOL confirmed) {
        if (confirmed) {
            WEAK_SELF
            [STORE_MANAGER resumeInterruptProductSuccess:^{
                STRONG_SELF
                [strongSelf.navigationController.topViewController.view showToastWithMessage:[NSString localizedStringWithName:@"buy_success"]];
            } failure:^(NSError * _Nonnull error) {
                STRONG_SELF
                [strongSelf.navigationController.topViewController.view showToastWithMessage:[NSString localizedStringWithName:@"buy_fail"]];
            }];
        } else {
            
        }
    }];
}


#pragma mark - Test
- (IBAction)clearCoinsAndState:(id)sender {
    WEAK_SELF
    [STORE_MANAGER clearCoinsAndState:^{
       STRONG_SELF
        [strongSelf.view showToastWithMessage:@"清除成功"];
    }];
}

#pragma mark - Scroll up and down
- (void)scrollDown:(id)sender {
    [self scrollToBottom];
}

- (void)scrollUp:(id)sender {
    [self scrollToTop];
}

- (void)scrollToTop {
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

- (void)scrollToBottom {
    NSInteger lastSection = [self.collectionView numberOfSections] - 1;
    if (lastSection >= 0) {
        NSInteger lastItem = [self.collectionView numberOfItemsInSection:lastSection] - 1;
        if (lastItem >= 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:lastItem inSection:lastSection];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }
    }
}

- (IBAction)addCoins:(id)sender {
    [STORE_MANAGER addVirtualCurrency:100 completion:^(BOOL result) {
        
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
