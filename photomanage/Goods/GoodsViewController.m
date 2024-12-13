//
//  GoodsViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/10/22.
//

#import "GoodsViewController.h"
#import "../StoreManager/StoreManager.h"

@interface GoodsViewController () <CustomButtonViewDelegate, StoreManagerObserver>
@property (weak, nonatomic) IBOutlet UILabel *slimmingCoinText;
@property (weak, nonatomic) IBOutlet UILabel *leftCoinsLabel;
@property (weak, nonatomic) IBOutlet UIView *leftBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *payBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *memberFlagView;

@property (weak, nonatomic) IBOutlet CustomButtonView *buyCoinButtonView;
@property (weak, nonatomic) IBOutlet CustomButtonView *buyMemberButtonView;
@property (assign, nonatomic) BOOL isMemberForever;
@end

@implementation GoodsViewController

+ (void)goToGoodsViewController:(UINavigationController *)navigationController {
    GoodsViewController *controller = [[GoodsViewController alloc] init];
    [navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *slimmingText = [NSString localizedStringWithName:@"slimming_coin"];
    self.slimmingCoinText.text = [NSString stringWithFormat:@"%lu%@", (unsigned long)kProductIdContainCoin, slimmingText];
    self.buyCoinButtonView.hidden = YES;
    self.buyMemberButtonView.hidden = YES;
    self.memberFlagView.hidden = YES;

    self.title = nil;
    self.isMemberForever = NO;
    WEAK_SELF
    [STORE_MANAGER getTotalVirtualCurrencyWithCompletion:^(NSUInteger value) {
        STRONG_SELF
        strongSelf.leftCoinsLabel.text = [NSString virtualCurrencyStringWithValue:value];
    }];
    self.title = [NSString localizedStringWithName:@"slimming_coin"];
    if ([STORE_MANAGER isMemberForever]) {
        self.memberFlagView.hidden = NO;
    } else {
        [self fetchsGoods];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.leftBackgroundView.layer.cornerRadius = 8;
    self.leftBackgroundView.clipsToBounds = YES;
    self.payBackgroundView.layer.cornerRadius = 8;
    self.payBackgroundView.clipsToBounds = YES;
    self.buyCoinButtonView.delegate = self;
    self.buyMemberButtonView.delegate = self;
    [STORE_MANAGER addObserver:self];
    [UserDefaultsManager setBool:YES forKey:kHadShowGuidance];
    
}


- (void)fetchsGoods {
    NSMutableSet<NSString *> *param = [[NSMutableSet alloc] init];
    [param addObject:kProductIdOnce];
    [param addObject:kProductIdForever];
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
        
            if ([kProductIdOnce isEqualToString:product.productIdentifier]) {
                NSString *buy = [NSString localizedStringWithFormat:@"buy_coins", kProductIdContainCoin];
                self.buyCoinButtonView.buttonText = [NSString stringWithFormat:@"%@ (%@)", buy, res];
                self.buyCoinButtonView.hidden = NO;
                self.buyCoinButtonView.customData = kProductIdOnce;
            } else if ([kProductIdForever isEqualToString:product.productIdentifier]) {
                NSString *buy = [NSString localizedStringWithName:@"buy_member_forever"];
                self.buyMemberButtonView.buttonText = [NSString stringWithFormat:@"%@ (%@)", buy, res];
                self.buyMemberButtonView.hidden = NO;
                self.buyMemberButtonView.customData = kProductIdForever;
            }
        }
    } failure:^(NSError * _Nonnull error) {
        LogInfo(@"fetchAvailableProducts fail = %@", error);
    }];
}

- (void)updateButtonText:(BOOL)freeForever isInterrupt:(BOOL)isInterrupt buyString:(NSString *)buyString {
    
}

- (void)dealloc {
    [STORE_MANAGER removeObserver:self];
}

-(void)onButtonTap:(CustomButtonView *)view {
    
    __block MBProgressHUD *hud = nil;
    
    hud = [ProgressHUDWrapper showLoadingToView:nil withString:@""];
    hud.userInteractionEnabled = YES;
    WEAK_SELF
    [[StoreManager sharedManager] purchaseProduct:view.customData success:^{
        [ProgressHUDWrapper hideHUDForView:nil];
            STRONG_SELF
            [strongSelf.view showToastWithMessage:[NSString localizedStringWithName:@"buy_success"]];
        } failure:^(NSError * _Nonnull error) {
            STRONG_SELF
            [strongSelf.view showToastWithMessage:[NSString localizedStringWithName:@"buy_fail"]];
        [ProgressHUDWrapper hideHUDForView:nil];
    }];
}

- (void)onVirtualCurrencyUpdate:(NSUInteger)virtualCurrency {
   self.leftCoinsLabel.text =  [NSString virtualCurrencyStringWithValue:virtualCurrency];
}

- (void)onBecomeMember {
    self.buyCoinButtonView.hidden = YES;
    self.buyMemberButtonView.hidden = YES;
    self.memberFlagView.hidden = NO;
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
