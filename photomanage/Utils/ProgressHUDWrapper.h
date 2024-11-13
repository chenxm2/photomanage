//
//  ProgressHUDWrapper.h
//  photomanage
//
//  Created by chenxianming on 2024/10/16.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
NS_ASSUME_NONNULL_BEGIN
@interface ProgressHUDWrapper : NSObject

// 显示普通文本消息
+ (void)showMessage:(NSString *)message toView:(UIView *)view;

// 显示带有加载信息的菊花
+ (MBProgressHUD *)showLoadingToView:(UIView *)view withString:(NSString *)loadingString;

// 显示带进度的 HUD
+ (MBProgressHUD *)showProgressToView:(UIView *)view withString:(NSString *)loadingString;

// 更新进度
+ (void)updateProgress:(MBProgressHUD *)hud progress:(float)progress;

+ (void)updateMessage:(MBProgressHUD *)hud message:(NSString *)message;

// 隐藏 HUD
+ (void)hideHUDForView:(UIView *)view;
@end
NS_ASSUME_NONNULL_END
