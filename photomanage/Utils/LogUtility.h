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
- (void)logInfoWithTag:(NSString *)tag message:(NSString *)message;
- (void)logDebugWithTag:(NSString *)tag message:(NSString *)message;
- (void)logErrorWithTag:(NSString *)tag message:(NSString *)message;
- (void)logWarningWithTag:(NSString *)tag message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
