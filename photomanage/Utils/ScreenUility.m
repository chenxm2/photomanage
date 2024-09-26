//
//  ScreenUility.m
//  photomanage
//
//  Created by chenxianming on 2024/9/26.
//

#import "ScreenUility.h"

@implementation ScreenUility
+ (void)setForceScreenOn:(BOOL)on
{
    [UIApplication sharedApplication].idleTimerDisabled = on;
}
@end
