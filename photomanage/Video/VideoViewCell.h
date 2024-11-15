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


@class VideoViewCell;

@protocol VideoViewCellDelegate <NSObject>
-(void)onDeleteButtonTap:(VideoViewCell *)cell data:(AssetData *)data;
@end


@interface VideoViewCell : UICollectionViewCell
+ (NSString *)reuseIdentifier;
@property (nonatomic, weak) id<VideoViewCellDelegate> delegete;
- (void)updateAssetData:(AssetData *)data showDelete:(BOOL)showDelete shouldShowViewd:(BOOL)shouldShowViewed;
@end

NS_ASSUME_NONNULL_END
