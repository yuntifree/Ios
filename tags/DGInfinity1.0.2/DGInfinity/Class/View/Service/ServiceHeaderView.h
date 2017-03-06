//
//  ServiceHeaderView.h
//  DGInfinity
//
//  Created by myeah on 16/10/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HeaderBtnClick)(NSInteger tag);

@interface ServiceHeaderView : UIView

@property (nonatomic, copy) HeaderBtnClick headClick;

@end
