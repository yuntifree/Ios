//
//  WiFiSpeedView.h
//  360FreeWiFi
//
//  Created by lijinwei on 15/11/5.
//  Copyright © 2015年 qihoo360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WiFiSpeedRecord : NSObject

@property (nonatomic, copy) NSString *speed;
@property (nonatomic, copy) NSString *desc;

@end

@interface WiFiSpeedView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@end
