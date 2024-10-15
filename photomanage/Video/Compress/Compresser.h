//
//  Compresser.h
//  photomanage
//
//  Created by chenxianming on 2024/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CompressResultCallBack)(BOOL succeed, NSURL * _Nullable fileURL, NSString *errMsg);
@interface Compresser : NSObject
- (void)compressVideoWithAsset:(PHAsset *)asset preset:(NSString *)preset completion:(CompressResultCallBack)completion;
@end

NS_ASSUME_NONNULL_END
