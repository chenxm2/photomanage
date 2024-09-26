//
//  ContentViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/5/20.
//

#import "ContentViewController.h"
#import "Masonry.h"
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface ContentViewController ()
@property (nonatomic) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteButton;
@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 添加Pan手势识别器
    UISwipeGestureRecognizer *swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipe.direction =UISwipeGestureRecognizerDirectionUp;
    self.view.userInteractionEnabled = YES;
    
    [self.view addGestureRecognizer:swipe];
    
    [self configDeleteButton];
}

- (void)configDeleteButton
{
    self.deleteButton = [[UIButton alloc] init];
    [self.deleteButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteButton];
    

    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY); //
        make.right.equalTo(self.view.mas_right).offset(-10); // 左边与父视图左边对齐
        make.width.equalTo(@44); // 设置固定宽度
        make.height.equalTo(@44); // 设置固定高度
    }];
}

- (void)deleteClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(onDelete:)]) {
        [self.delegate onDelete:self.content];
    }
}

#pragma mark 轻扫的对应方法

-(void)swipeAction:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction ==UISwipeGestureRecognizerDirectionUp) {
        if ([self.delegate respondsToSelector:@selector(onDelete:)]) {
            [self.delegate onDelete:self.content];
        }
    }
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 设置子视图的宽度与父视图的宽度相等
        make.width.equalTo(self.view.mas_width);
        
        // 根据宽度设置高度，保持3:4的比例
        // 这里我们使用一个辅助的计算属性来设置高度
        make.height.mas_equalTo(self.imageView.mas_width).multipliedBy(4.0f / 3.0f);
        
        // 设置子视图的中心X与父视图的中心X对齐，实现水平居中
        make.centerX.equalTo(self.view.mas_centerX);
        
        // 设置子视图的中心Y与父视图的中心Y对齐，实现垂直居中
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    if (self.imageView.image == nil) {
        [self.imageView setImageWithAsset:_content];
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
