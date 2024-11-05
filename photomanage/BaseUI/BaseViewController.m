//
//  BaseViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/10/30.
//

#import "BaseViewController.h"
#import "BaseConfiguration.h"

@interface BaseViewController ()

@end




@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置统一的页面背景颜色
    self.view.backgroundColor = [BaseConfiguration viewBackgroundColor];
    
    // 配置导航栏
    [self configureNavigationBar];
    
    // 根据子类的配置显示或隐藏左右按钮
    [self configureButtons];
}

- (void)configureNavigationBar {
    // 设置导航栏的颜色和透明度
    if (@available(iOS 15.0, *)) {
            // iOS 15 及以上版本使用 UINavigationBarAppearance
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            [appearance configureWithOpaqueBackground]; // 设置为不透明背景
            appearance.backgroundColor = [BaseConfiguration navigationBarColor]; // 替换为所需的颜色
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]}; // 设置标题颜色

            // 应用到 navigationBar 的 standardAppearance 和 scrollEdgeAppearance
            self.navigationController.navigationBar.standardAppearance = appearance;
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;

        } else {
            // iOS 15 以下版本直接使用 barTintColor 和 titleTextAttributes
            self.navigationController.navigationBar.barTintColor = [BaseConfiguration navigationBarColor]; // 导航栏背景颜色
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]}; // 设置标题颜色
        }
        
        // 设置透明度，确保颜色不与背景混合
        self.navigationController.navigationBar.translucent = NO;
}

- (void)configureButtons {
    if ([self shouldShowLeftButton]) {
        // 创建返回按钮
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(leftButtonTapped)];
        self.navigationItem.leftBarButtonItem = leftButton;
    } else {
        self.navigationItem.leftBarButtonItem = nil; // 隐藏左侧按钮
    }

    if ([self shouldShowRightButton]) {
        // 创建默认右侧按钮
        [self configureRightButtonText:@"123"
                                 image:[BaseConfiguration rightItemImg]  textColor:nil];
    } else {
        self.navigationItem.rightBarButtonItem = nil; // 隐藏右侧按钮
    }
}

- (void)configureRightButtonText:(NSString *)text
                           image:(UIImage *)image
                       textColor:(UIColor * _Nullable)color {
    if (!color) {
        color = [BaseConfiguration buttonTextColor]; // 使用默认文字颜色
    }
    
    int imageSize = 16;
    int margin = 8; // 标签和图片之间的间距
    int sidePadding = 12; // 左右边距
    int customViewHeight = 26;
    
    // 创建标签
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = color;
    label.textAlignment = NSTextAlignmentRight;
    [label sizeToFit]; // 自动调整标签的大小以适应文本内容
    
    // 计算自定义视图的宽度，增加左右边距
    int customViewWidth = label.frame.size.width + imageSize + margin + (2 * sidePadding);
    
    // 创建自定义视图
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, customViewWidth, customViewHeight)];
    customView.backgroundColor = [UIColor clearColor];
    customView.layer.borderColor = [ColorUtility colorWithDecimalRed:30 green:143 blue:56].CGColor;
    customView.layer.borderWidth = 1.0;
    customView.layer.cornerRadius = customViewHeight / 2;
    customView.layer.masksToBounds = YES;
    
    // 调整标签的位置
    label.frame = CGRectMake(sidePadding, 0, label.frame.size.width, customViewHeight);
    
    // 创建图片视图
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(customViewWidth - imageSize - sidePadding, (customViewHeight - imageSize) / 2, imageSize, imageSize);
    
    // 添加标签和图片到自定义视图中
    [customView addSubview:label];
    [customView addSubview:imageView];
    
    // 创建一个 UITapGestureRecognizer，添加到自定义视图
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonTapped)];
    [customView addGestureRecognizer:tapGesture];
    customView.userInteractionEnabled = YES; // 使自定义视图可交互
    
    // 将自定义视图设置为导航项的右侧按钮
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}


- (void)leftButtonTapped {
    // 实现左侧按钮点击逻辑
    [self.navigationController popViewControllerAnimated:YES]; // 默认返回上一层
}

- (void)rightButtonTapped {
    // 实现右侧按钮点击逻辑
    NSLog(@"右侧按钮被点击");
}

// 子类可以重载这两个方法来控制按钮的显示
- (BOOL)shouldShowLeftButton {
    return YES; // 默认显示左侧按钮
}

- (BOOL)shouldShowRightButton {
    return YES; // 默认显示右侧按钮
}

@end
