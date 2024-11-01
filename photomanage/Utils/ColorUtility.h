//
//  ColorUtility.h
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ColorUtility : NSObject

// 通过 RGB 和 Alpha 值创建 UIColor
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

// 省略 alpha 值，默认为 1.0
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

// 通过 0-255 范围的 RGB 值创建 UIColor
+ (UIColor *)colorWithDecimalRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

// 省略 alpha 值，默认为 1.0
+ (UIColor *)colorWithDecimalRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;

// 通过十六进制字符串创建 UIColor
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
