//
//  ConfirmDeleteController.m
//  photomanage
//
//  Created by chenxianming on 2024/5/21.
//

#import "ConfirmDeleteController.h"
#import "ConfirmDeleteViewCell.h"
#import <Photos/Photos.h> 

@interface ConfirmDeleteController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectArray;
@property (nonatomic, assign) Boolean isInitCollectionView;

@end

@implementation ConfirmDeleteController
- (IBAction)deleteButton:(id)sender {
    NSMutableArray<PHAsset *> *deleteArray = [[NSMutableArray alloc] init];
    if ([self.selectArray count] == 0) {
        [deleteArray addObjectsFromArray:self.deleteAssetsArray];
    } else {
        [deleteArray addObjectsFromArray:self.selectArray];
    }
    
    if ([self.delegate respondsToSelector:@selector(confirmDelete:)]) {
        [self.delegate confirmDelete:deleteArray];
    }
    
    [self.deleteAssetsArray removeObjectsInArray:deleteArray];
    [self.selectArray removeAllObjects];
    [self.collectionView reloadData];
    [self deleteAssets:deleteArray];
    
    if ([self.delegate respondsToSelector:@selector(didPhotoPreviewDeleteCountChange)]) {
        [self.delegate didPhotoPreviewDeleteCountChange];
    }
    
    [self updateButtonText];
}

- (void)deleteAssets:(NSArray<PHAsset *> *)assets {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        for (PHAsset *asset in assets) {
            [PHAssetChangeRequest deleteAssets:@[asset]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Assets have been successfully deleted.");
        } else {
            NSLog(@"Error occurred while deleting assets: %@", error);
        }
    }];
    
}


- (IBAction)restoreButton:(id)sender {
    if ([self.selectArray count] == 0) {
        [self.deleteAssetsArray removeAllObjects];
    } else {
        [self.deleteAssetsArray removeObjectsInArray:self.selectArray];
    }
    
    [self.selectArray removeAllObjects];
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didPhotoPreviewDeleteCountChange)]) {
        [self.delegate didPhotoPreviewDeleteCountChange];
    }
    
    [self updateButtonText];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectArray = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)initCollectionViewOnce
{
    if (_isInitCollectionView) {
        return;
    }
    _isInitCollectionView = true;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.view.frame.size.width / 3 - 1, self.view.frame.size.width / 3 - 1); // 根据需要设置cell大小
    layout.minimumInteritemSpacing = 1; // 设置最小列间距
    layout.minimumLineSpacing = 1; // 设置最小行间距
    
    [self.collectionView registerClass:[ConfirmDeleteViewCell class] forCellWithReuseIdentifier:[ConfirmDeleteViewCell reuseIdentifier]];
    [self.collectionView setCollectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"fetchAssets count = %lu", (unsigned long)self.deleteAssetsArray.count);
    return [self.deleteAssetsArray count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initCollectionViewOnce];
    self.navigationController.title = @"待处理";
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ConfirmDeleteViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ConfirmDeleteViewCell reuseIdentifier] forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ConfirmDeleteViewCell alloc] initWithFrame:CGRectZero];
    }

    
    PHAsset *asset = self.deleteAssetsArray[indexPath.row];
    [cell updateAsset:asset isSelect:[self.selectArray containsObject:asset]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.deleteAssetsArray[indexPath.row];
    if (![self.selectArray containsObject:asset]) {
        [self.selectArray addObject:asset];
    } else {
        [self.selectArray removeObject:asset];
    }
    
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    [self updateButtonText];
}

- (void)updateButtonText {
    if ([self.selectArray count] == 0) {
        [self.deleteButton setTitle:@"删除全部" forState:UIControlStateNormal];
        [self.restoreButton setTitle:@"恢复全部" forState:UIControlStateNormal];
    } else {
        NSString *deleteString = [NSString stringWithFormat:@"删除选中%lu项", (unsigned long)[self.selectArray count]];
        NSString *restring = [NSString stringWithFormat:@"恢复选中%lu项", (unsigned long)[self.selectArray count]];
        [self.deleteButton setTitle:deleteString forState:UIControlStateNormal];
        [self.restoreButton setTitle:restring forState:UIControlStateNormal];
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
