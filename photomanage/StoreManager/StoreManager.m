//
//  StoreManager.m
//  photomanage
//
//  Created by chenxianming on 2024/10/17.
//

#import "StoreManager.h"
#import "KeychainHelper.h"
#import <RMStore/RMStore.h>

@interface StoreManager () <RMStoreObserver, RMStoreReceiptVerificator>
@property (nonatomic, strong) RMStore *store;
@end

@implementation StoreManager

+ (instancetype)sharedManager {
    static StoreManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.store = [RMStore defaultStore]; // Initialize RMStore
        sharedInstance.store.receiptVerificator = sharedInstance;
        [sharedInstance.store addStoreObserver:sharedInstance]; // Add self as an observer
    });
    return sharedInstance;
}

// Fetch available products
- (void)fetchAvailableProducts:(NSSet<NSString *> *)productIdentifiers
                       success:(void (^)(NSArray<SKProduct *> *))successBlock
                       failure:(void (^)(NSError *))failureBlock {
    
    [self.store requestProducts:productIdentifiers success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            successBlock(products);
        } failure:^(NSError *error) {
            failureBlock(error);
        }];
}

// Purchase a product
- (void)purchaseProduct:(NSString *)productIdentifier
                success:(void (^)())successBlock
                failure:(void (^)(NSError *error))failureBlock {
    [self.store addPayment:productIdentifier success:^(SKPaymentTransaction *transaction) {
            successBlock();
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            failureBlock(error);
    }];
}

// Verify transaction using Apple’s validation service
- (void)verifyTransaction:(SKPaymentTransaction *)transaction
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock {
    
    if (successBlock) {
        successBlock();
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
- (NSString *)getOrCreateUUID {
    NSString *key = @"uniqueDeviceIdentifier";
    NSString *uuid = [KeychainHelper loadStringForKey:key];
    
    if (!uuid) {
        uuid = [[NSUUID UUID] UUIDString];
        [KeychainHelper saveString:uuid forKey:key];
    }
    
    return uuid;
}

// Get total virtual currency from Keychain
- (NSInteger)getTotalVirtualCurrency {
    NSString *key = [self getOrCreateUUID]; // Use UUID as the key
    NSNumber *currency = [KeychainHelper loadNumberForKey:key];
    return currency ? [currency integerValue] : 0;
}

// Add virtual currency to total
- (void)addVirtualCurrency:(NSInteger)amount {
    NSInteger total = [self getTotalVirtualCurrency];
    total += amount; // Update total
    NSString *key = [self getOrCreateUUID]; // Use UUID as the key
    [KeychainHelper saveNumber:@(total) forKey:key]; // Save updated total in Keychain
}

// Get virtual currency amount for specific product
- (NSInteger)virtualCurrencyForProduct:(NSString *)productIdentifier {
    // Add logic to determine the virtual currency amount for the given product
    // Example:
    if ([productIdentifier isEqualToString:@"com.yourapp.virtualcurrency1"]) {
        return 100; // 100 units for product 1
    } else if ([productIdentifier isEqualToString:@"com.yourapp.virtualcurrency2"]) {
        return 500; // 500 units for product 2
    }
    return 0; // Default to 0 if not found
}

@end
