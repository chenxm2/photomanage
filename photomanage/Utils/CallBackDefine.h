//
//  CallBackDefine.h
//  photomanage
//
//  Created by chenxianming on 2024/9/30.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
typedef void (^CompletionResult)(BOOL result);
typedef void (^CallBack)(void);
typedef void (^ProgressCallback)(double progress, BOOL finished,  NSError * _Nullable error);
typedef void (^CheckInICloudResult)(AVAsset * _Nullable result);
NS_ASSUME_NONNULL_END
