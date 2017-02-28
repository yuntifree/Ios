//
//  ServiceCityCell.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/27.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceCellModel.h"

@interface ServiceCityCell : UICollectionViewCell

@property (nonatomic, copy) void(^btnClick)(ServiceCityModel *model);

- (void)setCityValue:(ServiceCityModel *)model;

@end
