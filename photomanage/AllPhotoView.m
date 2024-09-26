//
//  AllPhotoView.m
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import "AllPhotoView.h"
#import "PhotoCollectionViewCell.h"
#import "Masonry.h"

@interface AllPhotoView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<PHAsset *> * assetsArray;
@property (nonatomic, strong) PHAsset *selectAsset;
@property (nonatomic, strong) UIButton *upButton;
@property (nonatomic, strong) UIButton *downButton;
@end


@implementation AllPhotoView

- (instancetype)initWithParameter:(NSMutableArray<PHAsset *> *)assetArray selectAsset:(PHAsset *)asset frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.assetsArray = assetArray;
        self.selectAsset = asset;
        self.backgroundColor = [UIColor blueColor];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.frame.size.width / 3 - 1, self.frame.size.width / 3 - 1); // 根据需要设置cell大小
        layout.minimumInteritemSpacing = 1; // 设置最小列间距
        layout.minimumLineSpacing = 1; // 设置最小行间距

        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [self.collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:[PhotoCollectionViewCell reuseIdentifier]];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
        }];
        
        self.layer.cornerRadius = 6;
        self.clipsToBounds = YES;
        [self scrollToSelect];
        [self configUpAndDownButton];
    }
    return self;
}

- (void)configUpAndDownButton
{
    self.upButton = [[UIButton alloc] init];
    [self.upButton setImage:[UIImage imageNamed:@"icon_group_prev"] forState:UIControlStateNormal];
    [self.upButton addTarget:self action:@selector(upclicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.upButton];
    
    self.downButton = [[UIButton alloc] init];
    [self.downButton setImage:[UIImage imageNamed:@"icon_group_next"] forState:UIControlStateNormal];
    [self.downButton addTarget:self action:@selector(downclicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.downButton];
    
    
    [self.upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10); // 顶部与父视图顶部对齐
        make.right.equalTo(self.mas_right).offset(-10); // 左边与父视图左边对齐
        make.width.equalTo(@44); // 设置固定宽度
        make.height.equalTo(@44); // 设置固定高度
    }];
    
    [self.downButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.upButton.mas_bottom).offset(10); // 顶部与父视图顶部对齐
        make.right.equalTo(self.mas_right).offset(-10); // 左边与父视图左边对齐
        make.width.equalTo(@44); // 设置固定宽度
        make.height.equalTo(@44); // 设置固定高度
    }];
}

- (void)upclicked:(UIButton *)button
{
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:topIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)downclicked:(UIButton *)button
{
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForItem:[self.assetsArray count] - 1 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:topIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (void)scrollToSelect
{
    __weak typeof(self) weakSelf = self;
    // 获取当前时间
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));

    // 指定延时执行的队列，这里使用主队列来更新UI
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 执行延时任务
    dispatch_after(popTime, queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSUInteger index = [strongSelf.assetsArray indexOfObject:strongSelf.selectAsset];
            [strongSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        }
    });
}


+ (instancetype)viewWithParameter:(NSMutableArray<PHAsset *> *)assetsArray selectAsset:(PHAsset *)asset frame:(CGRect)frame {
    AllPhotoView *view = [[AllPhotoView alloc] initWithParameter:assetsArray selectAsset:asset frame:frame];
    return view;
}
    
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"fetchAssets count = %lu", (unsigned long)self.assetsArray.count);
    return [self.assetsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PhotoCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[PhotoCollectionViewCell alloc] initWithFrame:CGRectZero];
    }

    
    PHAsset *asset = self.assetsArray[indexPath.item];
    [cell updateAsset:asset isSelect:indexPath.item == [self.assetsArray indexOfObject:self.selectAsset]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelect:)]) {
        [self.delegate didSelect:[self.assetsArray objectAtIndex:indexPath.row]];
    }
    // 处理单元格选中事件，例如打印indexPath
    
//   NSLog(@"didSelectItemAtIndexPath %@", indexPath);
//   PhotoPreviewController *previewController = [PhotoPreviewController viewControllerWithParameter:self.assetsArray currentIndex:indexPath.row];
//
//    [self.navigationController pushViewController:previewController animated:NO];
}

@end
