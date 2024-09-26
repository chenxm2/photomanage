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

@interface VideoManageViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *sourceVideoArray;
@property (nonatomic, strong) NSMutableArray<AssetData *> *sortedData;
@property (nonatomic, assign) Boolean isInitCollectionView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VideoManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sourceVideoArray = [[NSMutableArray alloc] init];
    self.sortedData = [[NSMutableArray alloc] init];
    NSLog(@"VideoManageViewController viewDidLoad");
    
    // 初始化 activityIndicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.view.center; // 设置在视图中心
    self.activityIndicator.hidesWhenStopped = YES; // 停止时隐藏
    
    // 将 activityIndicator 添加到视图中
    [self.view addSubview:self.activityIndicator];
    // Do any additional setup after loading the view.
}

- (void)showLoading {
    [self.activityIndicator startAnimating];
}

- (void)hideLoading {
    [self.activityIndicator stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCollectionView];
    if ([self.sortedData count] > 0) {
        [self.collectionView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchVideosSortedBySize];

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
    NSLog(@"fetchAssets count = %lu", (unsigned long)self.sourceVideoArray.count);
    return [self.sortedData count];
}

- (void)fetchVideosSortedBySize {
    
    [GCDUtility executeOnSerialQueue:^{
        if ([self.sortedData count] == 0) {
            [GCDUtility executeOnMainThread:^{
                            [self showLoading];
            }];
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
            // 可以根据需要设置options，例如过滤图片
            PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
            [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
                // 对每个PHAsset对象进行操作
                [self.sourceVideoArray addObject:asset];
            }];
            
            for (PHAsset *asset in self.sourceVideoArray) {
                NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                PHAssetResource *videoResource = nil;
                
                
                for (PHAssetResource *resource in resources) {
                    if (resource.type == PHAssetResourceTypeVideo) {
                        videoResource = resource;
                        break;
                    }
                }
                
                unsigned long long fileSize = [[videoResource valueForKey:@"fileSize"] unsignedLongLongValue];
                CGFloat fileSizeMB = fileSize / (1024.0 * 1024.0); // 转换为MB
                AssetData *data = [[AssetData alloc] initWithAsset:asset andNumber:@(fileSizeMB)];
            // 保存资产和大小
                [self.sortedData addObject:data];
            }
            [self handleCompleteLoad];
        }
    }];
}

- (void)handleCompleteLoad {
    NSLog(@"handleCompleteLoad");
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileSize" ascending:NO];
    [self.sortedData sortUsingDescriptors:@[sortDescriptor]];
    
    [GCDUtility executeOnMainThread:^{
            [self hideLoading];
            [self.collectionView reloadData];
    }];
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
    
//    [self showConfirmationAlertWithData:data];
    
    
//    PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
//            videoRequestOptions.version = PHVideoRequestOptionsVersionOriginal;
//            videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
//    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:videoRequestOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//            AVAsset *avAsset = asset;
//    
//        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
//            AVURLAsset *videoAsset = (AVURLAsset *)avAsset;
//            
//            [videoAsset loadValuesAsynchronouslyForKeys:@"" completionHandler:^{
//                            
//            }];
            
//            NSError *error = nil;
//            NSDictionary *values = [videoAsset.URL resourceValuesForKeys:@[NSURLFileSizeKey] error:&error];
//            if (error) {
//                NSLog(@"Error getting file size: %@", error.localizedDescription);
//            } else {
//                NSNumber *fileSize = values[NSURLFileSizeKey];
//                if (fileSize) {
//                    long long sizeInBytes = [fileSize longLongValue];
//                    double sizeInMegabytes = sizeInBytes / (1024.0 * 1024.0);
//                    NSLog(@"Video file size: %lld bytes (%.2f MB)", sizeInBytes, sizeInMegabytes);
//                } else {
//                    NSLog(@"File size key not found in resource values");
//                }
//            }
            
//        }
            
            
//            NSString *originalSize = [NSString stringWithFormat:@"%.2f MB", (float)[videoAsset URL] length / (1024 * 1024)];
//                            NSLog(@"Original Video Size: %@", originalSize);
//        }
//    }];
        
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
