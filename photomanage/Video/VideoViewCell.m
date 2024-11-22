//
//  VideoViewCell.m
//  photomanage
//
//  Created by chenxianming on 2024/9/2.
//

#import "VideoViewCell.h"
#import <Photos/Photos.h>
#import "../Utils/String+Bussiness.h"
#import "VideoDataManager.h"


@interface VideoViewCell() <CustomButtonViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *compressQuality;
@property (weak, nonatomic) IBOutlet CustomButtonView *deleteButton;
@property (nonatomic, strong) AssetData *data;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteTag;
@property (weak, nonatomic) IBOutlet UIImageView *viewedImage;

@end
@implementation VideoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.deleteButton.delegate = self;
}

+ (NSString *)reuseIdentifier {
    return @"VideoViewCell";
}

- (void)updateAssetData:(AssetData *)data showDelete:(BOOL)showDelete shouldShowViewd:(BOOL)shouldShowViewed {
    self.data = data;
    [self.imageView setSmallImageWithAsset:data.asset];
    self.sizeLabel.text = [NSString fileSizeStringWithNumber:data.fileSize];
    WEAK_SELF
    
    [data loadBindData:^(AssetBindData * _Nonnull bindData, AssetData * _Nonnull data) {
        STRONG_SELF
        strongSelf.compressQuality.text = [bindData getQualityString];
        if (shouldShowViewed && bindData.viewed) {
            strongSelf.viewedImage.hidden = NO;
        } else {
            strongSelf.viewedImage.hidden = YES;
        }
    }];
    
    if (showDelete) {
        self.deleteButton.hidden = NO;
    } else {
        self.deleteButton.hidden = YES;
    }
    
//    [VIDEO_DATA_MANAGER checkIfVideoIsOnlyInCloud:data.asset callback:^(AVAsset * _Nullable result) {
//        STRONG_SELF
//         strongSelf.icloudTag.hidden = (result != nil);
//    }];
    
    if (data.asset.isFavorite) {
        self.favoriteTag.hidden = NO;
    } else {
        self.favoriteTag.hidden = YES;
    }
}

-(void)onButtonTap:(CustomButtonView *)view {
    if ([self.delegete respondsToSelector:@selector(onDeleteButtonTap:data:)]) {
        [self.delegete onDeleteButtonTap:self data:self.data];
    }
}


@end
