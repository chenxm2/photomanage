//
//  StoreManager.m
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import "StoreManager.h"
#import "KeychainHelper.h"
#import <RMStore/RMStore.h>


NSString * const kProductIdOnce = @"com.xiaoma.slimcoin";
NSString * const kProductIdForever = @"com.xiaoma.slimcoin.forever";
NSUInteger const kProductIdContainCoin = 3000;
NSUInteger const kFirstFreeVirtualCurrency = 1000;

NSString * const kIAPReceiptData = @"kIAPReceiptData";
NSString * const kProductKey = @"kProductKey";
NSString * const kReceiptDataKey = @"kReceiptDataKey";
NSString * const kUniqueDeviceIdentifier = @"uniqueDeviceIdentifier";

//NSString * const kVerifyReceiptURL = @"https://buy.itunes.apple.com/verifyReceipt";
NSString * const kVerifyReceiptURL = @"https://sandbox.itunes.apple.com/verifyReceipt";



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

- (BOOL)isLastPurchaseInterrupt {
    return [self retrieveReceiptData] != nil;
}

- (BOOL)isFreeForever {
    return YES;
}

- (void)resumeInterruptProductSuccess:(void (^)(void))successBlock
                              failure:(void (^)(NSError *error))failureBlock {
    NSDictionary *dic = [self retrieveReceiptData];
    if (dic != nil) {
        NSString *receiptDataString = [dic objectForKey:kReceiptDataKey];
        NSString *productId = [dic objectForKey:kProductKey];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:receiptDataString options:0];
        [self verifyTransactionWithData:decodedData productId:productId success:^(NSString *productId) {
            if (successBlock) {
                successBlock();
            }
        } failure:^(NSError *error) {
                    if (failureBlock) {
                        failureBlock(error);
                    }
        }];
    }
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


- (void)verifyTransactionWithData:(NSData *)receiptData productId:(NSString *)productId
                  success:(void (^)(NSString *productId))successBlock
                  failure:(void (^)(NSError *error))failureBlock {
    if (!receiptData) {
        // 收据不存在的处理
        if (failureBlock) {
            NSError *error = [NSError errorWithDomain:@"StoreManagerErrorDomain"
                                                 code:1001
                                             userInfo:@{NSLocalizedDescriptionKey : @"Receipt data not found"}];
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
        return;
    }

    // 将收据数据转换为 Base64 字符串
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:0];

    // 创建请求体
    NSDictionary *requestBody = @{
        @"receipt-data": receiptString,
    };
    
    NSError *jsonError;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&jsonError];

    if (jsonError) {
        NSLog(@"[StoreManager] Failed to serialize request body: %@", jsonError.localizedDescription);
        if (failureBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(jsonError);
            });
        }
        return;
    }

    // 沙盒环境的验证 URL
    NSURL *url = [NSURL URLWithString:kVerifyReceiptURL];
    NSLog(@"[StoreManager] Using URL: %@", url);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = requestData;

    NSLog(@"[StoreManager] Sending request with body: %@", [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding]);
    
    // 使用 NSURLSession 发送验证请求
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self saveReceiptData:receiptData productId:productId];
            NSLog(@"[StoreManager] Request failed with error: %@", error.localizedDescription);
            if (failureBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock(error);
                });
            }
            return;
        }
        
        [self removeReceiptData];
        // 打印响应数据
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"[StoreManager] Response: %@", responseString);

        NSError *jsonResponseError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonResponseError];

        if (jsonResponseError) {
            NSLog(@"[StoreManager] Failed to parse response JSON: %@", jsonResponseError.localizedDescription);
            if (failureBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock(jsonResponseError);
                });
            }
            return;
        }

        // 解析状态码
        NSNumber *status = jsonResponse[@"status"];
        NSLog(@"[StoreManager] Validation status: %@", status);

        if (status.integerValue == 0) {
            NSLog(@"[StoreManager] Receipt validation succeeded.");
            // 验证成功
            if (successBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(productId);
                });
            }
        } else {
            // 根据状态码处理失败情况
            NSString *errorMessage = [NSString stringWithFormat:@"Receipt validation failed with status: %@", status];
            NSLog(@"[StoreManager] %@", errorMessage);

            NSError *validationError = [NSError errorWithDomain:@"StoreManagerErrorDomain"
                                                            code:status.integerValue
                                                        userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            if (failureBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock(validationError);
                });
            }
        }
    }];

    [task resume];
}

- (void)verifyTransaction:(SKPaymentTransaction *)transaction
                  success:(void (^)(void))successBlock
                  failure:(void (^)(NSError *error))failureBlock {
    
    // 获取收据文件路径
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    [self verifyTransactionWithData:receiptData productId:transaction.payment.productIdentifier success:^(NSString *productId) {
        if (successBlock) {
            successBlock();
        }
        
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

// 保存 receiptData 到本地存储
- (void)saveReceiptData:(NSData *)receiptData productId:(NSString *)productId {
    if (receiptData) {
        // 将 receiptData 转换为 base64 字符串
        NSString *base64Receipt = [receiptData base64EncodedStringWithOptions:0];
        NSDictionary *receiptInfo = @{
                kReceiptDataKey: base64Receipt,
                kProductKey: productId,
                
        };
        
        [UserDefaultsManager setObject:receiptInfo forKey:kIAPReceiptData];
        [self notifyLastPurchaseInterruptChange];
    }
}

// 从本地存储读取 receiptData
- (NSDictionary *)retrieveReceiptData {
    return [UserDefaultsManager objectForKey:kIAPReceiptData];
}

- (void)removeReceiptData {
    [UserDefaultsManager removeObjectForKey:kIAPReceiptData];
    [self notifyLastPurchaseInterruptChange];
}

- (void)notifyLastPurchaseInterruptChange {
    [GCDUtility executeOnMainThread:^{
        BOOL isLastPurchaseInterrupt = [self isLastPurchaseInterrupt];
        for (id<StoreManagerObserver> observer in self.observers) {
            if ([observer respondsToSelector:@selector(onLastPurchaseInterrupt:)]) {
                [observer onLastPurchaseInterrupt:isLastPurchaseInterrupt];
            }
        }
    }];
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
    if ([productIdentifier isEqualToString:kProductIdOnce]) {
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
