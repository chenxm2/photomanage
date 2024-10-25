//
//  StoreManager.h
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kProductId;
extern NSUInteger const kProductIdContainCoin;
extern NSUInteger const kOnePhotoCost;
extern NSUInteger const kOneVideoCost;
@interface StoreManager : NSObject

+ (instancetype)sharedManager;

// Fetch available products
- (BOOL)fetchAvailableProducts:(NSSet<NSString *> *)productIdentifiers
                       success:(void (^)(NSArray<SKProduct *> *products))successBlock
                       failure:(void (^)(NSError *error))failureBlock;

// Purchase a product
- (BOOL)purchaseProduct:(NSString *)productIdentifier
                success:(void (^)(void))successBlock
                failure:(void (^)(NSError *error))failureBlock;


// Get total virtual currency
- (BOOL)getTotalVirtualCurrencyWithCompletion:(void (^)(NSUInteger value))completion;

- (BOOL)subVirtualCurrency:(NSUInteger)amount completion:(CompletionResult)completion;
@end

#define STOTE_MANAGER [StoreManager sharedManager]

NS_ASSUME_NONNULL_END
