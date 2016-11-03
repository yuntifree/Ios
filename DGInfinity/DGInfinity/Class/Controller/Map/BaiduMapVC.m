//
//  BaiduMapVC.m
//  BaiduSB
//
//  Created by jacky.lee on 16/8/11.
//  Copyright © 2016年 aini25. All rights reserved.
//


#import "BaiduMapVC.h"
#import "BaiduMapSDK.h"
#import "UIImage+LeftAndRightStretch.h"
#import "MapCGI.h"

/**
 *  自定义PointAnnotation类
 */
@interface LocationAnnotation : BMKPointAnnotation

@property (nonatomic, assign) BOOL isMyLocation;

@end

@implementation LocationAnnotation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMyLocation = NO;
    }
    return self;
}

- (void)dealloc
{
    DDDLog(@"LocationAnnotation Dealloc");
}

@end

/**
 *  自定义BMKActionPaopaoView类
 */
@interface LocationActionPaopaoView : UIImageView

- (id)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle;

@end

@implementation LocationActionPaopaoView

- (void)dealloc
{
    DDDLog(@"LocationActionPaopaoView Dealloc");
}

- (id)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.image = nil;
        CGFloat windowW = [UIApplication sharedApplication].keyWindow.bounds.size.width;
        
        CGFloat selfH = 51;
        CGFloat btnW = 42;
        CGFloat maxW = windowW - btnW - 51;
        
        // titleLb
        UIFont *titleFont = [UIFont systemFontOfSize:12];
        CGFloat titleW = [self widthWithString:title font:titleFont constrainedToSize:CGSizeMake(maxW, 14)];
        UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, titleW, 14)];
        titleLb.font = titleFont;
        titleLb.text = title;
        titleLb.textColor = RGB(0xffffff, 1);
        [self addSubview:titleLb];
        
        // addressLb
        UIFont *subTitleFont = [UIFont systemFontOfSize:10];
        CGFloat subTitleW = [self widthWithString:subTitle font:subTitleFont constrainedToSize:CGSizeMake(maxW, 12)];
        UILabel *subTitleLb = [[UILabel alloc] initWithFrame:CGRectMake(8, 24, subTitleW, 12)];
        subTitleLb.font = subTitleFont;
        subTitleLb.text = subTitle;
        subTitleLb.textColor = RGB(0xffffff, 1);
        [self addSubview:subTitleLb];
        
        CGFloat w = (titleW > subTitleW ? titleW : subTitleW) + btnW + 41;
        self.bounds = CGRectMake(0, 0, w, selfH);
        
        // 背景
        UIImage *bgImage = ImageNamed(@"bg_navigation.png");
        CGSize size = bgImage.size;
        self.image = [bgImage stretchImageWithFLeftCapWidth:size.width-10 fTopCapHeight:size.height*0.5 tempWidth:w sLeftCapWidth:10 sTopCapHeight:size.height*0.5];
    }
    return self;
}

- (CGFloat)widthWithString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    return rect.size.width;
}

@end


/**
 *  自定义PINAnnotationView类
 */
@interface LocationAnnotationView : BMKAnnotationView

@end

@implementation LocationAnnotationView

- (void)dealloc
{
    DDDLog(@"LocationAnnotationView Dealloc");
}

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        LocationAnnotation *anno = (LocationAnnotation *)annotation;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"mapapi" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        NSString *imageUrl = anno.isMyLocation ? [imageBundle pathForResource:@"icon_center_point" ofType:@"png" inDirectory:@"images"] : [imageBundle pathForResource:@"pin_green" ofType:@"png" inDirectory:@"images"];
        UIImage *image = [UIImage imageWithContentsOfFile:imageUrl];
        UIImageView *iv = [[UIImageView alloc] initWithImage:image];
        self.bounds = iv.bounds;
        [self addSubview:iv];
        
        if (!anno.isMyLocation) { // 如果是终点，则弹出自定义泡泡
            LocationActionPaopaoView *paopaoView = [[LocationActionPaopaoView alloc] initWithTitle:anno.title subTitle:anno.subtitle];
            BMKActionPaopaoView *paopao = [[BMKActionPaopaoView alloc] initWithCustomView:paopaoView];
            self.paopaoView = paopao;
        }
    }
    return self;
}

