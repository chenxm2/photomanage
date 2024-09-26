//
//  AssetData.m
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import "AssetData.h"
static NSString * const kIsCompress = @"";
@interface AssetData ()
@property (nonatomic, strong) NSNumber *isCompress;
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

- (BOOL)isHasCompress {
    if (self.isCompress == nil) {
        self.isCompress =  [[NSUserDefaults standardUserDefaults] objectForKey:self.asset.localIdentifier];
    }
    
    
    return [self.isCompress boolValue];
}

- (void)setHasCompress:(bool)hasCompress {
    self.isCompress = [[NSNumber alloc] initWithBool:hasCompress];
    [[NSUserDefaults standardUserDefaults] setObject:self.isCompress forKey:self.asset.localIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
