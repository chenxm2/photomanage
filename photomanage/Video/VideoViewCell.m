//
//  VideoViewCell.m
//  photomanage
//
//  Created by chenxianming on 2024/9/2.
//

#import "VideoViewCell.h"
#import <Photos/Photos.h>
#import "../Utils/String+FileSize.h"


@interface VideoViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressQuality;

@end
@implementation VideoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentView.backgroundColor = [UIColor redColor];
    self.contentView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor greenColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
}

+ (NSString *)reuseIdentifier {
    return @"VideoViewCell";
}

- (void)updateAssetData:(AssetData *)data isSelected:(BOOL)isSelected {
    [self.imageView setSmallImageWithAsset:data.asset];
    self.sizeLabel.text = [NSString fileSizeStringWithNumber:data.fileSize];
    WEAK_SELF
    
    [data loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
        STRONG_SELF
        if (strongSelf) {
            self.compressQuality.text = [bindData getQualityString];
        }
    }];
    
    if (isSelected) {
        self.contentView.layer.borderWidth = 2.0; // 边框宽度
        self.contentView.layer.borderColor = [UIColor blackColor].CGColor; // 边框颜色
        self.contentView.layer.cornerRadius = 6.0; 
        self.contentView.clipsToBounds = YES; // 裁剪子视图
    } else {
        self.contentView.layer.borderWidth = 0; // 移除边框
        self.contentView.layer.borderColor = nil;
        self.contentView.clipsToBounds = NO; // 取消裁剪
    }
}

@end
