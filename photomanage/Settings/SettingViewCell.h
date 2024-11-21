//
//  SettingViewCell.h
//  photomanage
//
//  Created by chenxianming on 2024/11/20.
//

#import <UIKit/UIKit.h>
#import "SettingInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface SettingViewCell : UITableViewCell
+ (NSString *)reuseIdentifier;
- (void)setData:(SettingInfo *)info;
@end

NS_ASSUME_NONNULL_END
