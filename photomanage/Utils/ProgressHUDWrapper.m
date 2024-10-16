//
//  ProgressHUDWrapper.m
//  photomanage
//
//  Created by chenxianming on 2024/10/16.
//

#import "ProgressHUDWrapper.h"

@implementation ProgressHUDWrapper
+ (UIWindow *)currentKeyWindow {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    return UIApplication.sharedApplication.delegate.window; // 作为后备选项
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view {
    if (!view) view = [self currentKeyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2.0];
}

+ (MBProgressHUD *)showLoadingToView:(UIView *)view withString:(NSString *)loadingString {
    if (!view) view = [self currentKeyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = loadingString ?: @"Loading..."; // 提供默认文字
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (MBProgressHUD *)showProgressToView:(UIView *)view withString:(NSString *)loadingString {
    if (!view) view = [self currentKeyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate; // 设置为带进度的模式
    hud.label.text = loadingString ?: @"Loading..."; // 提供默认文字
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (void)updateProgress:(MBProgressHUD *)hud progress:(float)progress {
    if (hud) {
        hud.progress = progress; // 更新进度
    }
}

+ (void)hideHUDForView:(UIView *)view {
    if (!view) view = [self currentKeyWindow];
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
