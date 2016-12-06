//
//  ShoppingViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ShoppingViewController.h"
#import "AccountCGI.h"
#import "PayCGI.h"
#import "AliyunOssService.h"

@interface ShoppingViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ShoppingViewController

- (NSString *)title
{
    return @"抢购";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)logout:(id)sender {
    if (!SApp.username.length) return;
//    [SVProgressHUD show];
//    [AccountCGI logout:^(DGCgiResult *res) {
//        [SVProgressHUD dismiss];
//        if (E_OK == res._errno) {
//            [MSApp destory];
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGOUT object:nil];
//        } else {
//            [self makeToast:res.desc];
//        }
//    }];
#if (!TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] doLogout:SApp.username andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSDictionary *head = response[@"head"];
            if ([head isKindOfClass:[NSDictionary class]]) {
                NSString *retflag = head[@"retflag"];
                if ([retflag isEqualToString:@"0"]) {
                    [self makeToast:@"下线成功"];
                } else {
                    [self makeToast:head[@"reason"]];
                }
            }
        } else {
            [self makeToast:error.description];
        }
    }];
#endif
}

- (IBAction)payTest:(UIButton *)sender {
    NSString *channel = nil;
    if (sender.tag == 1000) {
        channel = @"wx";
    } else if (sender.tag == 1001) {
        channel = @"alipay";
    } else {
        return;
    }
    
    [SVProgressHUD show];
    
    // 测试1分钱
    [PayCGI PingppPay:1 channel:channel complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            NSDictionary *charge = res.data;
            if ([charge isKindOfClass:[NSDictionary class]]) {
                [Pingpp createPayment:charge appURLScheme:PingppUrlScheme withCompletion:^(NSString *result, PingppError *error) {
                    if ([result isEqualToString:@"success"]) {
                        [self makeToast:@"支付成功"];
                    } else {
                        [self makeToast:[error getMsg]];
                    }
                }];
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (IBAction)uploadTest:(UIButton *)sender {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD show];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [[AliyunOssService sharedAliyunOssService] applyImage:image complete:^(UploadPictureState state, NSString *picture) {
            [SVProgressHUD dismiss];
            if (UploadPictureState_Success == state) {
                [self makeToast:@"上传成功"];
                DDDLog(@"图片地址为：%@",picture);
            } else {
                [self makeToast:@"上传失败"];
            }
        }];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
