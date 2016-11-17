//
//  WiFiScanQrcodeViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiScanQrcodeViewController.h"
#import "MTBBarcodeScanner.h"
#import "PartialTransparentView.h"
#import "WiFiQrcodeFailViewController.h"

@interface WiFiScanQrcodeViewController ()

@property (nonatomic, strong) MTBBarcodeScanner *barcodeScanner;

@property (nonatomic, strong) UIView *presentView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *scanningBackgroundView;
@property (nonatomic, strong) UIImageView *scanningImageView;
@property (nonatomic, strong) UIImageView *leftBottomCornorImageView;
@property (nonatomic, strong) UIImageView *rightBottomCornorImageView;
@property (nonatomic, strong) UIImageView *rightTopCornorImageView;
@property (nonatomic, strong) UIImageView *leftTopCornorImageView;
@property (nonatomic, strong) UILabel *firstTextLabel;
@property (nonatomic, strong) UILabel *secondTextLabel;

@property (nonatomic, assign) BOOL isScanning;

@end

@implementation WiFiScanQrcodeViewController

- (NSString *)title
{
    return @"扫码连WiFi";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initScanView];
}

- (void)initScanView
{
    UIView *presentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.width, self.view.height)];
    presentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview: presentView];
    self.barcodeScanner = [[MTBBarcodeScanner alloc] initWithPreviewView: presentView];
    self.presentView = presentView;
    
    UIImageView *leftBottomCornorImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"wif_icon_qrcode_cornor"]];
    [leftBottomCornorImageView sizeToFit];
    [presentView addSubview: leftBottomCornorImageView];
    self.leftBottomCornorImageView = leftBottomCornorImageView;
    
    UIImageView *rightBottomCornorImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"wif_icon_qrcode_cornor"]];
    [rightBottomCornorImageView sizeToFit];
    rightBottomCornorImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [presentView addSubview: rightBottomCornorImageView];
    self.rightBottomCornorImageView = rightBottomCornorImageView;
    
    UIImageView *rightTopCornorImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"wif_icon_qrcode_cornor"]];
    [rightTopCornorImageView sizeToFit];
    rightTopCornorImageView.transform = CGAffineTransformMakeRotation(-M_PI);
    [presentView addSubview: rightTopCornorImageView];
    self.rightTopCornorImageView = rightTopCornorImageView;
    
    UIImageView *leftTopCornorImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"wif_icon_qrcode_cornor"]];
    [leftTopCornorImageView sizeToFit];
    leftTopCornorImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [presentView addSubview: leftTopCornorImageView];
    self.leftTopCornorImageView = leftTopCornorImageView;
    
    UIImageView *scanningImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"wif_qrcode_scanning"]];
    [scanningImageView sizeToFit];
    self.scanningImageView = scanningImageView;
    
    UIView *scanningBackgroundView = [[UIView alloc] init];
    scanningBackgroundView.layer.masksToBounds = YES;
    [scanningBackgroundView addSubview: scanningImageView];
    self.scanningBackgroundView = scanningBackgroundView;
    [presentView addSubview: scanningBackgroundView];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, kScreenWidth, 18)];
    label.font = [UIFont systemFontOfSize: 15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UICOLOR_ARGB(0xff56abff);
    label.text = @"扫描东莞无线WiFi二维码标识";
    [presentView addSubview: label];
    self.firstTextLabel = label;
    
    label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, kScreenWidth, 18)];
    label.font = [UIFont systemFontOfSize: 15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UICOLOR_ARGB(0xff56abff);
    label.text = @"一键免费上网";
    [presentView addSubview: label];
    self.secondTextLabel = label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.presentView.hidden = YES;
    [SVProgressHUD showWithStatus:LoadingTip];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.presentView.hidden = NO;
    [SVProgressHUD dismiss];
    [self startScanning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [SVProgressHUD dismiss];
    [self stopScanning];
}

#pragma mark - action

- (void)startScanning
{
    __weak typeof(self) weakSelf = self;
    
    [self.barcodeScanner startScanningWithResultBlock: ^(NSArray *codes) {
        [weakSelf.barcodeScanner freezeCapture];
        weakSelf.isScanning = NO;
        weakSelf.scanningImageView.hidden = YES;
        
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            NSString *resultString = code.stringValue;
            NSURL *url = [NSURL URLWithString:resultString];
            NSURLComponents *componets = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            NSArray *queryItems = componets.queryItems;
            if (queryItems.count) {
                bool isExist = NO;
                for (NSURLQueryItem *item in queryItems) {
                    if ([item.name isEqualToString:@"ssid"]) {
                        if ([item.value isEqualToString:WIFISDK_SSID]) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"识别成功" preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                            [weakSelf presentViewController:alert animated:YES completion:nil];
                        } else {
                            [weakSelf showFailPage];
                        }
                        isExist = YES;
                        break;
                    }
                }
                isExist ? : [weakSelf showFailPage];
            } else {
                [weakSelf showFailPage];
            }
            /** 只对第一个扫描结果进行处理 */
            break;
        }
    }];
    
    CGFloat scanWidth = self.view.width * 2 / 3;
    CGRect scanRect = CGRectMake((self.view.width - scanWidth) / 2, self.view.height * 120 / 667, scanWidth, scanWidth);
    self.barcodeScanner.scanRect = scanRect;
    
    CGFloat width = scanRect.size.width;
    self.scanningImageView.size = CGSizeMake(width, self.scanningImageView.height * width / self.scanningImageView.width);
    
    CGPoint leftBottomPoint = CGPointMake(scanRect.origin.x, scanRect.origin.y + scanRect.size.height);
    CGPoint rightBottomPoint = CGPointMake(scanRect.origin.x + scanRect.size.width, scanRect.origin.y + scanRect.size.height);
    CGPoint rightTopPoint = CGPointMake(scanRect.origin.x + scanRect.size.width, scanRect.origin.y);
    CGPoint leftTopPoint = CGPointMake(scanRect.origin.x, scanRect.origin.y);
    self.leftBottomCornorImageView.origin = CGPointMake(leftBottomPoint.x - 1, leftBottomPoint.y - 17);
    self.rightBottomCornorImageView.origin = CGPointMake(rightBottomPoint.x - 17, rightBottomPoint.y - 17);
    self.rightTopCornorImageView.origin = CGPointMake(rightTopPoint.x - 17, rightTopPoint.y - 1);
    self.leftTopCornorImageView.origin = CGPointMake(leftTopPoint.x - 1, leftTopPoint.y - 1);
    
    [self.maskView removeFromSuperview];
    self.maskView = [[PartialTransparentView alloc] initWithFrame: self.view.bounds backgroundColor: UICOLOR_ARGB(0x88000000) andTransparentRects: @[[NSValue valueWithCGRect: CGRectMake(scanRect.origin.x + 0.5, scanRect.origin.y + 0.5, scanRect.size.width - 1, scanRect.size.height - 1)]]];
    [self.presentView insertSubview: self.maskView belowSubview: self.leftBottomCornorImageView];
    
    self.firstTextLabel.y = scanRect.origin.y + scanRect.size.height + 16;
    self.secondTextLabel.y = self.firstTextLabel.y + self.firstTextLabel.height + 13;
    
    [self startScanningImageAnimation];
    self.isScanning = YES;
}

- (void)showFailPage
{
    WiFiQrcodeFailViewController *qrcodeFailViewController = [WiFiQrcodeFailViewController new];
    [self.navigationController pushViewController:qrcodeFailViewController animated:YES];
}

- (void)startScanningImageAnimation
{
    self.scanningBackgroundView.frame = self.barcodeScanner.scanRect;
    self.scanningImageView.origin = CGPointMake(0, -self.scanningImageView.height);
    
    [UIView animateWithDuration: 2 animations: ^{
        self.scanningImageView.origin = CGPointMake(0, self.scanningBackgroundView.height - self.scanningImageView.height);
    } completion: ^(BOOL finished) {
        if (self.isScanning) {
            [self startScanningImageAnimation];
        }
    }];
}

- (void)stopScanning
{
    [self.barcodeScanner stopScanning];
    self.isScanning = NO;
}

@end
