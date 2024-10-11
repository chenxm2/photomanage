//
//  AssetBindData.h
//  photomanage
//
//  Created by chenxianming on 2024/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kAssetBindData;

extern NSString * const kQualityLow;
extern NSString * const kQualityMiddle;
extern NSString * const kQualityHigh;

@interface AssetBindData : NSObject<NSSecureCoding>
@property (nonatomic, strong) NSString *orgLocalIdentifier; //当前频的id
@property (nonatomic, strong) NSString *compressedlocalIdentifier; //与这个视频关联的压缩视频id
@property (nonatomic, strong) NSNumber *isCompress; //当前频是否进行压缩过。与compressedlocalIdentifier 成对。压缩结果是compressedlocalIdentifier对应的视频。
@property (nonatomic, strong) NSString *compressQulity; //当前视频本身是否也是被压过的视频，自身的压缩档位。
@end

typedef void (^AssetBindDataCallback)(AssetBindData *bindData);

NS_ASSUME_NONNULL_END
