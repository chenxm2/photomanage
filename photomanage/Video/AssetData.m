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

// 重写 isEqual: 方法
- (BOOL)isEqual:(id)object {
    // 首先检查对象是否是同一个
    if (self == object) {
        return YES;
    }
    
    // 检查对象是否是同一个类或者是否是父类的实例
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    // 将对象转换为 MyClass 类型
    AssetData *otherObject = (AssetData *)object;
    
    // 比较重要的属性，这里以 identifier 为例
    return [self.asset.localIdentifier isEqualToString:otherObject.asset.localIdentifier];
}

// 重写 hash 方法，以确保isEqual的对象具有相同的哈希值
- (NSUInteger)hash {
    return self.asset.localIdentifier.hash;
}

@end
