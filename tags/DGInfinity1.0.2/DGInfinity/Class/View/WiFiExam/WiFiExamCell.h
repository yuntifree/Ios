//
//  WiFiExamCell.h
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WiFiExamModel.h"

@interface WiFiExamCell : UITableViewCell

@end

@interface WiFiExamDeviceCell : WiFiExamCell

- (void)setDeviceValue:(WiFiExamDeviceModel *)model;

@end

@interface WiFiExamDescCell : WiFiExamCell

- (void)setDescValue:(WiFiExamDescModel *)model;

@end
