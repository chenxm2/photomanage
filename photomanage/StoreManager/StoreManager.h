//
//  StoreManager.h
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface StoreManager : NSObject

+ (instancetype)sharedManager;

// Fetch available products
- (void)fetchAvailableProducts:(NSSet<NSString *> *)productIdentifiers
                       success:(void (^)(NSArray<SKProduct *> *products))successBlock
                       failure:(void (^)(NSError *error))failureBlock;

// Purchase a product
- (void)purchaseProduct:(NSString *)productIdentifier
                success:(void (^)(void))successBlock
                failure:(void (^)(NSError *error))failureBlock;


// Get total virtual currency
- (NSInteger)getTotalVirtualCurrency;

// Add virtual currency
- (void)addVirtualCurrency:(NSInteger)amount;

@end

NS_ASSUME_NONNULL_END
