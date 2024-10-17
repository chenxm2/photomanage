//
//  KeychainHelper.h
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//
#import <Foundation/Foundation.h>
#import <Security/Security.h>
NS_ASSUME_NONNULL_BEGIN

@interface KeychainHelper : NSObject

// Save a string to Keychain
+ (void)saveString:(NSString *)value forKey:(NSString *)key;

// Load a string from Keychain
+ (NSString *)loadStringForKey:(NSString *)key;

// Save a number to Keychain
+ (void)saveNumber:(NSNumber *)value forKey:(NSString *)key;

// Load a number from Keychain
+ (NSNumber *)loadNumberForKey:(NSString *)key;

// Save data to Keychain
+ (void)saveData:(NSData *)data forKey:(NSString *)key;

// Load data from Keychain
+ (NSData *)loadDataForKey:(NSString *)key;

// Delete item from Keychain
+ (void)deleteItemForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
