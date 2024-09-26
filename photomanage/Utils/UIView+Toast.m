//
//  UIView+Toast.m
//  photomanage
//
//  Created by chenxianming on 2024/9/18.
//

#import "UIView+Toast.h"

@implementation UIView (Toast)
- (void)showToastWithMessage:(NSString *)message {
    [self showToastWithMessage:message duration:3.0];
}

- (void)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration {
    UILabel *toastLabel = [[UILabel alloc] init];
    toastLabel.text = message;
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.numberOfLines = 0;
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds = YES;
    
    // Set size based on text content
    CGSize maxSize = CGSizeMake(self.bounds.size.width - 40, self.bounds.size.height - 40);
    CGSize textSize = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: toastLabel.font} context:nil].size;
    toastLabel.frame = CGRectMake(0, 0, textSize.width + 20, textSize.height + 20);
    toastLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - toastLabel.bounds.size.height - 50);
    
    
    [self addSubview:toastLabel];
    [UIView animateWithDuration:0.33 delay:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
        toastLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [toastLabel removeFromSuperview];
    }];
}

@end
