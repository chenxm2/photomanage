//
//  VideoDataManager.m
//  photomanage
//
//  Created by chenxianming on 2024/9/27.
//

#import "VideoDataManager.h"
@interface VideoDataManager ()
@property (nonatomic, strong) NSMutableArray<PHAsset *> *sourceVideoArray;
@property (nonatomic, strong) NSMutableArray<AssetData *> *sortedData;
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
                    [obj loadBindData:^(AssetBindData * _Nonnull bindData) {
                        [bindData setCompressQulity:quality];
                        
                        callback(obj);
                    }];
                    [self.dataMap setObject:obj forKey:obj.asset.localIdentifier];
                }];
            }];
        }];
    }
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
    
    callback(res);
}

- (void)fetchVideosSortedBySize:(AssetDatasCallback)callback {
    [GCDUtility executeOnSerialQueue:^{
        if ([self.sortedData count] == 0) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
            // 可以根据需要设置options，例如过滤图片
            PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
            [self createDataByPHFetchResult:fetchResult callback:^(NSArray<AssetData *> * _Nonnull dataList) {
                [self.sortedData addObjectsFromArray:dataList];
                [self.sortedData enumerateObjectsUsingBlock:^(AssetData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.dataMap setObject:obj forKey:obj.asset.localIdentifier];
                }];
                            
            }];
            [self handleCompleteLoad:callback];
        } else {
            [GCDUtility executeOnMainThread:^{
                callback([self.sortedData copy]);
            }];
        }
    }];
}


- (void)checkIfVideoIsOnlyInCloud:(PHAsset *)asset callback:(CompletionResult)callback
{
    // 检查资源类型是否为视频
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = NO; // 不允许从网络下载，直接检查本地是否有资源
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            [GCDUtility executeOnMainThread:^{
                if (avAsset) {
                    callback(NO);
                } else {
                    callback(YES);
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
