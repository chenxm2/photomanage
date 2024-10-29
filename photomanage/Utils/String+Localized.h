//
//  String+Localized.h
//  photomanage
//
//  Created by chenxianming on 2024/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Localized)
+ (NSString *)localizedStringWithName:(NSString *)name;
+ (NSString *)localizedConfirm;
+ (NSString *)localizedCancel;
+ (NSString *)localizedLoading;
@end

NS_ASSUME_NONNULL_END
