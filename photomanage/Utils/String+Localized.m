//
//  String+Localized.m
//  photomanage
//
//  Created by chenxianming on 2024/10/12.
//

#import "String+Localized.h"

@implementation NSString (Localized)
+ (NSString *)localizedStringWithName:(NSString *)name {
    return NSLocalizedString(name, name);
}

+ (NSString *)localizedConfirm {
    return NSLocalizedString(@"confirm", "confirm");
}

+ (NSString *)localizedCancel {
    return NSLocalizedString(@"cancel", "cancel");
}

+ (NSString *)localizedLoading {
    return NSLocalizedString(@"loading", "loading");
}

@end
