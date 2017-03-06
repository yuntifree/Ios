//
//  ServiceBannerCell.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/27.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceSectionModel.h"
#import "ServiceCellModel.h"

@interface ServiceBannerCell : UICollectionViewCell

@property (nonatomic, copy) void(^tapBlock)(ServiceBannerModel *model);

- (void)setBannerValue:(ServiceSectionModel *)model;

@end
