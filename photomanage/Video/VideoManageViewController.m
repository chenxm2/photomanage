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

@interface VideoManageViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<AssetData *> *sortedData;
@property (nonatomic, assign) Boolean isInitCollectionView;
@end

@implementation VideoManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VideoManageViewController viewDidLoad");
    // Do any additional setup after loading the view.
    [ActivityIndicatorUtility showActivityIndicatorInView:self.view];
    WEAK_SELF
    [[VideoDataManager sharedManager] fetchVideosSortedBySize:^(NSArray<AssetData *> * _Nonnull dataList) {
       STRONG_SELF
        [ActivityIndicatorUtility hideActivityIndicatorInView:strongSelf.view];
        strongSelf.sortedData = dataList;
        [strongSelf.collectionView reloadData];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCollectionView];
    if ([self.sortedData count] > 0) {
        [self.collectionView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ActivityIndicatorUtility hideActivityIndicatorInView:self.view];
    [super viewWillDisappear:animated];
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
    return [self.sortedData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VideoViewCell reuseIdentifier] forIndexPath:indexPath];

    [cell updateAssetData:self.sortedData[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AssetData *data = self.sortedData[indexPath.row];
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
