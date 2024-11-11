//
//  CustomButtonView.m
//  photomanage
//
//  Created by chenxianming on 2024/11/1.
//

#import "CustomButtonView.h"

@implementation CustomButtonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // 初始化图像视图
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit; // 保持图像比例
    [self addSubview:_imageView];

    // 初始化标签
    _titleLabel = [[UILabel alloc] init];
    [self addSubview:_titleLabel];

    // 添加点击手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped)];
    [self addGestureRecognizer:tapGesture];

    // 设置视图的默认背景色
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 1.0; // 边框宽度
    self.layer.cornerRadius = 8.0; // 圆角
    self.layer.masksToBounds = YES; // 确保子视图在圆角边界内

    // 默认设置
    _imagePosition = ButtonImagePositionLeft;
}

- (void)setButtonText:(NSString *)buttonText {
    _buttonText = buttonText;
    self.titleLabel.text = buttonText;
    [self updateUI];
}

- (void)setButtonImage:(UIImage *)buttonImage {
    _buttonImage = buttonImage;
    self.imageView.image = buttonImage;
    [self updateUI];
}

- (void)setButtonColor:(UIColor *)buttonColor {
    _buttonColor = buttonColor;
    self.layer.borderColor = buttonColor.CGColor; // 边框颜色
    self.titleLabel.textColor = buttonColor;
}

- (void)setImagePositionIndex:(NSInteger)imagePositionIndex {
    _imagePositionIndex = imagePositionIndex;
    self.imagePosition = imagePositionIndex == 0 ? ButtonImagePositionLeft : ButtonImagePositionRight;
    [self updateUI];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
}

// 更新界面
- (void)updateUI {
    [self setupConstraints];
}

- (void)setupConstraints {
    // 移除之前的所有约束
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    
    BOOL hasImage = self.buttonImage != nil;
    int margin = 8;
    
    
    // 设置图标和文字的约束
    if (self.imagePosition == ButtonImagePositionLeft) {
        self.titleLabel.textAlignment = NSTextAlignmentLeft; // 左对齐
        
        if (hasImage) {
            [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self).offset(margin);
                make.centerY.equalTo(self);
                make.height.equalTo(@20); // 固定高度
                make.width.equalTo(@20); // 固定宽度
            }];
            
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.imageView.mas_trailing).offset(0); // 与图像保持一定距离
                make.trailing.equalTo(self).offset(-margin);
                make.centerY.equalTo(self);
            }];
        } else {
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self).offset(margin);
                make.trailing.equalTo(self).offset(-margin);
                make.centerY.equalTo(self);
            }];
        }
    } else if (self.imagePosition == ButtonImagePositionRight) {
        self.titleLabel.textAlignment = NSTextAlignmentRight; // 右对齐

        if (hasImage) {
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self).offset(margin);
                make.trailing.equalTo(self.imageView.mas_leading).offset(0); // 与图像保持一定距离
                make.centerY.equalTo(self);
            }];

            [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self).offset(-margin);
                make.centerY.equalTo(self);
                make.height.equalTo(@20); // 固定高度
                make.width.equalTo(@20); // 固定宽度
            }];
        } else {
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self).offset(margin);
                make.trailing.equalTo(self).offset(-margin);
                make.centerY.equalTo(self);
            }];
        }
    }
}

- (void)buttonTapped {
    NSLog(@"Button tapped: %@", self.titleLabel.text);
    // 可以在这里执行其他操作，比如发出通知或执行回调
    if ([self.delegate respondsToSelector:@selector(onButtonTap:)]) {
        [self.delegate onButtonTap:self];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [self.buttonColor colorWithAlphaComponent:0.3]; // 按下状态
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor clearColor]; // 恢复背景颜色
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor clearColor]; // 恢复背景颜色
}

- (void)dealloc {
    // 自定义的清理操作
}

@end
