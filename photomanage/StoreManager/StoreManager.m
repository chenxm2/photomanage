//
//  StoreManager.m
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import "StoreManager.h"
#import "KeychainHelper.h"
#import <RMStore/RMStore.h>


NSString * const kProductId = @"com.private.test.photomanage.product1";
NSUInteger const kProductIdContainCoin = 100;
NSUInteger const kOnePhotoCost = 1;
NSUInteger const kOneVideoCost = 10;
NSUInteger const kFirstFreeVirtualCurrency = 100;

NSString * const kUniqueDeviceIdentifier = @"uniqueDeviceIdentifier";

@interface StoreManager () <RMStoreObserver, RMStoreReceiptVerificator>
@property (nonatomic, strong) RMStore *store;
@property (nonatomic, strong) NSString *savedCoinsKey;
@property (nonatomic, strong) NSHashTable<id<StoreManagerObserver>> *observers;

@end

@implementation StoreManager

+ (instancetype)sharedManager {
    static StoreManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[StoreManager alloc] init];
        sharedInstance.store = [RMStore defaultStore]; // Initialize RMStore
        sharedInstance.store.receiptVerificator = sharedInstance;
        [sharedInstance.store addStoreObserver:sharedInstance]; // Add self as an observer
    });
    return sharedInstance;
}

// 初始化
- (instancetype)init {
    
    self = [super init];
    if (self) {
        _observers = [NSHashTable weakObjectsHashTable]; // 使用弱引用防止循环引用
    }

    return self;
}

// 添加观察者
- (void)addObserver:(id<StoreManagerObserver>)observer {
    @synchronized (_observers) {
        if (![_observers containsObject:observer]) {
            [_observers addObject:observer];
        }
    }
}

// 移除观察者
- (void)removeObserver:(id<StoreManagerObserver>)observer {
    @synchronized (_observers) {
        [_observers removeObject:observer];
    }
}

// 更新虚拟货币值
- (void)notifyUpdateVirtualCurrency:(NSUInteger)newValue {
    // 通知所有观察者
    @synchronized (_observers) {
        for (id<StoreManagerObserver> observer in _observers) {
            if ([observer respondsToSelector:@selector(onVirtualCurrencyUpdate:)]) {
                [observer onVirtualCurrencyUpdate:newValue];
            }
        }
    }
}

// Fetch available products
- (BOOL)fetchAvailableProducts:(NSSet<NSString *> *)productIdentifiers
                       success:(void (^)(NSArray<SKProduct *> *))successBlock
                       failure:(void (^)(NSError *))failureBlock {
    if (successBlock == nil || successBlock == nil || productIdentifiers == nil) {
        return NO;
    }
    
    [self.store requestProducts:productIdentifiers success:^(NSArray *products, NSArray *invalidProductIdentifiers) { 
        [GCDUtility executeOnMainThread:^{
            successBlock(products);
        }];
            
        } failure:^(NSError *error) {
            [GCDUtility executeOnMainThread:^{
                failureBlock(error);
            }];
        }];
    
    return YES;
}

// Purchase a product
- (BOOL)purchaseProduct:(NSString *)productIdentifier
                success:(void (^)(void))successBlock
                failure:(void (^)(NSError *error))failureBlock {
    if (successBlock == nil || failureBlock == nil) {
        return NO;
    }
    
    [self.store addPayment:productIdentifier success:^(SKPaymentTransaction *transaction) {
        NSLog(@"purchaseProduct success");
        NSInteger coins = [self virtualCurrencyForProduct:productIdentifier];
        [self addVirtualCurrency:coins completion:^(BOOL result) {
            if (result) {
                successBlock();
            } else {
                //todo: 后续考虑是不是把流程插入到验证阶段，存本地成功再验证通过。
                failureBlock(nil);
            }
        }];
            
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            [GCDUtility executeOnMainThread:^{
                failureBlock(error);
            }];
    }];
    
    return YES;
}

