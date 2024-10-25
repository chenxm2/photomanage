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

/**
 Save a string to Keychain with completion handler.
 
 @param value The string to save.
 @param key The key under which to save the string.
 @param completion A block to execute after the save operation completes, indicating success or failure.
 */
+ (void)saveString:(NSString *)value forKey:(NSString *)key withCompletion:(void (^)(BOOL success))completion;

/**
 Load a string from Keychain with completion handler.
 
 @param key The key under which to retrieve the string.
 @param completion A block to execute after the load operation completes, returning the retrieved string or nil if not found.
 */
+ (void)loadStringForKey:(NSString *)key withCompletion:(void (^)(NSString *__nullable value))completion;

/**
 Save a number to Keychain with completion handler.
 
 @param value The number to save.
 @param key The key under which to save the number.
 @param completion A block to execute after the save operation completes, indicating success or failure.
 */
+ (void)saveNumber:(NSNumber *)value forKey:(NSString *)key withCompletion:(void (^)(BOOL success))completion;

/**
 Load a number from Keychain with completion handler.
 
 @param key The key under which to retrieve the number.
 @param completion A block to execute after the load operation completes, returning the retrieved number or nil if not found.
 */
+ (void)loadNumberForKey:(NSString *)key withCompletion:(void (^)(NSNumber *__nullable value))completion;

/**
 Save data to Keychain with completion handler.
 
 @param data The data to save.
 @param key The key under which to save the data.
 @param completion A block to execute after the save operation completes, indicating success or failure.
 */
+ (void)saveData:(NSData *)data forKey:(NSString *)key withCompletion:(void (^)(BOOL success))completion;

/**
 Load data from Keychain.
 
 @param key The key under which to retrieve the data.
 @return The retrieved data or nil if not found.
 */
+ (NSData *)loadDataForKey:(NSString *)key;

/**
 Delete item from Keychain.
 
 @param key The key of the item to delete.
 */
+ (void)deleteItemForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
