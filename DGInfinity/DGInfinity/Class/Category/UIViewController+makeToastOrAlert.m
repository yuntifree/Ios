//
//  UIViewController+makeToastOrAlert.m
//  DGInfinity
//
//  Created by myeah on 16/11/25.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UIViewController+makeToastOrAlert.h"

@implementation UIViewController (makeToastOrAlert)

- (void)makeToast:(NSString *)message
{
//    [self.view makeToast:message];
    [[UIApplication sharedApplication].windows.lastObject makeToast:message];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
             cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler
              defaultTitle:(NSString *)defaultTitle
            defaultHandler:(void (^ __nullable)(UIAlertAction *action))defaultHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (cancelTitle.length) {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelHandler]];
    }
    if (defaultTitle.length) {
        [alert addAction:[UIAlertAction actionWithTitle:defaultTitle style:UIAlertActionStyleDefault handler:defaultHandler]];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

@end
