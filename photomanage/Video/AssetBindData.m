//
//  AssetBindData.m
//  photomanage
//
//  Created by chenxianming on 2024/9/19.
//

#import "AssetBindData.h"
NSString * const kAssetBindData = @"AssetBindData";

NSString * const kQualityLow = @"低清晰度";
NSString * const kQualityMiddle = @"标准质量";
NSString * const kQualityHigh = @"高保真";

@implementation AssetBindData
// 序列化对象
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [[LogUtility sharedInstance] logDebugWithTag:@"AssetBindData" message:@"encodeWithCoder"];
    [aCoder encodeObject:self.orgLocalIdentifier forKey:@"orgLocalIdentifier"];
    [aCoder encodeObject:self.compressedlocalIdentifier forKey:@"compressedlocalIdentifier"];
    [aCoder encodeObject:self.isCompress forKey:@"isCompress"];
    [aCoder encodeObject:self.compressQulity forKey:@"compressQulity"];
}

// 反序列化对象
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    [[LogUtility sharedInstance] logDebugWithTag:@"AssetBindData" message:@"initWithCoder"];
    self = [super init];
    if (self) {
        if ([aDecoder requiresSecureCoding]) {
            _orgLocalIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"orgLocalIdentifier"];
            _compressedlocalIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"compressedlocalIdentifier"];
            _isCompress = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"isCompress"];
            _compressQulity = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"compressQulity"];
        } else {
            _orgLocalIdentifier = [aDecoder decodeObjectForKey:@"orgLocalIdentifier"];
            _compressedlocalIdentifier = [aDecoder decodeObjectForKey:@"compressedlocalIdentifier"];
            _isCompress = [aDecoder decodeObjectForKey:@"isCompress"];
            _compressQulity = [aDecoder decodeObjectForKey:@"compressQulity"];
        }
        [[LogUtility sharedInstance] logDebugWithTag:@"AssetBindData" message:@"initWithCoder enter"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

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
        if (strongSelf) {
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [archiver encodeObject:strongSelf forKey:kAssetBindData];
            [archiver finishEncoding];
            
            
            [[LogUtility sharedInstance] logInfoWithTag:@"AssetBindData" message:
            [NSString stringWithFormat:@"writeDataToFile size = %d", data.length]];
            
            // 保存序列化数据到 NSUserDefaults
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:strongSelf.orgLocalIdentifier];
            [defaults synchronize];
            [[LogUtility sharedInstance] logInfoWithTag:@"AssetBindData" message:
            [NSString stringWithFormat:@"writeDataToFile data = %@", strongSelf]];
        }
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, orgLocalIdentifier: %@, compressedlocalIdentifier: %@, isCompress: %@,   quality: %@>",
            NSStringFromClass([self class]), self, self.orgLocalIdentifier, self.compressedlocalIdentifier, self.isCompress, self.compressQulity];
}
@end
