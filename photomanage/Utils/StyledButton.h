//
//  StyledButton.h
//  photomanage
//
//  Created by chenxianming on 2024/9/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface StyledButton : UIButton
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable UIColor *startColor;
@property (nonatomic) IBInspectable UIColor *endColor;
@property (nonatomic) IBInspectable UIColor *titleColor;
@end

NS_ASSUME_NONNULL_END
