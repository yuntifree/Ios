//
//  PickHeadCell.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/21.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickHeadModel.h"

@interface PickHeadCell : UICollectionViewCell

@property (nonatomic, copy) void(^HeadTap)(NSString *headurl);

- (void)setPickHeadValue:(PickHeadModel *)model;

@end
