//
//  VideoViewCell.m
//  photomanage
//
//  Created by chenxianming on 2024/9/2.
//

#import "VideoViewCell.h"
#import <Photos/Photos.h>
#import "../Utils/String+FileSize.h"


@interface VideoViewCell() <CustomButtonViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressQuality;
@property (weak, nonatomic) IBOutlet CustomButtonView *deleteButton;
@property (nonatomic, strong) AssetData *data;

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
    self.deleteButton.delegate = self;
}

+ (NSString *)reuseIdentifier {
    return @"VideoViewCell";
}

- (void)updateAssetData:(AssetData *)data showDelete:(BOOL)showDelete {
    self.data = data;
    [self.imageView setSmallImageWithAsset:data.asset];
    self.sizeLabel.text = [NSString fileSizeStringWithNumber:data.fileSize];
    WEAK_SELF
    
    [data loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
        STRONG_SELF
        if (strongSelf) {
            self.compressQuality.text = [bindData getQualityString];
        }
    }];
    
    if (showDelete) {
        self.deleteButton.hidden = NO;
    } else {
        self.deleteButton.hidden = YES;
    }
}

-(void)onButtonTap:(CustomButtonView *)view {
    if ([self.delegete respondsToSelector:@selector(onDeleteButtonTap:data:)]) {
        [self.delegete onDeleteButtonTap:self data:self.data];
    }
}


@end
