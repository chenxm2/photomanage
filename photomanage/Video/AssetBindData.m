//
//  AssetBindData.m
//  photomanage
//
//  Created by chenxianming on 2024/9/19.
//

#import "AssetBindData.h"
NSString * const kAssetBindData = @"AssetBindData";

NSString * const kQualityLow = @"低清";
NSString * const kQualityMiddle = @"标清";
NSString * const kQualityHigh = @"高清";

@implementation AssetBindData
- (void)setOrgLocalIdentifier:(NSString *)orgLocalIdentifier {
    _orgLocalIdentifier = orgLocalIdentifier;
    [self writeDataToFile];
}

- (void)setIsCompress:(NSNumber *)isCompress {
    _isCompress = isCompress;
    [self writeDataToFile];
}

- (void)setCompressQulity:(NSString *)compressQulity {
    _compressQulity = compressQulity;
    [self writeDataToFile];
}

- (void)setCompressedlocalIdentifier:(NSString *)compressedlocalIdentifier
{
    _compressedlocalIdentifier = compressedlocalIdentifier;
    [self writeDataToFile];
}

- (void)writeDataToFile {
    WEAK_SELF
    [GCDUtility executeOnSerialQueue:^{
        STRONG_SELF
//        NSMutableData *data = [NSMutableData data];
//        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//        [archiver encodeObject:strongSelf forKey:kAssetBindData];
//        [archiver finishEncoding];
        NSData *data = [JSONConverter dataFromModel:strongSelf];
        
        // 保存序列化数据到 NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:strongSelf.orgLocalIdentifier];
        [defaults synchronize];
    }];
}

- (NSString *)getQualityString {
    if (self.compressQulity == nil) {
        return @"原始";
    } else {
        return self.compressQulity;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %p, orgLocalIdentifier: %@, compressedlocalIdentifier: %@, isCompress: %@,   quality: %@",
            NSStringFromClass([self class]), self, self.orgLocalIdentifier, self.compressedlocalIdentifier, self.isCompress, self.compressQulity];
}
@end
