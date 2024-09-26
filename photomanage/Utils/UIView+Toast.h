//
//  UIView+Toast.h
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Toast)
- (void)showToastWithMessage:(NSString *)message;
- (void)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
