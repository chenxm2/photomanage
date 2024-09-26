//
//  ActivityIndicatorUtility.h
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActivityIndicatorUtility : NSObject
+ (void)showActivityIndicatorInView:(UIView *)view;
+ (void)hideActivityIndicatorInView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
