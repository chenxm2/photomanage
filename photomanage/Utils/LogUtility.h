//
//  LogUtility.h
//  photomanage
//
//  Created by chenxianming on 2024/9/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogUtility : NSObject

+ (instancetype)sharedInstance;

// 支持格式化字符串的日志方法
- (void)logInfoWithTag:(NSString *)tag message:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
- (void)logDebugWithTag:(NSString *)tag message:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
- (void)logErrorWithTag:(NSString *)tag message:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
- (void)logWarningWithTag:(NSString *)tag message:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

@end
#ifdef DEBUG
#define LogInfo(...) [[LogUtility sharedInstance] logInfoWithTag:@"Photomanage" message:__VA_ARGS__]
#else
#define LogInfo(...)
#endif
NS_ASSUME_NONNULL_END
