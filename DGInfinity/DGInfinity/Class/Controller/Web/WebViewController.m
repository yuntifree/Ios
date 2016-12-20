//
//  WebViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "NetworkManager.h"
#import "WeakScriptMessageDelegate.h"

NSString *const JSHOST = @"JSHost";
NSString *const JavaScriptBackgroundColor = @"document.body.style.backgroundColor = '#000';";
NSString *const JavaScriptClosePage = @"javascript:(function() { \
                                            var videos = document.getElementsByTagName('video'); \
                                            for (var i = 0; i < videos.length; i++) { \
                                                videos[i].play(); \
                                                videos[i].addEventListener('ended', function () { \
                                                    var message = {'cmd': 'closePage'}; \
                                                    window.webkit.messageHandlers.JSHost.postMessage(message); \
                                                }, false); \
                                            } \
                                        })()";
NSString *const JavaScriptScaleToFit = @"var meta = document.createElement('meta'); \
                                         meta.setAttribute('name', 'viewport'); \
                                         meta.setAttribute('content', 'width=device-width'); \
                                         document.getElementsByTagName('head')[0].appendChild(meta);";

@interface WebViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
{
    WebItemType _type;
}

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIScrollView *backgroundView;

@property (nonatomic, strong) NSURLRequest *currentRequest;

@end

@implementation WebViewController

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:JSHOST];
    self.webView = nil;
    self.progressView = nil;
    self.backgroundView = nil;
}

- (WKWebView *)webView
{
    if (_webView == nil) {
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:JavaScriptScaleToFit injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        config.preferences = [WKPreferences new];
        config.userContentController = [WKUserContentController new];
        [config.userContentController addUserScript:wkUScript];
        [config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:JSHOST];
        if (!IOS9) {
            config.mediaPlaybackRequiresUserAction = NO;
        } else {
            config.requiresUserActionForMediaPlayback = NO;
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress = 0;
        _progressView.hidden = YES;
        _progressView.trackTintColor = [UIColor whiteColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (UIScrollView *)backgroundView
{
    if (_backgroundView == nil) {
        _backgroundView = [[UIScrollView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _backgroundView.hidden = YES;
        __weak typeof(self) wself = self;
        [_backgroundView configureNoNetStyleWithdidTapButtonBlock:^{
            [wself.webView loadRequest:wself.currentRequest];
        } didTapViewBlock:^{
            
        }];
        [self.view addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _changeTitle = YES;
        _type = ITEMTYPE_BACK;
        self.title = @"东莞无限";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@2);
    }];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    if (_newsType == NT_VIDEO) {
        self.view.backgroundColor = [UIColor blackColor];
        
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (_url.length) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [self.webView loadRequest:request];
    } else {
        [self makeToast:@"链接无效，加载失败"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return _newsType == NT_VIDEO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.shouldAutorotate ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Btn Action
- (void)backBtnClick:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        if (_newsType == NT_VIDEO) {
            if ([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait) {
                NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self closeBtnClick:nil];
                });
            } else {
                [self closeBtnClick:nil];
            }
        } else {
            [self closeBtnClick:nil];
        }
    }
}

- (void)closeBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:_pop ? NO : YES];
    if (_pop) {
        _pop();
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.webView) {
        if ([keyPath isEqualToString:@"title"]) {
            if (self.webView.title.length && _changeTitle) {
                self.title = self.webView.title;
            }
        } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
            double progress = self.webView.estimatedProgress;
            if (progress == 1) {
                [self.progressView setProgress:0 animated:NO];
                self.progressView.hidden = YES;
            } else {
                [self.progressView setProgress:progress animated:YES];
                self.progressView.hidden = NO;
            }
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    self.currentRequest = navigationAction.request;
    if(navigationAction.targetFrame == nil)
    {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (_newsType == NT_VIDEO) {
        [webView evaluateJavaScript:JavaScriptBackgroundColor completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            if (error) {
                DDDLog(@"javaScript error: %@",error);
            }
        }];
        [webView evaluateJavaScript:JavaScriptClosePage completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            if (error) {
                DDDLog(@"javaScript error: %@",error);
            }
        }];
    }

    if (!self.backgroundView.hidden) {
        self.backgroundView.hidden = YES;
    }
    if ([webView canGoBack]) {
        if (_type != ITEMTYPE_CLOSE) {
            _type = ITEMTYPE_CLOSE;
            [self setUpCloseItem];
        }
    } else {
        if (_type != ITEMTYPE_BACK) {
            _type = ITEMTYPE_BACK;
            [self setUpBackItem];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if ([[NetworkManager shareManager] currentReachabilityStatus] == NotReachable) {
        if (self.backgroundView.hidden) {
            self.backgroundView.hidden = NO;
        }
    } else {
        [self makeToast:@"网页加载失败"];
    }
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:JSHOST]) {
        NSDictionary *body = message.body;
        if ([body isKindOfClass:[NSDictionary class]]) {
            DDDLog(@"JS Response Data: %@",body);
            [self handleMessage:body];
        }
    }
}

#pragma mark - HOST
- (void)handleMessage:(NSDictionary *)body
{
    NSString *cmd = body[@"cmd"];
    if ([cmd isEqualToString:@"closePage"]) {
        [self handleClosePage];
    } else if ([cmd isEqualToString:@"ready"]) {
        [self handleReady:body];
    }
}

- (void)handleClosePage
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    if ([NSStringFromClass([vc class]) isEqualToString:@"AVFullScreenViewController"]) {
        [vc dismissViewControllerAnimated:NO completion:^{
            [UIApplication sharedApplication].keyWindow.rootViewController = self.navigationController.tabBarController;
            [self backBtnClick:nil];
        }];
    } else {
        [self backBtnClick:nil];
    }
}

- (void)handleReady:(NSDictionary *)body
{
    if (SApp.uid && SApp.token) {
        NSString *func = body[@"callback"];
        NSDictionary *info = @{@"uid": @(SApp.uid), @"token": SApp.token};
        NSString *javaScript = [NSString stringWithFormat:@"%@('%@')", func, [Tools dictionaryToJsonString:info]];
        [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            if (error) {
                DDDLog(@"javaScript error: %@",error);
            }
        }];
    }
}

@end
