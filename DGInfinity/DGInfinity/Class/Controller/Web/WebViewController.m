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
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        config.preferences = [WKPreferences new];
        config.userContentController = [WKUserContentController new];
        [config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:JSHOST];
        if (!IOS9) {
            config.mediaPlaybackRequiresUserAction = NO;
        } else {
            config.requiresUserActionForMediaPlayback = NO;
        }
        CGFloat systemBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.height;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - systemBarHeight) configuration:config];
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
        _progressView.frame = CGRectMake(0, 0, kScreenWidth, 4);
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
        _backgroundView = [[UIScrollView alloc] initWithFrame:self.webView.bounds];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        __weak typeof(self) wself = self;
        [_backgroundView configureNoNetStyleWithdidTapButtonBlock:^{
            [wself.webView loadRequest:wself.currentRequest];
        } didTapViewBlock:^{
            
        }];
    }
    return _backgroundView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = ITEMTYPE_BACK;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_newsType == NT_VIDEO) {
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
        self.webView.backgroundColor = [UIColor blackColor];
    } else {
        self.webView.backgroundColor = [UIColor whiteColor];
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
            NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [super backBtnClick:sender];
            });
        } else {
            [super backBtnClick:sender];
        }
    }
}

- (void)closeBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.webView) {
        if ([keyPath isEqualToString:@"title"]) {
            if (self.webView.title.length) {
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
        [webView evaluateJavaScript:@"document.body.style.backgroundColor = '#000';" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            if (error) {
                DDDLog(@"---%@",error);
            }
        }];
    }
    if (_backgroundView.superview) {
        [self.backgroundView removeFromSuperview];
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
        if (!_backgroundView.superview) {
            [self.view addSubview:self.backgroundView];
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
        }
    }
}

@end
