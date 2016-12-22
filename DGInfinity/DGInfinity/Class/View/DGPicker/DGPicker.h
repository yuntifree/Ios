//
//  DGPicker.h
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/22.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PickerSourceType) {
    PickerSourceTypeSex = 0,
};

@interface DGPicker : UIView

@property (nonatomic, assign) PickerSourceType sourceType;

- (void)showInView:(UIView *)view;

@end
