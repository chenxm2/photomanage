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

NSString * const kSelectIndex = @"VideoManage_SelectIndex";

@interface VideoManageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CustomButtonViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<AssetData *> *showDatas;
@property (nonatomic, assign) Boolean isInitCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmented;
@property (nonatomic, assign) FilterType currentFilterType;
@property (weak, nonatomic) IBOutlet CustomButtonView *sortButton;
@property (nonatomic, assign) SortType curretSortType;
@end

@implementation VideoManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VideoManageViewController viewDidLoad");
    self.curretSortType = SortTypeByTime;
    self.currentFilterType = FilterTypeUnCompress;
    self.filterSegmented.selectedSegmentIndex = 0;
    if (@available(iOS 13.0, *)) {
        self.filterSegmented.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    self.title = [NSString localizedStringWithName:@"video_compress"];
    // Do any additional setup after loading the view.
    self.sortButton.delegate = self;
}

- (BOOL)shouldShowLeftButton {
    return NO;
}

- (BOOL)shouldShowRightButton {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCollectionView];
    [self handleParamChange];
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
        [strongSelf.sortButton setButtonText:byTime];

        [strongSelf handleParamChange];
    }]];
    
    NSString *bySize = [NSString localizedStringWithName:@"sort_by_size"];
    [alertController addAction:[UIAlertAction actionWithTitle:bySize style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        STRONG_SELF
        strongSelf.curretSortType = SortTypeBySize;
        [strongSelf.sortButton setButtonText:bySize];
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
            self.currentFilterType = FilterTypeUnCompressResult;
            break;
        case 2:
            self.currentFilterType = FilterTypeCompressed;
            break;
    }
    
    [self handleParamChange];
}

- (void)handleParamChange {
    WEAK_SELF
    if (self.showDatas == nil || [self.showDatas count] == 0) {
        [ProgressHUDWrapper showLoadingToView:self.view withString:[NSString localizedLoading]];
    }
    
    [[VideoDataManager sharedManager] fetchVideosWithSortedType:self.curretSortType filterType:self.currentFilterType completion:^(NSArray<AssetData *> * _Nonnull dataList) {
        STRONG_SELF
        [ProgressHUDWrapper hideHUDForView:strongSelf.view];
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


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.showDatas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VideoViewCell reuseIdentifier] forIndexPath:indexPath];

    [cell updateAssetData:self.showDatas[indexPath.row] isSelected:NO];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AssetData *data = self.showDatas[indexPath.row];
    VideoCompressViewController *controller = [[VideoCompressViewController alloc] initWithAssetData:data];
    [self.navigationController pushViewController:controller animated:YES];        
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
