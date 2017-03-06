//
//  DetailLocationViewController.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/3/6.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "DGViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface DetailLocationViewController : DGViewController

@property (nonatomic, strong) BMKPointAnnotation *annotation;

@end
