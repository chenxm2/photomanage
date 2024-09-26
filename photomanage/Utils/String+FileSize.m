//
//  String+FileSize.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "String+FileSize.h"

@implementation NSString (FileSize)
+(NSString *)fileSizeStringWithNumber:(NSNumber *)fileSize 
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 0; // 最少的小数位数
    formatter.maximumFractionDigits = 2; // 最多保留两位小数

    NSString *formattedString = [formatter stringFromNumber:fileSize];
    return [NSString stringWithFormat:@"%@ M", formattedString];
}
@end
