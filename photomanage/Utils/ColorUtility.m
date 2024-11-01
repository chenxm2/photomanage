//
//  ColorUtility.m
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import "ColorUtility.h"
@implementation ColorUtility

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    // 默认 alpha 值为 1.0
    return [self colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)colorWithDecimalRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

+ (UIColor *)colorWithDecimalRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    // 默认 alpha 值为 1.0
    return [self colorWithDecimalRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    // 移除 #
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    // 确保字符串长度为 8
    if (cleanString.length == 8) {
        unsigned int rgbaValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:cleanString];
        [scanner scanHexInt:&rgbaValue];
        
        // 解析 alpha 和 RGB 值
        CGFloat alpha = ((rgbaValue >> 24) & 0xFF) / 255.0; // 前两位是 alpha
        CGFloat red = ((rgbaValue >> 16) & 0xFF) / 255.0;  // 接下来的两位是红色
        CGFloat green = ((rgbaValue >> 8) & 0xFF) / 255.0; // 接下来的两位是绿色
        CGFloat blue = (rgbaValue & 0xFF) / 255.0;         // 最后两位是蓝色

        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }

    // 如果不符合长度要求，返回透明色
    return [UIColor clearColor];
}

@end
