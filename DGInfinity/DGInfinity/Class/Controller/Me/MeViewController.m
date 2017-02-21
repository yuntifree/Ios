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

@interface MeViewController () <UITableViewDelegate, UITableViewDataSource, PhotoManagerDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    MeHeader *_header;
    
}
@end

@implementation MeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modNickname:) name:kNCModNickname object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modHead:) name:kNCModHead object:nil];
    }
    return self;
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
        AlterNameViewController *vc = [AlterNameViewController new];
        [wself.navigationController pushViewController:vc animated:YES];
    };
}

- (void)onTapHead
{
    __weak typeof(self) wself = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            PickHeadViewController *vc = [PickHeadViewController new];
            [wself.navigationController pushViewController:vc animated:YES];
        } else if (buttonIndex == 2) {
            [wself openPhotoAlbum];
        }
    } otherButtonTitles:@"我为你推荐", @"从相册选择", nil];
    [actionSheet show];
}

- (void)openPhotoAlbum
{
    [[PhotoManager shareManager] showPhotoPicker:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)modNickname:(NSNotification *)notification
{
    [_header setNickname:notification.object];
}

- (void)modHead:(NSNotification *)notification
{
    [_header setHead:notification.object];
}

- (void)getUserInfo
{
    [UserInfoCGI getUserInfo:SApp.uid complete:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                [_header setHeaderValue:data];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kNCModHead object:headurl];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeCell"];
    switch (indexPath.row) {
        case 0:
        {
            [cell setIcon:@"my_ico_problem" title:@"反馈问题"];
        }
            break;
        case 1:
        {
            [cell setIcon:@"my_ico_set" title:@"设置"];
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            FeedBackViewController *vc = [FeedBackViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            SettingViewController *vc = [SettingViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
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
