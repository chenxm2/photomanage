//
//  UserDefaultsManager.h
//  photomanage
//
//  Created by chenxianming on 2024/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface UserDefaultsManager : NSObject

// 存储字符串
+ (void)setString:(NSString *)value forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;

// 存储整数
+ (void)setInteger:(NSInteger)value forKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key;

// 存储布尔值
+ (void)setBool:(BOOL)value forKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;

// 存储浮点数
+ (void)setFloat:(float)value forKey:(NSString *)key;
+ (float)floatForKey:(NSString *)key;

// 存储对象（如 NSDictionary、NSArray）
+ (void)setObject:(id)value forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

// 移除某个键
+ (void)removeObjectForKey:(NSString *)key;

@end


NS_ASSUME_NONNULL_END
