//
//  ActivityIndicatorUtility.m
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import "ActivityIndicatorUtility.h"

@implementation ActivityIndicatorUtility
+ (void)showActivityIndicatorInView:(UIView *)view {
// 检查视图是否已包含覆盖视图
    UIView *existingOverlayView = [view viewWithTag:999];
    if (existingOverlayView) {
        return; // 如果已存在覆盖视图，则不再创建新的
    }
    
    // 创建一个覆盖视图
    UIView *overlayView = [[UIView alloc] initWithFrame:view.bounds];
    overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3]; // 半透明背景
    overlayView.tag = 999; // 为了以后能够找到和移除

    // 创建活动指示器
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = overlayView.center;
    [activityIndicator startAnimating];

    // 添加活动指示器到覆盖视图
    [overlayView addSubview:activityIndicator];

    // 禁用用户交互
    view.userInteractionEnabled = NO;

    // 添加覆盖视图到主视图
    [view addSubview:overlayView];
}

+ (void)hideActivityIndicatorInView:(UIView *)view {
// 找到并移除覆盖视图
    UIView *overlayView = [view viewWithTag:999];
    if (overlayView) {
        [overlayView removeFromSuperview];
    }

    // 恢复用户交互
    view.userInteractionEnabled = YES;
}
@end
