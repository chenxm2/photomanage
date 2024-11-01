//
//  BaseTabBarController.h
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN



@interface BaseTabBarController : UITabBarController
- (BOOL)shouldShowLeftButton; // 是否显示左侧按钮
- (BOOL)shouldShowRightButton; // 是否显示右侧按钮
- (void)configureRightButtonText:(NSString *)text
                            image:(UIImage *)image
                        textColor:(UIColor  * _Nullable)color;
@end


NS_ASSUME_NONNULL_END
