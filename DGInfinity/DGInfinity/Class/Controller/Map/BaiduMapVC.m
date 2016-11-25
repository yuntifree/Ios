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

- (id)initWithTitle:(NSString *)title distance:(CLLocationDistance)distance;

@end

@implementation LocationActionPaopaoView

- (void)dealloc
{
    DDDLog(@"LocationActionPaopaoView Dealloc");
}

- (id)initWithTitle:(NSString *)title distance:(CLLocationDistance)distance
{
    self = [super initWithFrame:CGRectMake(0, 0, 250, 140)];
    if (self) {
        
        UIImageView *wifiView = [[UIImageView alloc] initWithImage:ImageNamed(@"icon_WiFi")];
        wifiView.origin = CGPointMake(17, 16);
        [self addSubview:wifiView];
        
        UILabel *ssidLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(wifiView.frame) + 10, 16, self.width - CGRectGetMaxX(wifiView.frame) - 20, 17)];
        ssidLbl.font = SystemFont(12);
        ssidLbl.textColor = COLOR(49, 49, 49, 1);
        ssidLbl.text = WIFISDK_SSID;
        [self addSubview:ssidLbl];
        
        UIImageView *locationView = [[UIImageView alloc] initWithImage:ImageNamed(@"ico_location")];
        locationView.origin = CGPointMake(wifiView.x, CGRectGetMaxY(wifiView.frame) + 18);
        [self addSubview:locationView];
        
        UILabel *locationLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(locationView.frame), 73, 140, 14)];
        locationLbl.font = SystemFont(10);
        locationLbl.textColor = COLOR(180, 180, 180, 1);
        if (title.length) {
            locationLbl.text = title;
        } else {
            locationLbl.text = @"暂无地理位置信息";
        }
        [self addSubview:locationLbl];
        
        UIImageView *walkView = [[UIImageView alloc] initWithImage:ImageNamed(@"ico_walk")];
        walkView.origin = CGPointMake(177, 70);
        [self addSubview:walkView];
        
        UILabel *distanceLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(walkView.frame), 72, self.width - CGRectGetMaxX(walkView.frame), 17)];
        distanceLbl.font = SystemFont(12);
        distanceLbl.textColor = COLOR(0, 166, 249, 1);
        distanceLbl.text = [self getDistance:distance];
        [self addSubview:distanceLbl];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(4, CGRectGetMaxY(walkView.frame) + 6, self.width - 8, 30)];
        backView.backgroundColor = COLOR(229, 243, 251, 1);
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 3;
        [self addSubview:backView];
        
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(wifiView.x, 103, self.width - 14, 17)];
        descLbl.font = SystemFont(12);
        descLbl.textColor = COLOR(180, 180, 180, 1);
        descLbl.text = @"前往此处，在WiFi列表里有免费WiFi可连";
        [self addSubview:descLbl];
        
        // 背景
        UIImage *bgImage = ImageNamed(@"btn_Label");
        CGSize size = bgImage.size;
        self.image = [bgImage stretchImageWithFLeftCapWidth:size.width - 10 fTopCapHeight:size.height * 0.5 tempWidth:self.width sLeftCapWidth:10 sTopCapHeight:size.height * 0.5];
    }
    return self;
}

- (NSString *)getDistance:(CLLocationDistance)distance
{
    NSString *text = nil;
    if (distance > 1000) {
        text = [NSString stringWithFormat:@"%.1lfkm",distance / 1000.0];
    } else {
        text = [NSString stringWithFormat:@"%.0lfm",distance];
    }
    return text;
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
        UIImage *image = anno.isMyLocation ? ImageNamed(@"target") : ImageNamed(@"bar-wifi");
        UIImageView *iv = [[UIImageView alloc] initWithImage:image];
        self.bounds = iv.bounds;
        [self addSubview:iv];
        
        LocationActionPaopaoView *paopaoView = [[LocationActionPaopaoView alloc] initWithTitle:anno.title distance:MetersTwoCoordinate2D([[BaiduMapSDK shareBaiduMapSDK] getUserLocation].location.coordinate, anno.coordinate)];
        BMKActionPaopaoView *paopao = [[BMKActionPaopaoView alloc] initWithCustomView:paopaoView];
        self.paopaoView = paopao;
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
    BMKUserLocation *_myLocation;
    
    NSMutableSet *_annotitaionSet;
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
    return @"WiFi地图";
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        _annotitaionSet = [NSMutableSet setWithCapacity:20];
        _myLocation = [[BaiduMapSDK shareBaiduMapSDK] getUserLocation];
    }
    return self;
}

- (void)willEnterForeground
{
    if ([[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled] && !_mapView.annotations.count) {
        _myLocation = [[BaiduMapSDK shareBaiduMapSDK] getUserLocation];
        [_mapView updateLocationData:_myLocation];
        [self navBtnClick];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    [SVProgressHUD showWithStatus:@"正在查找免费WiFi"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
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
    _mapView.showsUserLocation = YES;
    _mapView.zoomLevel = 16.1;
    _mapView.centerCoordinate = _myLocation.location.coordinate;
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isAccuracyCircleShow = NO;
    param.locationViewImgName = @"target";
    [_mapView updateLocationViewWithParam:param];
    [_mapView setNeedsUpdateConstraints];
    [self.view addSubview:_mapView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(kScreenWidth - 36 - 20, 20, 36, 36);
    [button setBackgroundImage:ImageNamed(@"Navigation") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(navBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)navBtnClick
{
    if (![[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled]) return;
    BMKMapStatus *status = [BMKMapStatus new];
    status.targetGeoPt = _myLocation.location.coordinate;
    [_mapView setMapStatus:status withAnimation:YES];
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
- (void)addAnnotations:(CLLocationCoordinate2D)location
{
    [MapCGI getNearbyAps:location.longitude latitude:location.latitude complete:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *infos = data[@"infos"];
                if ([infos isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *info in infos) {
                        @autoreleasepool {
                            LocationAnnotation *annotation = [[LocationAnnotation alloc] init];
                            annotation.title = info[@"address"];
                            annotation.coordinate = CLLocationCoordinate2DMake([info[@"latitude"] doubleValue], [info[@"longitude"] doubleValue]);
                            NSString *hashFlag = [NSString stringWithFormat:@"%lf%lf", annotation.coordinate.latitude, annotation.coordinate.longitude];
                            if (![_annotitaionSet containsObject:hashFlag]) {
                                [_annotitaionSet addObject:hashFlag];
                                [_mapView addAnnotation:annotation];
                            }
                        }
                    }
                }
            }
        } else {
            [self makeToast:res.desc];
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
        [self showAlertWithTitle:@"提示" message:@"无法获取位置信息，建议开启定位服务" cancelTitle:@"忽略" cancelHandler:nil defaultTitle:@"开启" defaultHandler:^(UIAlertAction *action) {
            [Tools openSetting];
        }];
        return;
    }
    [_mapView updateLocationData:_myLocation];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[LocationAnnotation class]]) {
        return nil;
    }
    
    LocationAnnotation *anno = (LocationAnnotation *)annotation;
    NSString *reuseIdentifier = anno.isMyLocation ? @"MyIdentifier" : @"LocationIdentifier";
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[LocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    }
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (![[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled]) return;
    [self addAnnotations:mapView.centerCoordinate];
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    BMKMapStatus *status = [BMKMapStatus new];
    status.targetGeoPt = view.annotation.coordinate;
    [_mapView setMapStatus:status withAnimation:YES];
}

@end
