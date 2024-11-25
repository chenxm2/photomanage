//
//  String+Bussiness.h
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kHadShowGuidance;
@interface NSString (Bussiness)
+ (NSString *)fileSizeStringWithNumber:(NSNumber *)fileSize;
+ (NSString *)virtualCurrencyStringWithValue:(NSUInteger)virtualCurrency;
@end

NS_ASSUME_NONNULL_END
