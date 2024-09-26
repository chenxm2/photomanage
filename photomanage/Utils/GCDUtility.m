//
//  GCDUtility.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "GCDUtility.h"

@implementation GCDUtility
// 1. 切换到主线程执行任务
+ (void)executeOnMainThread:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

// 2. 切换到串行队列执行任务
+ (void)executeOnSerialQueue:(void (^)(void))block {
    static dispatch_queue_t serialQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serialQueue = dispatch_queue_create("com.example.serialQueue", DISPATCH_QUEUE_SERIAL);
    });
    dispatch_async(serialQueue, block);
}

// 3. 切换到并发队列执行任务
+ (void)executeOnConcurrentQueue:(void (^)(void))block {
    static dispatch_queue_t concurrentQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        concurrentQueue = dispatch_queue_create("com.example.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    dispatch_async(concurrentQueue, block);
}
@end
