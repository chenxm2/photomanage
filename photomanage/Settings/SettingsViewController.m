//
//  SettingsViewController.m
//  photomanage
//
//  Created by chenxianming on 2024/11/20.
//

#import "SettingsViewController.h"
#import "SettingViewCell.h"
#import "SettingInfo.h"
#import "SimpleWebviewController.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<SettingInfo *> *aboutData;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [NSString localizedStringWithName:@"setting"];
    
    // 设置表格样式和代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor]; // 背景色
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (@available(iOS 13.0, *)) {
        self.tableView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingViewCell" bundle:nil]
         forCellReuseIdentifier:[SettingViewCell reuseIdentifier]];
    
    // URL:https://www.termsfeed.com/live/107d8080-a345-4f3d-baa8-e419494fc55c
}

- (NSArray<SettingInfo *> *)aboutData {
    if (_aboutData == nil) {
        // 定义一个字典，存储 SettingId 和对应的标题
        NSDictionary<NSNumber *, NSString *> *settingTitles = @{
            @(SettingIdVertion): [NSString localizedStringWithName:@"version"],            // SettingIdVertion
//            @(SettingIdUsage): [NSString localizedStringWithName:@"usage"],                // SettingIdUsage
            @(SettingIdPrivacy): [NSString localizedStringWithName:@"privacy"],            // SettingIdPrivacy
        };

        _aboutData = [[NSMutableArray alloc] init];
        for (int i = SettingIdAboutBegin + 1; i < SettingIdAboutEnd; i++) {
            SettingInfo *info = [[SettingInfo alloc] init];
            NSString *title = [settingTitles objectForKey:@(i)];
            info.settingTitle = title;
            info.settingId = i;
            [_aboutData addObject:info];
        }
    }
    
    return  _aboutData;
}

// 分组数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // 两个分组
}

// 每个分组的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.aboutData count];
}

// 配置单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SettingViewCell reuseIdentifier] forIndexPath:indexPath];

    SettingInfo *info = [self.aboutData objectAtIndex:indexPath.row];
    [cell setData:info];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 处理点击事件
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingInfo *info = [self.aboutData objectAtIndex:indexPath.row];
    switch (info.settingId) {
        case SettingIdPrivacy:
        {
            SimpleWebviewController *controller = [[SimpleWebviewController alloc] initWithTitle:info.settingTitle   url:@"https://www.termsfeed.com/live/27a8ba14-7e74-4260-b477-55c3a77c1416"];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - UITableViewDelegate

// 提供分组标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString localizedStringWithName:@"about"];
    }
    
    return @"";
}

@end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

