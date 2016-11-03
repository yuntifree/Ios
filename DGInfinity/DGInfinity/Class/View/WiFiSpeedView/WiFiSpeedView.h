//
//  WiFiSpeedView.h
//  360FreeWiFi
//
//  Created by lijinwei on 15/11/5.
//  Copyright © 2015年 qihoo360. All rights reserved.
//

#import "WIFContentViewProtocol.h"
#import "WiFiRecord.h"
#import <UIKit/UIKit.h>

#define IS_IPHONE_FOUR (kScreenWidth == 320 && kScreenHeight == 480)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE_FIVE ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_IPHONE_SIX_PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

@protocol WIFISpeedViewDelegate <NSObject>

- (void)touchCloseBtn;
- (void)updateSpeedBarIcon:(NSString*)speed;
- (void)updateSpeedNavTitle:(NSString*)navTitle;

@end

@interface WiFiSpeedView : UIView<WIFMenuContentViewDeleagte>

@property (nonatomic, weak) NSObject<WIFISpeedViewDelegate> *delegate;

- (instancetype)initWithFrame:(CGRect)frame;

//更新wifi的info信息
-(void)updateWiFiInfo:(WiFiRecord*) record;

- (void)contentViewDidAppear;

#pragma mark -- WIFMenuContentViewDeleagte
- (void)wifiConnected;
- (void)wifiDisconnected;
- (void)wifiInfoUpdate:(WiFiRecord*) record;

@end