// Verify transaction using Apple’s validation service
- (void)verifyTransaction:(SKPaymentTransaction *)transaction
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock {
    
    
    if (successBlock) {
        // todo:修复验证逻辑，callBack也一定要主线程
        [GCDUtility executeOnMainThread:^{
                    successBlock();
        }];
        return;
    }
    // Get the receipt data directly from the transaction
    NSData *receiptData = transaction.transactionReceipt;

    if (!receiptData) {
        // Handle receipt not found
        if (failureBlock) {
            NSError *error = [NSError errorWithDomain:@"StoreManagerErrorDomain"
                                                 code:1001
                                             userInfo:@{NSLocalizedDescriptionKey : @"Receipt data not found."}];
            failureBlock(error);
        }
        return;
    }

    // Convert receipt data to base64 string
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:0];

    // Create the request to Apple’s server
    NSURL *url = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"]; // For production
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"receipt-data": receiptString}
                                                    options:0
                                                      error:nil];
    request.allHTTPHeaderFields = @{@"Content-Type": @"application/json"};

    // Send the request
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (failureBlock) {
                failureBlock(error);
            }
            return;
        }

        // Parse the response
        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (jsonError) {
            if (failureBlock) {
                failureBlock(jsonError);
            }
            return;
        }

        // Check the status of the response
        NSNumber *status = jsonResponse[@"status"];
        if ([status integerValue] == 0) {
            // Receipt is valid, check transactions
            NSArray *latestReceiptInfo = jsonResponse[@"latest_receipt_info"];
            BOOL transactionFound = NO;

            for (NSDictionary *transactionInfo in latestReceiptInfo) {
                // Compare the transaction ID or product ID to verify
                if ([transactionInfo[@"transaction_id"] isEqualToString:transaction.transactionIdentifier] &&
                    [transactionInfo[@"product_id"] isEqualToString:transaction.payment.productIdentifier]) {
                    transactionFound = YES;
                    break;
                }
            }

            if (transactionFound) {
                // Verified transaction successfully
                if (successBlock) {
                    successBlock();
                }
            } else {
                // Transaction not found in the receipt
                NSError *validationError = [NSError errorWithDomain:@"StoreManagerErrorDomain"
                                                                code:1002
                                                            userInfo:@{NSLocalizedDescriptionKey : @"Transaction not found in receipt."}];
                if (failureBlock) {
                    failureBlock(validationError);
                }
            }
        } else {
            // Receipt is invalid, handle error based on status code
            NSError *validationError = [NSError errorWithDomain:@"StoreManagerErrorDomain"
                                                            code:[status integerValue]
                                                        userInfo:@{NSLocalizedDescriptionKey : @"Receipt validation failed."}];
            if (failureBlock) {
                failureBlock(validationError);
            }
        }
    }];

    [task resume];
}

// Get unique device identifier
- (BOOL)getOrCreateUUIDWithCompletion:(void (^)(NSString *__nullable coinKey, BOOL isCreate))completion {
    if (completion == nil) {
        return NO;
    }
    
    if (self.savedCoinsKey != nil) {
        [GCDUtility executeOnMainThread:^{
            completion(self.savedCoinsKey, NO);
        }];
        return YES;
    }
    
    NSString *key = kUniqueDeviceIdentifier;
    [KeychainHelper loadStringForKey:key withCompletion:^(NSString * _Nullable value) {
        if (!value) {
            LogInfo(@"new uniqueDeviceIdentifier = %@", value);
            value = [[NSUUID UUID] UUIDString];
            [KeychainHelper saveString:value forKey:key withCompletion:^(BOOL success) {
                if (success) {
                    self.savedCoinsKey = value;
                    completion(value, YES);
                    
                } else {
                    completion(nil, NO);
                }
            }];
        } else {
            LogInfo(@"use old uniqueDeviceIdentifier = %@", value);
            self.savedCoinsKey = value;
            completion(value, NO);
        }
    }];
    
    return YES;
}

// Get total virtual currency from Keychain
- (BOOL)getTotalVirtualCurrencyWithCompletion:(void (^)(NSUInteger value))completion {
    
    if (completion == nil) {
        LogInfo(@"getTotalVirtualCurrencyWithCompletion completion nil");
        return NO;
    }
    
    LogInfo(@"getTotalVirtualCurrencyWithCompletion begin");
    
    [self getOrCreateUUIDWithCompletion:^(NSString * _Nullable coinKey, BOOL isCreate) {
        if (coinKey != nil) {
            LogInfo(@"getTotalVirtualCurrencyWithCompletion coinKey = %@, isCreate = %d", coinKey, isCreate);
            if (isCreate) {
                [KeychainHelper saveNumber:@(kFirstFreeVirtualCurrency) forKey:coinKey withCompletion:^(BOOL success) {
                    LogInfo(@"getTotalVirtualCurrency by isCreate %lu", kFirstFreeVirtualCurrency);
                    completion(kFirstFreeVirtualCurrency);
                }];
            
            } else {
                [KeychainHelper loadNumberForKey:coinKey withCompletion:^(NSNumber * _Nullable value) {
                    if (value != nil) {
                        LogInfo(@"getTotalVirtualCurrency = %lu", [value unsignedIntegerValue]);
                        completion([value unsignedIntegerValue]);
                    } else {
                        completion(0);
                    }
                }];
            }
            
        } else {
            completion(0);
        }
    }];
    
    return YES;
}

