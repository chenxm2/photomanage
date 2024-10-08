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
                [[LogUtility sharedInstance] logInfoWithTag:@"AssetData" message:
                 [NSString stringWithFormat:@"loadBindData orgLocalIdentifier = %@, size = %lu", strongSelf.asset.localIdentifier, (unsigned long)savedData.length]];
                if (savedData) {
                    NSError *error = nil;
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:savedData error:&error];
                    if (error == nil) {
                        AssetBindData *unarchivedAssetData = [unarchiver decodeObjectOfClass:[AssetBindData class] forKey:kAssetBindData];
                        [unarchiver finishDecoding];
                        if (unarchivedAssetData != nil) {
                            [[LogUtility sharedInstance] logInfoWithTag:@"AssetData" message:
                             [NSString stringWithFormat:@"loadBindData data = %@", unarchivedAssetData]];
                            [GCDUtility executeOnMainThread:^{
                                strongSelf.assetBindData = unarchivedAssetData;
                                callback(unarchivedAssetData);
                            }];
                        } else {
                            [[LogUtility sharedInstance] logInfoWithTag:@"AssetData" message:@"decodeObjectOfClass fail"];
                            [strongSelf generateNewData:callback];
                        }
                    } else {
                        [[LogUtility sharedInstance] logInfoWithTag:@"AssetData" message:@"initForReadingFromData unarchiver fail"];
                        [[LogUtility sharedInstance] logInfoWithTag:@"AssetData" message:error.description];
                        [strongSelf generateNewData:callback];
                    }
                } else {
                    [[LogUtility sharedInstance] logInfoWithTag:@"AssetData" message:@"savedData nil"];
                    [strongSelf generateNewData:callback];
                }
            }
        }];
    } else {
        callback(_assetBindData);
    }
}

- (void)generateNewData:(AssetBindDataCallback)callback {
    AssetBindData *newData = [[AssetBindData alloc] init];
    newData.orgLocalIdentifier = self.asset.localIdentifier;
    [[LogUtility sharedInstance] logInfoWithTag:@"AssetData" message:
     [NSString stringWithFormat:@"generateNewData data = %@", newData]];
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
