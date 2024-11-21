//
//  SettingViewCell.m
//  photomanage
//
//  Created by chenxianming on 2024/11/20.
//

#import "SettingViewCell.h"

@interface SettingViewCell()
@property (nonatomic, strong) SettingInfo *info;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation SettingViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (NSString *)reuseIdentifier {
    return @"SettingViewCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(SettingInfo *)info {
    self.info = info;
    if (info.settingId == SettingIdVertion) {
        self.subTitleLabel.hidden = NO;
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        self.subTitleLabel.text = appVersion;
    } else {
        self.subTitleLabel.hidden = YES;
    }
    
    self.titleLabel.text = info.settingTitle;
}

@end
