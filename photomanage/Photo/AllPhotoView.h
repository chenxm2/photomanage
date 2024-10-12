//
//  AllPhotoView.h
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@protocol AllPhotoViewDelegate <NSObject>
@optional
- (void)didSelect:(PHAsset *)asset;
@end

@interface AllPhotoView : UIView
@property (weak, nonatomic) id<AllPhotoViewDelegate> delegate;
+ (instancetype)viewWithParameter:(NSMutableArray<PHAsset *> *) assetsArray selectAsset:(PHAsset *)asset frame:(CGRect)frame; // 类方法声明
@end

NS_ASSUME_NONNULL_END
