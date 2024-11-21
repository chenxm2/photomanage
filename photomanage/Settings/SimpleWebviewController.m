//
//  SimpleWebviewController.m
//  photomanage
//
//  Created by chenxianming on 2024/11/20.
//

#import "SimpleWebviewController.h"
#import <WebKit/WebKit.h>

@interface SimpleWebviewController ()  <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) NSString *pageURL;
@end

@implementation SimpleWebviewController

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url {
    self = [super init];
    if (self) {
        self.pageTitle = title;
        self.pageURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.navigationDelegate = self; // 设置代理
    [self.view addSubview:self.webView];
    // Do any additional setup after loading the view.
    
    // 加载URL
    if (self.pageURL) {
        NSURL *url = [NSURL URLWithString:self.pageURL];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
        
    // 设置导航栏标题
    if (self.pageTitle) {
        self.title = self.pageTitle;
    }
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
