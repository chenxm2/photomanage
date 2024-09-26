//
//  AlertUtility.m
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import "AlertUtility.h"

@implementation AlertUtility
+ (void)showConfirmationAlertInViewController:(UIViewController *)viewController
                                       withTitle:(NSString *)title
                                         message:(NSString *)message
                               confirmButtonTitle:(NSString *)confirmTitle
                                cancelButtonTitle:(NSString *)cancelTitle
                               completionHandler:(nullable void(^)(BOOL confirmed))completion
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(NO); // 取消按钮表示未确认
        }
    }];
    [alertController addAction:cancelAction];

    // 添加确认按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(YES); // 确认按钮表示确认
        }
    }];
    [alertController addAction:confirmAction];

    // 显示弹框
    [viewController presentViewController:alertController animated:YES completion:nil];
}
@end
