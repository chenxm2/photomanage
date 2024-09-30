//
//  VideoDataManager.h
//  photomanage
//
//  Created by chenxianming on 2024/9/27.
//

#import <Foundation/Foundation.h>
#import "AssetData.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^AssetDatasCallback)(NSArray<AssetData *> *dataList);
@interface VideoDataManager : NSObject
@property (nonatomic, strong) NSArray<AssetData *> *videoList; // 示例属性，用于存储视频数据
/**
 Returns the shared instance of the VideoDataManager class.
 */
+ (instancetype)sharedManager;
- (void)fetchVideosSortedBySize:(AssetDatasCallback)callback;
- (AssetData *)assetDataByLocalIdentifier:(NSString *)localIdentifier;
- (void)onCompressedVideoSaveToAlblum:(NSString *)compressedLocalIdentifier;
- (void)checkIfVideoIsOnlyInCloud:(PHAsset *)asset callback:(CompletionResult)callback;
@end

NS_ASSUME_NONNULL_END
