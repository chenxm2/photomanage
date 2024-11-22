//
//  String+Localized.m
//  photomanage
//
//  Created by chenxianming on 2024/10/12.
//

#import "String+Localized.h"

@implementation NSString (Localized)

+ (NSString *)localizedStringWithFormat:(NSString *)name, ... {
    va_list args;
    va_start(args, name);
    
    NSString *localizedString = NSLocalizedString(name, name);
    NSString *formattedString = [[NSString alloc] initWithFormat:localizedString arguments:args];
    
    va_end(args);
    return formattedString;
}

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
