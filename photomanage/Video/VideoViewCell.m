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
@property (weak, nonatomic) IBOutlet UILabel *compressedTag;
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
    self.compressedTag.layer.cornerRadius = 2;
    self.compressedTag.clipsToBounds = true;
}

+ (NSString *)reuseIdentifier {
    return @"VideoViewCell";
}

- (void)updateAssetData:(AssetData *)data; {
    [self.imageView setSmallImageWithAsset:data.asset];
    self.sizeLabel.text = [NSString fileSizeStringWithNumber:data.fileSize];
    WEAK_SELF
    
    [data loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
        STRONG_SELF
        if (strongSelf) {
            if ([bindData.isCompress boolValue]) {
                self.compressedTag.hidden = NO;
            } else {
                self.compressedTag.hidden = YES;
            }
            
            self.compressQuality.text = [bindData getQualityString];
        }
    }];
}

@end
