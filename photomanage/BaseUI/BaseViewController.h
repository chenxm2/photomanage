//
//  BaseViewController.h
//  photomanage
//
//  Created by chenxianming on 2024/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface BaseViewController : UIViewController

- (void)configureRightButtonText:(NSString *)text
                            image:(UIImage *)image
                        textColor:(UIColor  * _Nullable)color;

- (BOOL)shouldShowLeftButton; // 是否显示左侧按钮
- (BOOL)shouldShowRightButton; // 是否显示右侧按钮
@end

NS_ASSUME_NONNULL_END
