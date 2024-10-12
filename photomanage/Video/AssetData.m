//
//  AssetData.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "AssetData.h"
#import "AssetBindData.h"

@interface AssetData ()
@property (nonatomic, strong) NSNumber *isCompress;
@property (nonatomic, strong) AssetBindData *assetBindData;
@end

@implementation AssetData
- (instancetype)initWithAsset:(PHAsset *)asset andNumber:(NSNumber *)fileSize {
    self = [super init];
    if (self) {
        _asset = asset;
        _fileSize = fileSize;
    }
    return self;
}

- (void)loadBindData:(AssetBindDataCallback)callback {
    if (_assetBindData == nil) {
        WEAK_SELF
        [GCDUtility executeOnSerialQueue:^{
            STRONG_SELF
            if (strongSelf) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *savedData = [defaults objectForKey:strongSelf.asset.localIdentifier];
                if (savedData) {
                    NSError *error = nil;
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:savedData error:&error];
                    if (error == nil) {
                        AssetBindData *unarchivedAssetData = [unarchiver decodeObjectOfClass:[AssetBindData class] forKey:kAssetBindData];
                        [unarchiver finishDecoding];
                        if (unarchivedAssetData != nil) {
                            [GCDUtility executeOnMainThread:^{
                                strongSelf.assetBindData = unarchivedAssetData;
                                callback(unarchivedAssetData);
                            }];
                        } else {
                            [strongSelf generateNewBindData:callback];
                        }
                    } else {
                        [strongSelf generateNewBindData:callback];
                    }
                } else {
                    [strongSelf generateNewBindData:callback];
                }
            }
        }];
    } else {
        callback(_assetBindData);
    }
}

- (void)generateNewBindData:(AssetBindDataCallback)callback {
    AssetBindData *newData = [[AssetBindData alloc] init];
    newData.orgLocalIdentifier = self.asset.localIdentifier;
    WEAK_SELF
    [GCDUtility executeOnMainThread:^{
        STRONG_SELF
        if (strongSelf) {
            strongSelf.assetBindData = newData;
        }
        
        callback(newData);
    }];
}

@end
