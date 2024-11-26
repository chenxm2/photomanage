//
//  Compresser.h
//  photomanage
//
//  Created by chenxianming on 2024/10/15.
//

#import <Foundation/Foundation.h>
#import "AssetData.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^CompressResultCallBack)(BOOL succeed, NSURL * _Nullable fileURL, NSString *errMsg);
@interface Compresser : NSObject
@property (nonatomic, strong) ProgressCallback downloadProgress;
@property (nonatomic, strong) ProgressCallback compressProgress;
@property (nonatomic, strong) CallBack beginCompressCallBack;
- (BOOL)isCompressing;
- (void)compressVideoWithAsset:(AVAsset *)asset assetData:(AssetData *)assetData preset:(NSString *)preset completion:(CompressResultCallBack)completion;
@end

NS_ASSUME_NONNULL_END
