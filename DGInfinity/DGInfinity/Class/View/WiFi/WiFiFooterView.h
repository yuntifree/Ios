//
//  WiFiFooterView.h
//  DGInfinity
//
//  Created by myeah on 16/11/11.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WiFiFooterType) {
    WiFiFooterTypeLookForNews = 1000,
    WiFiFooterTypeBanner = 1001,
    WiFiFooterTypeNews = 1002,
    WiFiFooterTypeVideo = 1003,
    WiFiFooterTypeService = 1004,
    WiFiFooterTypeGoverment = 1005,
    WiFiFooterTypeLive = 1006,
    WiFiFooterTypeShopping = 1007
};

typedef void(^FooterBlock)(NSInteger type);

@interface WiFiFooterView : UIView

@property (nonatomic, copy) FooterBlock block;

- (void)setFrontInfo:(NSDictionary *)frontInfo;

@end
