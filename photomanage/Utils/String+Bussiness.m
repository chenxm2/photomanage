//
//  String+Bussiness.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "String+Bussiness.h"

NSString * const kHadShowGuidance = @"hadShowGuidance";

@implementation NSString (Bussiness)
+(NSString *)fileSizeStringWithNumber:(NSNumber *)fileSize
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 0; // 最少的小数位数
    formatter.maximumFractionDigits = 2; // 最多保留两位小数

    NSString *formattedString = [formatter stringFromNumber:fileSize];
    return [NSString stringWithFormat:@"%@ M", formattedString];
}

+ (NSString *)virtualCurrencyStringWithValue:(NSUInteger)virtualCurrency {
    return [NSString stringWithFormat:@"%ld", virtualCurrency];
}
@end
