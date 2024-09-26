//
//  GCDUtility.h
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDUtility : NSObject
// 1. 切换到主线程执行任务
+ (void)executeOnMainThread:(void (^)(void))block;

// 2. 切换到串行队列执行任务
+ (void)executeOnSerialQueue:(void (^)(void))block;

// 3. 切换到并发队列执行任务
+ (void)executeOnConcurrentQueue:(void (^)(void))block;
@end

NS_ASSUME_NONNULL_END
