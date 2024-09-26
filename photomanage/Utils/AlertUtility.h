//
//  AlertUtility.h
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertUtility : NSObject
+ (void)showConfirmationAlertInViewController:(UIViewController *)viewController
                                       withTitle:(NSString *)title
                                         message:(NSString *)message
                               confirmButtonTitle:(NSString *)confirmTitle
                                cancelButtonTitle:(NSString *)cancelTitle
                               completionHandler:(nullable void(^)(BOOL confirmed))completion;
@end

NS_ASSUME_NONNULL_END
