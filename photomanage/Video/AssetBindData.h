//
//  AssetBindData.h
//  photomanage
//
//  Created by chenxianming on 2024/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kAssetBindData;
@interface AssetBindData : NSObject<NSCoding>
@property (nonatomic, strong) NSString *orgLocalIdentifier;
@property (nonatomic, strong) NSString *compressedlocalIdentifier;
@property (nonatomic, strong) NSNumber *isCompress;
@end

typedef void (^AssetBindDataCallback)(AssetBindData *bindData);

NS_ASSUME_NONNULL_END
