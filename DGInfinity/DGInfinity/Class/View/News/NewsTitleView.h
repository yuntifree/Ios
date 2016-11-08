//
//  NewsTitleView.h
//  DGInfinity
//
//  Created by myeah on 16/11/8.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Block)(NSInteger index);

@interface NewsTitleView : UIView

@property (nonatomic, copy) Block block;

- (void)changeBtn:(NSInteger)tag;

@end
