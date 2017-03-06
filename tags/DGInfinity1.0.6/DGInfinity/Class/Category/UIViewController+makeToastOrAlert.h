//
//  UIViewController+makeToastOrAlert.h
//  DGInfinity
//
//  Created by myeah on 16/11/25.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (makeToastOrAlert)

- (void)makeToast:(NSString *)message;

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
             cancelHandler:(void (^)(UIAlertAction *action))cancelHandler
              defaultTitle:(NSString *)defaultTitle
            defaultHandler:(void (^)(UIAlertAction *action))defaultHandler;

@end
