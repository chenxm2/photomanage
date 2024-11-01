//
//  BaseConfiguration.h
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface BaseConfiguration : NSObject

+ (UIColor *)navigationBarColor; // 导航栏颜色
+ (UIColor *)navigationBarTitleColor;
+ (UIColor *)buttonTextColor; // 默认按钮文字颜色
+ (UIColor *)viewBackgroundColor; // 视图背景颜色
+ (UIImage *)rightItemImg; // 视图背景颜色

@end

NS_ASSUME_NONNULL_END
