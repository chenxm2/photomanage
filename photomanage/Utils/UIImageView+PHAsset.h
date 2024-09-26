//
//  UIImageView+PHAsset.h
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImageView.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (PHAsset)
- (void)setImageWithAsset:(PHAsset *)asset;
- (void)setSmallImageWithAsset:(PHAsset *)asset;
@end

NS_ASSUME_NONNULL_END
