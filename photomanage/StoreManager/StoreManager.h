//
//  StoreManager.h
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kProductIdOnce;
extern NSString * const kProductIdForever;
extern NSUInteger const kProductIdContainCoin;
extern NSUInteger const kOnePhotoCost;
extern NSUInteger const kOneVideoCost;

@protocol StoreManagerObserver <NSObject>
@optional
- (void)onVirtualCurrencyUpdate:(NSUInteger)virtualCurrency;
- (void)onLastPurchaseInterrupt:(BOOL)isInterrupt;
- (void)onBecomeMember;
@end

@interface StoreManager : NSObject
+ (instancetype)sharedManager;

- (void)addObserver:(id<StoreManagerObserver>)observer;
- (void)removeObserver:(id<StoreManagerObserver>)observer;

// Fetch available products
- (BOOL)fetchAvailableProducts:(NSSet<NSString *> *)productIdentifiers
                       success:(void (^)(NSArray<SKProduct *> *products))successBlock
                       failure:(void (^)(NSError *error))failureBlock;

// Purchase a product
- (BOOL)purchaseProduct:(NSString *)productIdentifier
                success:(void (^)(void))successBlock
                failure:(void (^)(NSError *error))failureBlock;


- (void)resumeInterruptProductSuccess:(void (^)(void))successBlock
                    failure:(void (^)(NSError *error))failureBlock;

- (void)removeReceiptData;
- (BOOL)isLastPurchaseInterrupt;
- (BOOL)isMemberForever;
- (void)loadIsMemer;

// Get total virtual currency
- (BOOL)getTotalVirtualCurrencyWithCompletion:(void (^)(NSUInteger value))completion;

- (BOOL)subVirtualCurrency:(NSUInteger)amount completion:(CompletionResult)completion;

- (BOOL)addVirtualCurrency:(NSUInteger)amount completion:(CompletionResult)completion;

- (void)clearCoins:(CallBack)callBack;
- (void)clearCoinsAndState:(CallBack)callBack;
- (void)clearMember;
@end

#define STORE_MANAGER [StoreManager sharedManager]

NS_ASSUME_NONNULL_END
