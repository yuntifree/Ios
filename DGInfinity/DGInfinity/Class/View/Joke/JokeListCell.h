//
//  JokeListCell.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/23.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JokeModel.h"

@interface JokeListCell : UITableViewCell

@property (nonatomic, copy) void(^evaluatedBlock)(void);
@property (nonatomic, copy) void(^likeOrUnlikeBlock)(JokeModel *model);

- (void)setJokeValue:(JokeModel *)model;

@end
