//
//  PhotoPreviewController.m
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import "PhotoPreviewController.h"
#import "ContentViewController.h"
@interface PhotoPreviewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, ContentViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray<PHAsset *> *assetsArray;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *deleteArray;
@property (nonatomic, strong) PHAsset *selectAsset;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@end

@implementation PhotoPreviewController

- (instancetype)initWithParameter:(NSMutableArray<PHAsset *> *)assetsArray deleteArray:(NSMutableArray<PHAsset *> *)deleteArray selectAsset:(PHAsset *)selectAsset
                      
{
    self = [super init];
    if (self) {
        self.assetsArray = assetsArray;
        self.selectAsset = selectAsset;
        self.deleteArray = deleteArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self pageViewControllerTransitonStyleScroll];
        
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
        
    // 设置UIPageViewController初始化数据，将数据放到NSArray里面
    // 如果 options 设置了 UIPageViewControllerSpineLocationMid,注意viewControllers至少包含两个数据,且 doubleSided = YES
        
    ContentViewController *initialViewController = [self viewControllerWithPHAsset:self.selectAsset];// 得到第一页
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    _pageViewController.view.frame = self.view.bounds; // 设置UIPageViewControlelr视图的尺寸
        
        // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];

    // Do any additional setup after loading the view.
}

+ (instancetype)viewControllerWithParameter:(NSMutableArray<PHAsset *> *)assetsArray
                                deleteArray:(NSMutableArray<PHAsset *> *)deleteArray selectAsset:(PHAsset *)selectAsset
                                 {
    return [[PhotoPreviewController alloc] initWithParameter:assetsArray deleteArray:deleteArray selectAsset:selectAsset];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    
    
    ContentViewController* contentController = (ContentViewController *)viewController;
    PHAsset *asset = [self findPreAssetWith:contentController.content];
    if (asset != nil) {
        self.selectAsset = asset;
        if ([self.delegate respondsToSelector:@selector(didPhotoPreviewSelectPHAsset:)]) {
            [self.delegate didPhotoPreviewSelectPHAsset:asset];
        }
        
        long current = [self.assetsArray indexOfObject:contentController.content];
        long pre = [self.assetsArray indexOfObject:asset];
        NSLog(@"before current = %ld, pre = %ld", current, pre);
        return [self viewControllerWithPHAsset:asset];
    } else {
        return nil;
    }
}

- (PHAsset *)findPreAssetWith:(PHAsset *)current
{
    PHAsset *res = nil;
    NSUInteger currentIndex = NSIntegerMax;
    for (int i = 0; i < [self.assetsArray count]; i++) {
        if (current == self.assetsArray[i]) {
            currentIndex = i;
            break;
        }
    }
    
    if (currentIndex != NSIntegerMax) {
        for (NSInteger i = currentIndex - 1; i >= 0; i--) {
            PHAsset *asset = self.assetsArray[i];
            if (![self.deleteArray containsObject:asset]) {
                res = asset;
                break;
            }
        }
    }
    
    return res;
}

- (PHAsset *)findNextAssetWith:(PHAsset *)current
{
    PHAsset *res = nil;
    NSUInteger currentIndex = NSIntegerMax;
    for (int i = 0; i < [self.assetsArray count]; i++) {
        if (current == self.assetsArray[i]) {
            currentIndex = i;
            break;
        }
    }
    
    if (currentIndex != NSIntegerMax) {
        for (NSInteger i = currentIndex + 1; i < [self.assetsArray count]; i++) {
            PHAsset *asset = self.assetsArray[i];
            if (![self.deleteArray containsObject:asset]) {
                res = asset;
                break;
            }
        }
    }
    
    return res;
}

#pragma mark 返回下一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    ContentViewController* contentController = (ContentViewController *)viewController;
    PHAsset *asset = [self findNextAssetWith:contentController.content];
    if (asset != nil) {
        self.selectAsset = asset;
        if ([self.delegate respondsToSelector:@selector(didPhotoPreviewSelectPHAsset:)]) {
            [self.delegate didPhotoPreviewSelectPHAsset:asset];
        }
        long current = [self.assetsArray indexOfObject:contentController.content];
        long next = [self.assetsArray indexOfObject:asset];

        return [self viewControllerWithPHAsset:asset];
    } else {
        return nil;
    }
}

- (ContentViewController *)viewControllerWithPHAsset:(PHAsset *)asset {
    
    if ([self.assetsArray containsObject:asset]) {
        ContentViewController *contentVC = [[ContentViewController alloc] init];
        contentVC.content = asset;
        contentVC.delegate = self;
        return contentVC;
    }


    return nil;
}


#pragma mark - 数组元素值，得到下标值

- (NSUInteger)indexOfPHAsset:(PHAsset *)asset {
    return [self.assetsArray indexOfObject:asset];
}

- (void)pageViewControllerTransitonStyleScroll
{
    // 设置UIPageViewController的配置项
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(20)};
    
    // 根据给定的属性实例化UIPageViewController
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
}

- (void)updateWithAsset:(PHAsset *)selectAsset {
    _selectAsset = selectAsset;
    ContentViewController * controller = [self viewControllerWithPHAsset:selectAsset];
    if (controller != nil) {
        [self.pageViewController setViewControllers:@[controller]
                                           direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
    }
}

- (void)onDelete:(PHAsset *)asset {
    [self.deleteArray addObject:asset];
    PHAsset *current = [self findNextAssetWith:asset];
    
    if (current == nil) {
        current = [self findPreAssetWith:asset];
    }
    
    if (current != nil) {
        self.selectAsset = current;
        if ([self.delegate respondsToSelector:@selector(didPhotoPreviewSelectPHAsset:)]) {
            [self.delegate didPhotoPreviewSelectPHAsset:current];
        }
        [self updateWithAsset:current];
    }
    
    if ([self.delegate respondsToSelector:@selector(didPhotoPreviewDeleteCountChange)]) {
        [self.delegate didPhotoPreviewDeleteCountChange];
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
