//
//  BaseConfiguration.m
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import "BaseConfiguration.h"


@implementation BaseConfiguration

+ (UIColor *)navigationBarColor {
    return [ColorUtility colorWithDecimalRed:246 green:246 blue:246]; // 返回统一的导航栏颜色
}

+ (UIColor *)navigationBarTitleColor {
    return [ColorUtility colorWithDecimalRed:21 green:21 blue:21]; // 返回统一的导航栏颜色
}

+ (UIColor *)buttonTextColor {
    return [UIColor blackColor]; // 默认按钮文字颜色
}

+ (UIColor *)viewBackgroundColor {
    return [ColorUtility colorWithDecimalRed:246 green:246 blue:246 alpha:0.5]; // 视图的默认背景颜色
}

+ (UIImage *)rightItemImg {
   return [UIImage imageNamed:@"test_right"];
}

@end
