//
//  ConfirmDeleteViewCell.m
//  photomanage
//
//  Created by chenxianming on 2024/5/21.
//

#import "ConfirmDeleteViewCell.h"
#import "Masonry.h"
@interface ConfirmDeleteViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImageView *selectImageView;
@end

@implementation ConfirmDeleteViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor redColor];
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.backgroundColor = [UIColor greenColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        self.selectImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.self.selectImageView];
        [self setupConstraints];
        
    }
    return self;
}

- (void)setupConstraints {
    // 这里可以添加额外的初始化代码
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsZero);
    }];
    
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(10); // 顶部与父视图顶部对齐
        make.right.equalTo(self.contentView.mas_right).offset(-10); // 左边与父视图左边对齐
        make.width.equalTo(@12); // 设置固定宽度
        make.height.equalTo(@12); // 设置固定高度
    }];
}

- (void)updateAsset:(PHAsset *)asset isSelect:(Boolean)isSelect {
    self.asset = asset;
    NSLog(@"updateAsset isSelect = %d", isSelect);
    if (isSelect) {
        self.selectImageView.image = [UIImage imageNamed:@"deleteSelected"];
    } else {
        self.selectImageView.image = [UIImage imageNamed:@"deleteNormal"];
    }
    [self.imageView setSmallImageWithAsset:asset];
}

+ (NSString *)reuseIdentifier {
    return @"ConfirmDeleteViewCell";
}

@end
