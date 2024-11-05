//
//  CustomButtonView.h
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, ButtonImagePosition) {
    ButtonImagePositionLeft,
    ButtonImagePositionRight
};

@class CustomButtonView;

@protocol CustomButtonViewDelegate <NSObject>
-(void)onButtonTap:(CustomButtonView *)view;
@end

IB_DESIGNABLE
@interface CustomButtonView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) ButtonImagePosition imagePosition;

// 可在Storyboard中设置的属性
@property (nonatomic, strong) IBInspectable NSString *buttonText;
@property (nonatomic, strong) IBInspectable UIImage *buttonImage;
@property (nonatomic, assign) IBInspectable NSInteger imagePositionIndex; // 0 for left, 1 for right
@property (nonatomic, assign) IBInspectable CGFloat fontSize;
@property (nonatomic, strong) IBInspectable UIColor *buttonColor;
@property (nonatomic, weak) id<CustomButtonViewDelegate> delegate;

- (void)updateUI; // 更新界面

@end



NS_ASSUME_NONNULL_END
