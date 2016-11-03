//
//  WIFContentViewProtocol.h
//  360FreeWiFi
//
//  Created by 黄继华 on 15/11/10.
//  Copyright © 2015年 qihoo360. All rights reserved.
//

#ifndef WIFContentViewProtocol_h
#define WIFContentViewProtocol_h

#import "WiFiRecord.h"

@protocol WIFMenuContentViewDeleagte <NSObject>

@optional
/*! 用来通知 content view 其将显示出来了 */
- (void)contentViewWillAppear;
/*! 用来通知 content view 其已经显示出来了 */
- (void)contentViewDidAppear;
- (NSString *)getNavigationTitle;

- (void)wifiConnected;
- (void)wifiDisconnected;
- (void)wifiInfoUpdate:(WiFiRecord *)record;

@end

#endif /* WIFContentViewProtocol_h */
