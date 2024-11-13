//
//  VideoDataManager.m
//  photomanage
//
//  Created by chenxianming on 2024/9/27.
//

#import "VideoDataManager.h"
@interface VideoDataManager ()
@property (nonatomic, strong) NSMutableArray<AssetData *> *sortedData;
@property (nonatomic, strong) NSMutableArray<AssetData *> *orgData;
@property (nonatomic, strong) NSMutableDictionary<NSString *, AssetData *> *dataMap;
@end

@implementation VideoDataManager

static VideoDataManager *_instance = nil;
static dispatch_once_t onceToken;

// 私有化初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        _sortedData = [[NSMutableArray alloc] init]; // 初始化视频列表
        _dataMap = [[NSMutableDictionary alloc] init];
        _orgData = [[NSMutableArray alloc] init];
    }
    return self;
}

// 公共接口获取单例
+ (instancetype)sharedManager {
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

// 对外提供只读的NSArray
- (NSArray<AssetData *> *)videoList {
    return [self.sortedData copy]; // 返回一个不可变副本
}

- (AssetData *)assetDataByLocalIdentifier:(NSString *)localIdentifier
{
    if (localIdentifier == nil) {
        return nil;
    }
    
    return [_dataMap objectForKey:localIdentifier];
}

- (void)onCompressedVideoSaveToAlblum:(NSString *)compressedLocalIdentifier compressQuality:(NSString *)quality callBack:(AssetDataCallback)callback {
    if (compressedLocalIdentifier == nil) {
        return;
    }
    
    if ([_dataMap objectForKey:compressedLocalIdentifier] == nil) {
        [GCDUtility executeOnSerialQueue:^{
            PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:compressedLocalIdentifier] options:nil];
            [self createDataByPHFetchResult:fetchResult callback:^(NSArray<AssetData *> * _Nonnull dataList) {
                [dataList enumerateObjectsUsingBlock:^(AssetData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"onCompressedVideoSaveToAlblum got %@", obj);
                    [self.orgData insertObject:obj atIndex:0];
                    [obj loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
                        [bindData setCompressQulity:quality];
                        [self.dataMap setObject:data forKey:data.asset.localIdentifier];
                        LogInfo(@"onCompressedVideoSaveToAlblum data = %@", data);
                        callback(data);
                    }];
                }];
            }];
        }];
    }
}

- (void)deleteData:(AssetData *)data {
    [GCDUtility executeOnMainThread:^{
        [self.orgData removeObject:data];
        [self.dataMap removeObjectForKey:data.asset.localIdentifier];
    }];
}

- (void)deleteVideoAsset:(AssetData *)asset completionHandler:(void(^)(BOOL success, NSError * _Nullable error))completion {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 请求删除指定的 PHAsset
        [PHAssetChangeRequest deleteAssets:@[asset.asset]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        [GCDUtility executeOnMainThread:^{
            [self deleteData:asset];
            if (completion) {
                completion(success, error);
            }
        }];
    }];
}

- (void)createDataByPHFetchResult:(PHFetchResult *)fetchResult callback:(AssetDatasCallback)callback {
    NSMutableArray<PHAsset *> *sourceVideoArray = [[NSMutableArray alloc] init];
    NSMutableArray<AssetData *> *res = [[NSMutableArray alloc] init];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
        // 对每个PHAsset对象进行操作
        [sourceVideoArray addObject:asset];
    }];
    
    for (PHAsset *asset in sourceVideoArray) {
        NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
        PHAssetResource *videoResource = nil;
        
        for (PHAssetResource *resource in resources) {
            if (resource.type == PHAssetResourceTypeVideo) {
                videoResource = resource;
                break;
            }
        }
        
        unsigned long long fileSize = [[videoResource valueForKey:@"fileSize"] unsignedLongLongValue];
        CGFloat fileSizeMB = fileSize / (1024.0 * 1024.0); // 转换为MB
        AssetData *data = [[AssetData alloc] initWithAsset:asset andNumber:@(fileSizeMB)];
        [res addObject:data];
    }
    
    [GCDUtility executeOnMainThread:^{
        callback(res);
    }];
}

