//
//  BaseTabBarController.m
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import "BaseTabBarController.h"
#import "BaseConfiguration.h"
@interface BaseTabBarController ()

@end



@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [BaseConfiguration viewBackgroundColor];
    [self configureNavigationBar];
    [self configureTabBar];
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
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName : [BaseConfiguration navigationBarTitleColor]}; // 设置标题颜色

            // 应用到 navigationBar 的 standardAppearance 和 scrollEdgeAppearance
            self.navigationController.navigationBar.standardAppearance = appearance;
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;

        } else {
            // iOS 15 以下版本直接使用 barTintColor 和 titleTextAttributes
            self.navigationController.navigationBar.barTintColor = [BaseConfiguration navigationBarColor]; // 导航栏背景颜色
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [BaseConfiguration navigationBarTitleColor]}; // 设置标题颜色
        }
        
        // 设置透明度，确保颜色不与背景混合
        self.navigationController.navigationBar.translucent = NO;
}

- (void)configureTabBar {
    if (@available(iOS 15.0, *)) {
        // iOS 15 及以上使用 UITabBarAppearance
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground]; // 设置为不透明背景
        appearance.backgroundColor = [BaseConfiguration navigationBarColor]; // 设置背景颜色
        
        // 可选：配置选中和未选中项的颜色
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorUtility colorWithDecimalRed:25 green:184 blue:77]};
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [ColorUtility colorWithDecimalRed:44 green:44 blue:44]};
        
        // 应用到 tabBar 的 standardAppearance 和 scrollEdgeAppearance
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;

    } else {
        // iOS 15 以下系统，使用 barTintColor 和 tintColor
        self.tabBar.barTintColor = [BaseConfiguration navigationBarTitleColor]; // 设置背景颜色
        self.tabBar.tintColor = [ColorUtility colorWithDecimalRed:25 green:184 blue:77]; // 选中项颜色
        self.tabBar.unselectedItemTintColor = [ColorUtility colorWithDecimalRed:44 green:44 blue:44]; // 未选中项颜色
    }
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
        [self configureRightButtonText:@"设置"
                                 image:[BaseConfiguration rightItemImg]
                                textColor:nil];
    } else {
        self.navigationItem.rightBarButtonItem = nil; // 隐藏右侧按钮
    }
}

- (void)configureRightButtonText:(NSString *)text
                            image:(UIImage *)image
                        textColor:(UIColor  * _Nullable)color {
    if (!color) {
            color = [BaseConfiguration buttonTextColor]; // 使用默认文字颜色
        }

        // 创建自定义视图
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)]; // 根据需要调整大小

        // 创建标签
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, customView.frame.size.width - 44, 44)];
        label.text = text;
        label.textColor = color;
        label.textAlignment = NSTextAlignmentLeft;
        
        // 创建图片视图
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit; // 设置图片内容模式
        imageView.frame = CGRectMake(customView.frame.size.width - 44, (customView.frame.size.height - 44) / 2, 44, 44); // 图片的大小和位置

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

