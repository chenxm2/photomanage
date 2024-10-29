//
//  AssetData.h
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "AssetBindData.h"
NS_ASSUME_NONNULL_BEGIN
@class AssetData;

typedef void (^AssetBindDataCallback)(AssetBindData *bindData, AssetData *data);
typedef void (^AssetDataCallback)(AssetData *assetData);
typedef void (^HasCompressCallback)(BOOL hasCompressed);
@interface AssetData : NSObject
@property (strong, nonatomic, readonly) PHAsset *asset;
@property (strong, nonatomic, readonly) NSNumber *fileSize;
- (void)loadBindData:(AssetBindDataCallback)callback;
- (instancetype)initWithAsset:(PHAsset *)asset andNumber:(NSNumber *)fileSize;
@end



NS_ASSUME_NONNULL_END
