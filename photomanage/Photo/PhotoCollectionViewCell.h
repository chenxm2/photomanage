//
//  PhotoCollectionViewCell.h
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotoCollectionViewCell : UICollectionViewCell
+ (NSString *)reuseIdentifier;
- (void)updateAsset:(PHAsset *)asset isSelect:(Boolean)isSelect;
@end



NS_ASSUME_NONNULL_END
