//
//  JSONConverter.h
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>


NS_ASSUME_NONNULL_BEGIN
@interface JSONConverter : NSObject
// 将模型对象转换为 JSON 字符串
+ (NSString *)jsonStringFromModel:(id)model;

// 将 JSON 字符串转换为 NSData
+ (NSData *)dataFromJsonString:(NSString *)jsonString;

// 将模型对象转换为 NSData（合并方法）
+ (NSData *)dataFromModel:(id)model;

// 将 NSData 转换为模型对象
+ (id)modelFromData:(NSData *)data modelClass:(Class)modelClass;

// 将模型对象转换为字典
+ (NSDictionary *)dictionaryFromModel:(id)model;

// 将字典转换为模型对象
+ (id)modelFromDictionary:(NSDictionary *)dict modelClass:(Class)modelClass;

@end
NS_ASSUME_NONNULL_END