- (void)fetchVideosWithSortedType:(SortType)sortType filterType:(FilterType)filterType completion:(AssetDatasCallback)callback {
    if (self.orgData.count == 0) {
        LogInfo(@"fetchVideosWithSortedType size orgData == 0 sortType = %ld, filterType = %ld", (long)sortType, filterType);
        [self loadDataFromAlbumWithCompletion:^(NSArray<AssetData *> * _Nonnull dataList) {
            [self filterVideosWithSortedType:sortType filterType:filterType orgData:dataList callBack:callback];
        }];
    } else {
        LogInfo(@"fetchVideosWithSortedType size orgData > 0 sortType = %ld, filterType = %ld", (long)sortType, filterType);
        [self filterVideosWithSortedType:sortType filterType:filterType orgData:self.orgData callBack:callback];
    }
}

- (void)filterVideosWithSortedType:(SortType)sortType filterType:(FilterType)filterType orgData:(NSArray<AssetData *> *)dataList callBack:(AssetDatasCallback)callBack {
    
    [GCDUtility executeOnSerialQueue:^{
        NSUInteger count = [dataList count];
        __block NSUInteger current = 0;
        
        NSMutableArray<AssetData *> *filterData  = [[NSMutableArray alloc] init];
        for (int i = 0; i < count; i++) {
            [[dataList objectAtIndex:i] loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
                current++;
                if (filterType == FilterTypeUnCompress) {
                    if (![bindData.isCompress boolValue] && bindData.compressQulity == nil) {
                        [filterData addObject:data];
                    }
                } else if (filterType == FilterTypeCompressResult) {
                    if (bindData.compressQulity != nil) {
                        [filterData addObject:data];
                    }
                } else if (filterType == FilterTypeWaitDelete) {
                    if ([bindData.isCompress boolValue]) {
                        [filterData addObject:data];
                    }
                }
                
                if (current == count) {
                    [self filterVideosWithSortedType:sortType orgData:filterData callBack:callBack];
                }
            }];
        }
    }];
}

- (void)filterVideosWithSortedType:(SortType)sortType orgData:(NSMutableArray<AssetData *> *)dataList callBack:(AssetDatasCallback)callBack {
    [GCDUtility executeOnSerialQueue:^{
        if (sortType == SortTypeByTime) {
            NSUInteger count = dataList.count;
            for (NSUInteger i = 0; i < count / 2; i++) {
                id obj = dataList[i];
                dataList[i] = dataList[count - 1 - i];
                dataList[count - 1 - i] = obj;
            }
        } else {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileSize" ascending:NO];
            [dataList sortUsingDescriptors:@[sortDescriptor]];
        }
        
        [GCDUtility executeOnMainThread:^{
            callBack(dataList);
        }];
    }];
}

- (void)loadDataFromAlbumWithCompletion:(AssetDatasCallback)completion {
    [GCDUtility executeOnSerialQueue:^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
        // 可以根据需要设置options，例如过滤图片
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
        [self createDataByPHFetchResult:fetchResult callback:^(NSArray<AssetData *> * _Nonnull dataList) {
            [dataList enumerateObjectsUsingBlock:^(AssetData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.orgData addObject:obj];
                [self.dataMap setObject:obj forKey:obj.asset.localIdentifier];
            }];
            
            completion(self.orgData);
        }];
    }];
    
}




- (void)checkIfVideoIsOnlyInCloud:(PHAsset *)asset callback:(CheckInICloudResult)callback
{
    // 检查资源类型是否为视频
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = NO; // 不允许从网络下载，直接检查本地是否有资源
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            [GCDUtility executeOnMainThread:^{
                if (avAsset) {
                    callback(avAsset);
                } else {
                    callback(nil);
                }
            }];
            
        }];
    }
}

- (void)handleCompleteLoad:(AssetDatasCallback)callback {
    NSLog(@"handleCompleteLoad");
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileSize" ascending:NO];
    [self.sortedData sortUsingDescriptors:@[sortDescriptor]];
    [GCDUtility executeOnMainThread:^{
        callback([self.sortedData copy]);
    }];
}


@end
