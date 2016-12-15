//
//  PhotoManager.m
//  DGInfinity
//
//  Created by myeah on 16/12/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "PhotoManager.h"

@interface PhotoManager () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id <PhotoManagerDelegate> delegate;

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

- (void)showPhotoPicker:(UIViewController <PhotoManagerDelegate> *)viewController
{
    self.delegate = viewController;
    __weak typeof(self) wself = self;
    __weak typeof(viewController) wvc = viewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [wself openImagePickerController:UIImagePickerControllerSourceTypeCamera viewController:wvc];
        } else {
            [wvc makeToast:@"您的设备不支持拍照功能"];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [wself openImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary viewController:wvc];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
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
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        if (_delegate && [_delegate respondsToSelector:@selector(photoManager:didFinishPickImage:)]) {
            [_delegate photoManager:self didFinishPickImage:image];
        }
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
