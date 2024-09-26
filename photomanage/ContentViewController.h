//
//  ContentViewController.h
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ContentViewControllerDelegate <NSObject>
@optional
- (void)onDelete:(PHAsset *)asset;
@end

@interface ContentViewController : UIViewController
@property (weak) id<ContentViewControllerDelegate> delegate;
@property (nonatomic, strong) PHAsset *content;
@end

NS_ASSUME_NONNULL_END