- (BOOL)subVirtualCurrency:(NSUInteger)amount completion:(CompletionResult)completion {

    if (completion == nil) {
        return NO;
    }
    
    [self getTotalVirtualCurrencyWithCompletion:^(NSUInteger value) {
        NSUInteger result = value - amount;
        [self getOrCreateUUIDWithCompletion:^(NSString * _Nullable coinKey, BOOL isCreate) {
            [KeychainHelper saveNumber:@(result) forKey:coinKey withCompletion:^(BOOL success) {
                completion(success);
                if (success) {
                    [self notifyUpdateVirtualCurrency:result];
                    LogInfo(@"subVirtualCurrency current = %lu, amount = %lu, result = %lu ", value, amount, result);
                } else {
                    LogInfo(@"subVirtualCurrency fail");
                }
            }];
        }];
    }];
    
    return YES;
}

// Add virtual currency to total
- (BOOL)addVirtualCurrency:(NSUInteger)amount completion:(CompletionResult)completion {
    if (completion == nil) {
        return NO;
    }
    LogInfo(@"begin addVirtualCurrency");
    [self getTotalVirtualCurrencyWithCompletion:^(NSUInteger value) {
        NSUInteger result = amount + value;
        [self getOrCreateUUIDWithCompletion:^(NSString * _Nullable coinKey, BOOL isCreate) {
            [KeychainHelper saveNumber:@(result) forKey:coinKey withCompletion:^(BOOL success) {
                completion(success);
                if (success) {
                    [self notifyUpdateVirtualCurrency:result];
                    LogInfo(@"addVirtualCurrency current = %lu, amount = %lu, result = %lu ", value, amount, result);
                } else {
                    LogInfo(@"addVirtualCurrency fail");
                }
            }];
        }];
    }];
    
    return YES;
}

// Get virtual currency amount for specific product
- (NSInteger)virtualCurrencyForProduct:(NSString *)productIdentifier {
    // Add logic to determine the virtual currency amount for the given product
    // Example:
    if ([productIdentifier isEqualToString:kProductId]) {
        return kProductIdContainCoin; // 100 units for product 1
    }
    return 0; // Default to 0 if not found
}

- (void)clearCoins:(CallBack)callBack {
    [self getOrCreateUUIDWithCompletion:^(NSString * _Nullable coinKey, BOOL isCreate) {
        [KeychainHelper saveNumber:@(0) forKey:coinKey withCompletion:^(BOOL success) {
            if (success) {
                [self notifyUpdateVirtualCurrency:0];
                if (callBack) {
                    callBack();
                }
                LogInfo(@"clearCoins success");
            } else {
                LogInfo(@"clearCoins fail");
            }
        }];
    }];
}

- (void)clearCoinsAndState:(CallBack)callBack {
    self.savedCoinsKey = nil;
    [self getOrCreateUUIDWithCompletion:^(NSString * _Nullable coinKey, BOOL isCreate) {
        [KeychainHelper saveNumber:@(0) forKey:coinKey withCompletion:^(BOOL success) {
            if (success) {
                [self notifyUpdateVirtualCurrency:0];
                LogInfo(@"clearCoinsAndState coins success");
            } else {
                LogInfo(@"clearCoinsAndState coins fail");
            }
        }];
    }];
    
    [GCDUtility executeOnSerialQueue:^{
        [KeychainHelper deleteItemForKey:kUniqueDeviceIdentifier];
        [GCDUtility executeOnMainThread:^{
            LogInfo(@"clearCoinsAndState kUniqueDeviceIdentifier success");
            if (callBack) {
                callBack();
            }
        }];
    }];
}

@end
