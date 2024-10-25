//
//  KeychainHelper.m
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import "KeychainHelper.h"
#import <Security/Security.h>

@implementation KeychainHelper

+ (void)saveString:(NSString *)value forKey:(NSString *)key withCompletion:(void (^)(BOOL success))completion {
    [GCDUtility executeOnSerialQueue:^{
        if (value && key) {
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            [self saveData:data forKey:key withCompletion:completion];
        } else if (completion) {
            [GCDUtility executeOnMainThread:^{
                completion(NO);
            }];
        }
    }];
}

+ (void)loadStringForKey:(NSString *)key withCompletion:(void (^)(NSString *))completion {
    [GCDUtility executeOnSerialQueue:^{
        NSData *data = [self loadDataForKey:key];
        NSString *value = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        [GCDUtility executeOnMainThread:^{
            if (completion) {
                completion(value);
            }
        }];
    }];
}

+ (void)saveNumber:(NSNumber *)value forKey:(NSString *)key withCompletion:(void (^)(BOOL success))completion {
    [GCDUtility executeOnSerialQueue:^{
        if (value && key) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:NO error:nil];
            [self saveData:data forKey:key withCompletion:completion];
        } else if (completion) {
            [GCDUtility executeOnMainThread:^{
                completion(NO);
            }];
        }
    }];
}

+ (void)loadNumberForKey:(NSString *)key withCompletion:(void (^)(NSNumber *))completion {
    [GCDUtility executeOnSerialQueue:^{
        NSData *data = [self loadDataForKey:key];
        NSNumber *value = data ? [NSKeyedUnarchiver unarchivedObjectOfClass:[NSNumber class] fromData:data error:nil] : nil;
        [GCDUtility executeOnMainThread:^{
            if (completion) {
                completion(value);
            }
        }];
    }];
}

+ (void)saveData:(NSData *)data forKey:(NSString *)key withCompletion:(void (^)(BOOL success))completion {
    if (!data || !key) {
        if (completion) {
            [GCDUtility executeOnMainThread:^{
                completion(NO);
            }];
        }
        return;
    }

    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecValueData] = data;

    // Delete existing item
    [self deleteItemForKey:key];

    // Add item to Keychain
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
    if (status == errSecSuccess) {
        if (completion) {
            [GCDUtility executeOnMainThread:^{
                completion(YES);
            }];
        }
    } else {
        if (completion) {
            [GCDUtility executeOnMainThread:^{
                completion(NO);
            }];
        }
    }
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
