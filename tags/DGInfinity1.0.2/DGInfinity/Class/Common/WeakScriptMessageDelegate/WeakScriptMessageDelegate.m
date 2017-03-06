//
//  WeakScriptMessageDelegate.m
//  Live
//
//  Created by Flame on 16/6/2.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import "WeakScriptMessageDelegate.h"

@implementation WeakScriptMessageDelegate

- (void)dealloc
{
    DDDLog(@"WeakScriptMessageDelegate Dealloc");
}

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (_scriptDelegate && [_scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [_scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
