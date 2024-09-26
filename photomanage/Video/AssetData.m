//
//  AssetData.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "AssetData.h"
#import "AssetBindData.h"

typedef void (^AssetBindDataCallback)(AssetBindData *data);

static NSString * const kIsCompress = @"";
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

- (void)hasCompress:(HasCompressCallback)callback
{
    [self loadBindData:^(AssetBindData *data) {
        callback([data.isCompress boolValue]);
    }];
}

- (void)setHasCompress:(bool)hasCompress {
    [self loadBindData:^(AssetBindData *data) {
        [data setIsCompress:[NSNumber numberWithBool:hasCompress]];
    }];
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
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:savedData];
                    AssetBindData *unarchivedAssetData = [unarchiver decodeObjectOfClass:[AssetBindData class] forKey:kAssetBindData];
                    [unarchiver finishDecoding];
                    if (unarchivedAssetData != nil) {
                        [GCDUtility executeOnMainThread:^{
                            callback(unarchivedAssetData);
                        }];
                    } else {
                        AssetBindData *newData = [[AssetBindData alloc] init];
                        newData.orgLocalIdentifier = strongSelf.asset.localIdentifier;
                        [GCDUtility executeOnMainThread:^{
                            callback(newData);
                        }];
                        
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        AssetBindData *newData = [[AssetBindData alloc] init];
                        newData.orgLocalIdentifier = strongSelf.asset.localIdentifier;
                        [GCDUtility executeOnMainThread:^{
                            callback(newData);
                        }];
                    });
                }
            }
        }];
    } else {
        callback(_assetBindData);
    }
}

@end
