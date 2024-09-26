//
//  String+FileSize.h
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FileSize)
+ (NSString *)fileSizeStringWithNumber:(NSNumber *)fileSize;
@end

NS_ASSUME_NONNULL_END
