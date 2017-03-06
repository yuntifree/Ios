//
//  PhotoManager.m
//  DGInfinity
//
//  Created by myeah on 16/12/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "PhotoManager.h"
#import "PhotoViewController.h"

@interface PhotoManager () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoViewControllerDelegate>

@property (nonatomic, weak) id <PhotoManagerDelegate> delegate;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;

@end

@implementation PhotoManager

+ (instancetype)shareManager
{
    static PhotoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (void)showPhotoPicker:(UIViewController <PhotoManagerDelegate> *)viewController sourceType:(UIImagePickerControllerSourceType)sourceType
{
    self.delegate = viewController;
    self.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self openImagePickerController:UIImagePickerControllerSourceTypeCamera viewController:viewController];
        } else {
            [viewController makeToast:@"您的设备不支持拍照功能"];
        }
    } else {
        [self openImagePickerController:sourceType viewController:viewController];
    }
}

//  打开相册或者相机
- (void)openImagePickerController:(UIImagePickerControllerSourceType)sourceType viewController:(UIViewController *)viewController
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    [viewController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    PhotoViewController *photoVC = [[PhotoViewController alloc] init];
    photoVC.oldImage = image;
    photoVC.mode = PhotoMaskViewModeSquare;
    photoVC.cropWidth = kScreenWidth / 3 * 2;
    photoVC.cropHeight = kScreenWidth / 3 * 2;
    photoVC.delegate = self;
    photoVC.isDark = YES;
    photoVC.lineColor = [UIColor whiteColor];
    photoVC.cropTitle = @"照片裁剪";
    photoVC.btnBackgroundColor = [UIColor clearColor];
    NSArray *subViews = photoVC.view.subviews;
    if (subViews.count > 2) {
        UIView *bottomView = subViews[2];
        bottomView.backgroundColor = RGB(0x000000, 0.7);
        bottomView.bounds = CGRectMake(0, 0, kScreenWidth, 64);
        for (UIView *view in bottomView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                btn.frame = CGRectMake(kScreenWidth - 90, 0, 80, 64);
                [btn setTitle:@"使用照片" forState:UIControlStateNormal];
            } else {
                [view removeFromSuperview];
            }
        }
    }
    [picker pushViewController:photoVC animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PhotoViewControllerDelegate
- (void)imageCropper:(PhotoViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(photoManager:didFinishPickImage:)]) {
            [_delegate photoManager:self didFinishPickImage:editedImage];
        }
    }];
}

- (void)imageCropperDidCancel:(PhotoViewController *)cropperViewController
{
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [cropperViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [cropperViewController.navigationController popViewControllerAnimated:YES];
    }
}

@end
