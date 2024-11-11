//
//  VideoDataManager.h
//  photomanage
//
//  Created by chenxianming on 2024/9/27.
//

#import <Foundation/Foundation.h>
#import "AssetData.h"
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, FilterType) {
    FilterTypeUnCompress,
    FilterTypeCompressResult,
    FilterTypeWaitDelete,
};

typedef NS_ENUM(NSInteger, SortType) {
    SortTypeBySize,
    SortTypeByTime
};

typedef void (^AssetDatasCallback)(NSArray<AssetData *> *dataList);
@interface VideoDataManager : NSObject
@property (nonatomic, strong, readonly) NSArray<AssetData *> *videoList; // 示例属性，用于存储视频数据
/**
 Returns the shared instance of the VideoDataManager class.
 */
+ (instancetype)sharedManager;
- (AssetData *)assetDataByLocalIdentifier:(NSString *)localIdentifier;
- (void)onCompressedVideoSaveToAlblum:(NSString *)compressedLocalIdentifier compressQuality:(NSString *)quality callBack:(AssetDataCallback)callback;
- (void)checkIfVideoIsOnlyInCloud:(PHAsset *)asset callback:(CompletionResult)callback;

- (void)fetchVideosWithSortedType:(SortType)sortType filterType:(FilterType)filterType completion:(AssetDatasCallback)callback;

- (void)deleteVideoAsset:(AssetData *)asset completionHandler:(void(^)(BOOL success, NSError * _Nullable error))completion;

#define VIDEO_DATA_MANAGER [VideoDataManager sharedManager]

@end

NS_ASSUME_NONNULL_END
