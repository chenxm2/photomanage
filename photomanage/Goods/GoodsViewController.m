//
//  GoodsViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/10/22.
//

#import "GoodsViewController.h"
#import "../StoreManager/StoreManager.h"

@interface GoodsViewController ()
@property (nonatomic, strong) NSString *productId;
@end

@implementation GoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)fetchsGoods:(id)sender {
    NSMutableSet<NSString *> *param = [[NSMutableSet alloc] init];
    [param addObject:@"com.testtest.coin"];
    [[StoreManager sharedManager] fetchAvailableProducts:param success:^(NSArray<SKProduct *> * _Nonnull products) {
        LogInfo(@"fetchAvailableProducts success = %@",  products);
        for (SKProduct *product in products) {
            LogInfo(@"fetchAvailableProducts  %@, %@",  product.description, product.productIdentifier);
            
            NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
            priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
            priceFormatter.locale = [product priceLocale];
            NSString *res = [priceFormatter stringFromNumber:product.price];
            LogInfo(@"fetchAvailableProducts  %@, %@",  res , product.productIdentifier);
            self.productId = product.productIdentifier;
        }
    } failure:^(NSError * _Nonnull error) {
        LogInfo(@"fetchAvailableProducts fail = %@", error);
    }];
}
- (IBAction)buyProduct:(id)sender {
    [[StoreManager sharedManager] purchaseProduct:self.productId success:^{
        LogInfo(@"purchaseProduct success ");
        } failure:^(NSError * _Nonnull error) {
        
        }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
