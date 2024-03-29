//
//  MeViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/20.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "MeViewController.h"
#import "MeHeader.h"
#import "MeCell.h"
#import "FeedBackViewController.h"
#import "SettingViewController.h"
#import "UserInfoCGI.h"
#import "AlterNameViewController.h"
#import "PickHeadViewController.h"
#import "PhotoManager.h"
#import "AliyunOssService.h"
#import "MeMenuModel.h"
#import "WebViewController.h"
#import "DGTabBarController.h"

@interface MeViewController () <UITableViewDelegate, UITableViewDataSource, PhotoManagerDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    MeHeader *_header;
    
}

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation MeViewController

- (NSArray *)dataArray
{
    if (!_dataArray) {
        BOOL scoreShopIsRead = [[NSUSERDEFAULTS objectForKey:kScoreShopIsRead] boolValue];
        _dataArray = @[@[[MeMenuModel createWithIcon:@"my_ico_shop" title:@"我的积分" desc:@"免费领取进口零食" showPoint:!scoreShopIsRead]],
                       @[[MeMenuModel createWithIcon:@"my_ico_problem" title:@"反馈问题" desc:@"" showPoint:NO],
                         [MeMenuModel createWithIcon:@"my_ico_call" title:@"客服热线" desc:@"" showPoint:NO],
                         [MeMenuModel createWithIcon:@"my_ico_set" title:@"设置" desc:@"" showPoint:NO]]];
    }
    return _dataArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo) name:kNCRefreshUserInfo object:nil];
    }
    return self;
}

- (void)refreshUserInfo
{
    [_header refreshUserinfo];
}

- (NSString *)title
{
    return @"我";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpSubViews];
    [self getUserInfo];
}

- (void)setUpSubViews
{
    [_tableView registerNib:[UINib nibWithNibName:@"MeCell" bundle:nil] forCellReuseIdentifier:@"MeCell"];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, kScreenWidth, 160);
    _header = [[NSBundle mainBundle] loadNibNamed:@"MeHeader" owner:nil options:nil][0];
    _header.frame = view.bounds;
    [view addSubview:_header];
    _tableView.tableHeaderView = view;
    __weak typeof(self) wself = self;
    _header.headTap = ^ {
        [wself onTapHead];
    };
    _header.writeTap = ^ {
        MobClick(@"Me_profile_name");
        AlterNameViewController *vc = [AlterNameViewController new];
        [wself.navigationController pushViewController:vc animated:YES];
    };
}

- (void)headerRefresh
{
    [self getUserInfo];
}

- (void)onTapHead
{
    MobClick(@"Me_profile_photo");
    __weak typeof(self) wself = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            PickHeadViewController *vc = [PickHeadViewController new];
            [wself.navigationController pushViewController:vc animated:YES];
        } else if (buttonIndex == 2) {
            [wself openPhotoAlbum];
        }
    } otherButtonTitles:@"经典头像", @"自定义头像", nil];
    [actionSheet show];
}

- (void)openPhotoAlbum
{
    [[PhotoManager shareManager] showPhotoPicker:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)getUserInfo
{
    [UserInfoCGI getUserInfo:SApp.uid complete:^(DGCgiResult *res) {
        [_tableView.mj_header endRefreshing];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSString *headurl = data[@"headurl"];
                if ([headurl isKindOfClass:[NSString class]] && headurl.length) {
                    SApp.headurl = headurl;
                }
                NSString *nickname = data[@"nickname"];
                if ([nickname isKindOfClass:[NSString class]] && nickname.length) {
                    SApp.nickname = nickname;
                }
                [_header setHeaderValue:data];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNCRefreshUserInfo object:nil];
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)modUserHead:(NSString *)headurl
{
    [SVProgressHUD show];
    [UserInfoCGI modUserInfo:@"headurl" value:headurl complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            SApp.headurl = headurl;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNCRefreshUserInfo object:nil];
            [self makeToast:@"上传成功"];
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeCell"];
    if (indexPath.section < self.dataArray.count) {
        NSArray *subArray = self.dataArray[indexPath.section];
        if (indexPath.row < subArray.count) {
            [cell setMenuValue:subArray[indexPath.row]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        WebViewController *vc = [WebViewController new];
        vc.url = [NSString stringWithFormat:@"http://api.yunxingzh.com/app/mall.html?uid=%ld&token=%@", SApp.uid, SApp.token];
        [self.navigationController pushViewController:vc animated:YES];
        
        MeMenuModel *model = self.dataArray[0][0];
        model.showPoint = NO;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [NSUSERDEFAULTS setObject:@(YES) forKey:kScoreShopIsRead];
        [NSUSERDEFAULTS synchronize];
        DGTabBarController *tabVC = (DGTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabVC hideBadgeOnItemIndex:4];
    } else {
        switch (indexPath.row) {
            case 0:
            {
                MobClick(@"Me_feedback");
                FeedBackViewController *vc = [FeedBackViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            {
                [self showAlertWithTitle:@"拨打客服热线" message:@"0769-21660569" cancelTitle:@"取消" cancelHandler:nil defaultTitle:@"确定" defaultHandler:^(UIAlertAction *action) {
                    NSURL *tel = [NSURL URLWithString:@"tel:076921660569"];
                    if ([[UIApplication sharedApplication] canOpenURL:tel]) {
                        [[UIApplication sharedApplication] openURL:tel];
                    }
                }];
            }
                break;
            case 2:
            {
                MobClick(@"Me_setting");
                SettingViewController *vc = [SettingViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = RGB(0xf0f0f0, 1);
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = RGB(0xf0f0f0, 1);
    return view;
}

#pragma mark - PhotoManagerDelegate
- (void)photoManager:(PhotoManager *)manager didFinishPickImage:(UIImage *)image
{
    [SVProgressHUD show];
    [[AliyunOssService sharedAliyunOssService] applyImage:image complete:^(UploadPictureState state, NSString *picture) {
        [SVProgressHUD dismiss];
        if (UploadPictureState_Success == state) {
            [self modUserHead:picture];
        } else {
            [self makeToast:@"上传失败"];
        }
    }];
}

@end
