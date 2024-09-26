//
//  ConfirmDeleteViewCell.h
//  photomanage
//
//  Created by chenxianming on 2024/5/21.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfirmDeleteViewCell : UICollectionViewCell
+ (NSString *)reuseIdentifier;
- (void)updateAsset:(PHAsset *)asset isSelect:(Boolean)isSelect;
@end

NS_ASSUME_NONNULL_END
