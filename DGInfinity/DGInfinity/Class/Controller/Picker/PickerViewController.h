//
//  PickerViewController.h
//  DGInfinity
//
//  Created by myeah on 16/12/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

typedef NS_ENUM(NSInteger, PickerSourceType) {
    PickerSourceTypeSex = 0,
};

@interface PickerViewController : DGViewController

@property (nonatomic, assign) PickerSourceType sourceType;

@end
