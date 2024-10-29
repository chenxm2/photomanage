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
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSData *savedData = [defaults objectForKey:strongSelf.asset.localIdentifier];
            AssetBindData *res = [JSONConverter modelFromData:savedData modelClass:[AssetBindData class]];
            if (res) {
                [GCDUtility executeOnMainThread:^{
                    STRONG_SELF
                    strongSelf.assetBindData = res;
                    callback(res, strongSelf);
                }];
                
            } else {
                [strongSelf generateNewBindData:callback];
            }
        }];
    } else {
        WEAK_SELF
        [GCDUtility executeOnMainThread:^{
            STRONG_SELF
            callback(_assetBindData, strongSelf);
        }];
    }
}

- (void)generateNewBindData:(AssetBindDataCallback)callback {
    AssetBindData *newData = [[AssetBindData alloc] init];
    newData.orgLocalIdentifier = self.asset.localIdentifier;
    WEAK_SELF
    [GCDUtility executeOnMainThread:^{
        STRONG_SELF
        strongSelf.assetBindData = newData;
        callback(newData, strongSelf);
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %p, AssetBindData = %@",
            NSStringFromClass([self class]), self, self.assetBindData];
}

@end
