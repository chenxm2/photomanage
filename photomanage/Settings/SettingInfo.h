//
//  SettingInfo.h
//  photomanage
//
//  Created by chenxianming on 2024/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SettingId) {
    SettingIdAboutBegin,
    SettingIdVertion,
//    SettingIdUsage,
    SettingIdPrivacy,
    SettingIdAboutEnd,
};

@interface SettingInfo : NSObject
@property (nonatomic, assign) NSInteger settingId;
@property (nonatomic, strong) NSString *settingTitle;
@end

NS_ASSUME_NONNULL_END