@end


/**
 *  BaiduMapVC类
 */
@interface BaiduMapVC () <BMKMapViewDelegate>
{
    BMKMapView *_mapView;
    LocationInfo *_myLocation;
}

@end

@implementation BaiduMapVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _mapView = nil;
}

- (NSString *)title
{
    return @"附近的免费WiFi";
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
//        _myLocation = [[LocationInfo alloc] initWithCoordinate2D:[[BaiduMapSDK shareBaiduMapSDK] getUserLocation] busiName:@"我的位置" locationDesc:@"我的位置" isMyLocation:YES];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(22.930574, 113.890796);
        _myLocation = [[LocationInfo alloc] initWithCoordinate2D:location busiName:@"我的位置" locationDesc:@"我的位置" isMyLocation:YES];
    }
    return self;
}

- (void)willEnterForeground
{
    if ([[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled] && !_mapView.annotations.count) {
        [self addAnnotations];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 适配ios7
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    _mapView = [[BMKMapView alloc] init];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    _mapView.centerCoordinate = _myLocation.coordinate2D;
    _mapView.zoomLevel = 16.1;
    [_mapView setNeedsUpdateConstraints];
    [self.view addSubview:_mapView];
}

- (void)updateViewConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_mapView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_mapView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [super updateViewConstraints];
}

// 添加附近WiFi位置标注，和我的位置标注
- (void)addAnnotations
{
    if (_mapView.annotations.count) {
        [_mapView removeAnnotations:_mapView.annotations];
    }
    
//    _myLocation = [[LocationInfo alloc] initWithCoordinate2D:[[BaiduMapSDK shareBaiduMapSDK] getUserLocation] busiName:@"我的位置" locationDesc:@"我的位置" isMyLocation:YES];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(22.930574, 113.890796);
    _myLocation = [[LocationInfo alloc] initWithCoordinate2D:location busiName:@"我的位置" locationDesc:@"我的位置" isMyLocation:YES];
    
    LocationAnnotation *myAnnotation = [[LocationAnnotation alloc] init];
    myAnnotation.coordinate = _myLocation.coordinate2D;
    myAnnotation.title = _myLocation.busiName;
    myAnnotation.isMyLocation = _myLocation.isMyLocation;
    [_mapView addAnnotation:myAnnotation];
    
    [SVProgressHUD showWithStatus:@"正在查找免费WiFi"];
    [MapCGI getNearbyAps:myAnnotation.coordinate.longitude latitude:myAnnotation.coordinate.latitude complete:^(DGCgiResult *res) {
        [SVProgressHUD dismissWithDelay:1];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *infos = data[@"infos"];
                if ([infos isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tem = [NSMutableArray arrayWithCapacity:20];
                    for (NSDictionary *info in infos) {
                        LocationAnnotation *annotation = [[LocationAnnotation alloc] init];
                        annotation.title = [NSString stringWithFormat:@"%ld",[info[@"aid"] integerValue]];
                        annotation.subtitle = @"东莞智慧城市WiFi";
                        annotation.coordinate = CLLocationCoordinate2DMake([info[@"latitude"] doubleValue], [info[@"longitude"] doubleValue]);
                        [tem addObject:annotation];
                    }
                    [_mapView addAnnotations:tem];
                }
            }
        } else {
            [self showHint:res.desc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    if (![[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法获取位置信息，建议开启定位服务" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Tools openSetting];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // 这一句为了处理第一次弹出paopaoView后，点击地图空白处，paopaoView不会消失的问题。
    _mapView.zoomLevel = _mapView.zoomLevel - 0.00001;
    [self addAnnotations];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[LocationAnnotation class]]) {
        return nil;
    }
    
    static NSString *reuseIdentifier = @"reuseIdentifier";
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[LocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"reuseIdentifier"];
    }
    return annotationView;
}

@end
