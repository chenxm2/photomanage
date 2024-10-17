//
//  KeychainHelper.m
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import "KeychainHelper.h"
#import <Security/Security.h>

#import "KeychainHelper.h"
#import <Security/Security.h>

@implementation KeychainHelper
+ (void)saveString:(NSString *)value forKey:(NSString *)key {
    if (value && key) {
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
        [self saveData:data forKey:key];
    }
}

+ (NSString *)loadStringForKey:(NSString *)key {
    NSData *data = [self loadDataForKey:key];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

+ (void)saveNumber:(NSNumber *)value forKey:(NSString *)key {
    if (value && key) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:NO error:nil];
        [self saveData:data forKey:key];
    }
}

+ (NSNumber *)loadNumberForKey:(NSString *)key {
    NSData *data = [self loadDataForKey:key];
    return data ? [NSKeyedUnarchiver unarchivedObjectOfClass:[NSNumber class] fromData:data error:nil] : nil;
}

+ (void)saveData:(NSData *)data forKey:(NSString *)key {
    if (!data || !key) {
        return;
    }

    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecValueData] = data;

    // Delete existing item
    [self deleteItemForKey:key];

    // Add item to Keychain
    SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

+ (NSData *)loadDataForKey:(NSString *)key {
    if (!key) {
        return nil;
    }

    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecReturnData] = @YES;
    keychainItem[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, &result);
    return (__bridge_transfer NSData *)result;
}

+ (void)deleteItemForKey:(NSString *)key {
    if (!key) {
        return;
    }

    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = key;

    SecItemDelete((__bridge CFDictionaryRef)keychainItem);
}

@end
