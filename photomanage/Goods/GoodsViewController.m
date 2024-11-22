//
//  GoodsViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/10/22.
//

#import "GoodsViewController.h"
#import "../StoreManager/StoreManager.h"

@interface GoodsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *slimmingCoinText;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *leftCoinsLabel;
@property (weak, nonatomic) IBOutlet UIView *leftBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *payBackgroundView;

@property (nonatomic, strong) NSString *productId;
@end

@implementation GoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *slimmingText = [NSString localizedStringWithName:@"slimming_coin"];
    self.slimmingCoinText.text = [NSString stringWithFormat:@"%d%@", kProductIdContainCoin, slimmingText];
    [self fetchsGoods];
    self.buyButton.hidden = YES;
    self.title = [NSString localizedStringWithName:@"slimming_coin"];
    
    WEAK_SELF
    [STORE_MANAGER getTotalVirtualCurrencyWithCompletion:^(NSUInteger value) {
        STRONG_SELF
        strongSelf.leftCoinsLabel.text = [NSString virtualCurrencyStringWithValue:value];
    }];
    self.view.backgroundColor = [UIColor whiteColor];
    self.leftBackgroundView.layer.cornerRadius = 8;
    self.leftBackgroundView.clipsToBounds = YES;
    self.payBackgroundView.layer.cornerRadius = 8;
    self.payBackgroundView.clipsToBounds = YES;
}

- (void)fetchsGoods {
    NSMutableSet<NSString *> *param = [[NSMutableSet alloc] init];
    [param addObject:kProductId];
    WEAK_SELF
    [[StoreManager sharedManager] fetchAvailableProducts:param success:^(NSArray<SKProduct *> * _Nonnull products) {
        LogInfo(@"fetchAvailableProducts success = %@",  products);
        STRONG_SELF
        for (SKProduct *product in products) {
            LogInfo(@"fetchAvailableProducts  %@, %@",  product.description, product.productIdentifier);
            
            NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
            priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
            priceFormatter.locale = [product priceLocale];
            NSString *res = [priceFormatter stringFromNumber:product.price];
            LogInfo(@"fetchAvailableProducts  %@, %@",  res , product.productIdentifier);
            
            strongSelf.productId = product.productIdentifier;
            NSString *buy = [NSString localizedStringWithName:@"buy"];
            NSString *fullBuyText = [NSString stringWithFormat:@"%@ %@", res, buy];
            [strongSelf.buyButton setTitle:fullBuyText forState:UIControlStateNormal];
            strongSelf.buyButton.hidden = NO;
        }
    } failure:^(NSError * _Nonnull error) {
        LogInfo(@"fetchAvailableProducts fail = %@", error);
    }];
}
- (IBAction)buyProduct:(id)sender {
    [[StoreManager sharedManager] purchaseProduct:self.productId success:^{
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
