//
//  StyledButton.m
//  photomanage
//
//  Created by chenxianming on 2024/9/19.
//

#import "StyledButton.h"

@implementation StyledButton

// 默认属性值
#define DEFAULT_CORNER_RADIUS 10.0
#define DEFAULT_START_COLOR [UIColor colorWithRed:0.1 green:0.6 blue:0.8 alpha:0.5]
#define DEFAULT_END_COLOR [UIColor colorWithRed:0.2 green:0.2 blue:0.6 alpha:0.5]
#define DEFAULT_TITLE_COLOR [UIColor whiteColor]

// 当从 XIB/Storyboard 初始化时调用
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupButtonStyle];
}

// 当以编程方式初始化时调用
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButtonStyle];
    }
    return self;
}

// 在 Interface Builder 中实时渲染样式
- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self setupButtonStyle];
}

// 设置按钮的样式
- (void)setupButtonStyle {
    // 如果 cornerRadius 没有指定，使用默认值
    self.layer.cornerRadius = self.cornerRadius ?: DEFAULT_CORNER_RADIUS;
    self.clipsToBounds = YES;
    
    // 设置背景颜色，带有透明度
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

    UIColor *titleColor = self.titleColor ?: DEFAULT_TITLE_COLOR;
    
    // 设置文字颜色和字体
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    [self setTintColor:titleColor];
    
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
}

// 设置 IBInspectable 属性的 setter 方法
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

// 设置 startColor
- (void)setStartColor:(UIColor *)startColor {
    _startColor = startColor;
    [self setupButtonStyle];
}


// 设置 endColor
- (void)setEndColor:(UIColor *)endColor {
    _endColor = endColor;
    [self setupButtonStyle];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

}

@end

