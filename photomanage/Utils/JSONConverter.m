//
//  JSONConverter.m
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import "JSONConverter.h"
@implementation JSONConverter
+ (NSString *)jsonStringFromModel:(id)model {
    if (!model) {
        return nil;
    }
    // 使用 yy_modelToJSONString 将模型对象转换为 JSON 字符串
    NSString *jsonString = [model yy_modelToJSONString];
    
    return jsonString;
}

+ (NSData *)dataFromJsonString:(NSString *)jsonString {
    if (!jsonString) {
        return nil;
    }
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)dataFromModel:(id)model {
    if (!model) {
        return nil;
    }
    // 将模型对象转换为 JSON 字符串
    NSString *jsonString = [self jsonStringFromModel:model];
    // 将 JSON 字符串转换为 NSData
    return [self dataFromJsonString:jsonString];
}

+ (id)modelFromData:(NSData *)data modelClass:(Class)modelClass {
    if (!data || !modelClass) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [modelClass yy_modelWithJSON:jsonString];
}

+ (NSDictionary *)dictionaryFromModel:(id)model {
    if (!model) {
        return nil;
    }
    return [model yy_modelToJSONObject];
}

+ (id)modelFromDictionary:(NSDictionary *)dict modelClass:(Class)modelClass {
    if (!dict || !modelClass) {
        return nil;
    }
    return [modelClass yy_modelWithJSON:dict];
}
@end
