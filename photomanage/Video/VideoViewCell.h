//
//  VideoViewCell.h
//  photomanage
//
//  Created by chenxianming on 2024/9/2.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "AssetData.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoViewCell : UICollectionViewCell
+ (NSString *)reuseIdentifier;
- (void)updateAssetData:(AssetData *)data isSelected:(BOOL)isSelected;
@end

NS_ASSUME_NONNULL_END
