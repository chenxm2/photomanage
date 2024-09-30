//
//  AssetBindData.m
//  photomanage
//
//  Created by chenxianming on 2024/9/19.
//

#import "AssetBindData.h"
NSString * const kAssetBindData = @"AssetBindData";
@implementation AssetBindData
// 序列化对象
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.orgLocalIdentifier forKey:@"orgLocalIdentifier"];
    [aCoder encodeObject:self.compressedlocalIdentifier forKey:@"compressedlocalIdentifier"];
    [aCoder encodeObject:self.isCompress forKey:@"isCompress"];
}

// 反序列化对象
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.orgLocalIdentifier = [aDecoder decodeObjectForKey:@"orgLocalIdentifier"];
        self.compressedlocalIdentifier = [aDecoder decodeObjectForKey:@"compressedlocalIdentifier"];
        self.isCompress = [aDecoder decodeObjectForKey:@"isCompress"];
    }
    return self;
}

- (void)setOrgLocalIdentifier:(NSString *)orgLocalIdentifier {
    _orgLocalIdentifier = orgLocalIdentifier;
    [self writeDataToFile];
}

- (void)setIsCompress:(NSNumber *)isCompress {
    _isCompress = isCompress;
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
        if (strongSelf) {
            NSMutableData *data = [NSMutableData data];

            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
            [archiver encodeObject:strongSelf forKey:kAssetBindData];
            [archiver finishEncoding];
            
            // 保存序列化数据到 NSUserDefaults
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:strongSelf.orgLocalIdentifier];
        }
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, orgLocalIdentifier: %@, compressedlocalIdentifier: %@, isCompress: %@>",
            NSStringFromClass([self class]), self, self.orgLocalIdentifier, self.compressedlocalIdentifier, self.isCompress];
}
@end
