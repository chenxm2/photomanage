//
//  PhotoCollectionViewCell.m
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import "PhotoCollectionViewCell.h"
#import "Masonry.h"
@interface PhotoCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UILabel *selectView;
@end

@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor redColor];
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.backgroundColor = [UIColor greenColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
        
        self.selectView = [[UILabel alloc] init];
        self.selectView.numberOfLines = 0;
        self.selectView.font = [UIFont systemFontOfSize:10];
        self.selectView.backgroundColor = [UIColor greenColor];
        [self.selectView setText:@"当前选中"];
        [self.selectView setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:self.selectView];
        self.contentView.clipsToBounds = YES;
        [self setupConstraints];
        
    }
    return self;
}

- (void)setupConstraints {
    // 这里可以添加额外的初始化代码
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsZero);
    }];
    
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.width.lessThanOrEqualTo(self.contentView).multipliedBy(0.5);
    
    }];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)updateAsset:(PHAsset *)asset isSelect:(Boolean)isSelect {
    self.asset = asset;
    
    NSLog(@"updateAsset ");
    
    if (isSelect) {
        self.selectView.hidden = NO;
    } else {
        self.selectView.hidden = YES;
    }
    
    [self.imageView setSmallImageWithAsset:asset];
}

+ (NSString *)reuseIdentifier {
    return @"PhotoCollectionViewCell";
}

@end
