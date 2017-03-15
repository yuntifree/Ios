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
#import "DetailLocationViewController.h"

/**
 *  自定义BMKActionPaopaoView类
 */
@interface LocationActionPaopaoView : UIImageView
{
    BMKPointAnnotation *_annotation;
}

@property (nonatomic, copy) void(^navigateBlock)(BMKPointAnnotation *annotation);

- (id)initWithAnnotion:(BMKPointAnnotation *)annotation;

@end

@implementation LocationActionPaopaoView

- (void)dealloc
{
    DDDLog(@"LocationActionPaopaoView Dealloc");
}

- (id)initWithAnnotion:(BMKPointAnnotation *)annotation
{
    self = [super initWithFrame:CGRectMake(0, 0, 250, 140)];
    if (self) {
        self.userInteractionEnabled = YES;
        _annotation = annotation;
        
        UIImageView *wifiView = [[UIImageView alloc] initWithImage:ImageNamed(@"ico_wifiname")];
        wifiView.origin = CGPointMake(18, 16);
        [self addSubview:wifiView];
        
        UILabel *ssidLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(wifiView.frame) + 6, 18, 140, 17)];
        ssidLbl.font = SystemFont(12);
        ssidLbl.textColor = COLOR(49, 49, 49, 1);
        ssidLbl.text = WIFISDK_SSID;
        [self addSubview:ssidLbl];
        
        UIImageView *locationView = [[UIImageView alloc] initWithImage:ImageNamed(@"ico_location")];
        locationView.origin = CGPointMake(wifiView.x, CGRectGetMaxY(wifiView.frame) + 7);
        [self addSubview:locationView];
        
        UILabel *locationLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(locationView.frame) + 5, CGRectGetMaxY(ssidLbl.frame) + 11, 130, 14)];
        locationLbl.font = SystemFont(10);
        locationLbl.textColor = COLOR(180, 180, 180, 1);
        if (annotation.title.length) {
            locationLbl.text = annotation.title;
        } else {
            locationLbl.text = @"暂无地理位置信息";
        }
        [self addSubview:locationLbl];
        
        UILabel *distanceLbl = [[UILabel alloc] initWithFrame:CGRectMake(locationLbl.x, CGRectGetMaxY(locationLbl.frame) + 6, 130, 20)];
        distanceLbl.font = SystemFont(14);
        distanceLbl.textColor = COLOR(0, 166, 249, 1);
        distanceLbl.text = [self getDistance:MetersTwoCoordinate2D([[BaiduMapSDK shareBaiduMapSDK] getUserLocation].location.coordinate, annotation.coordinate)];
        [self addSubview:distanceLbl];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(4, CGRectGetMaxY(distanceLbl.frame) + 12, self.width - 8, 29)];
        backView.backgroundColor = COLOR(229, 243, 251, 1);
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 3;
        [self addSubview:backView];
        
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, backView.y + 6, self.width - 28, 17)];
        descLbl.font = SystemFont(12);
        descLbl.textColor = COLOR(180, 180, 180, 1);
        descLbl.text = @"前往此处，在WiFi列表里有免费WiFi可连";
        [self addSubview:descLbl];
        
        // 背景
        UIImage *bgImage = ImageNamed(@"btn_Label");
        CGSize size = bgImage.size;
        self.image = [bgImage stretchImageWithFLeftCapWidth:size.width - 10 fTopCapHeight:size.height * 0.5 tempWidth:self.width sLeftCapWidth:10 sTopCapHeight:size.height * 0.5];
        
        // 导航
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.width - 58 - 11, 26, 58, 58);
        [button setBackgroundImage:ImageNamed(@"btn_going_nor") forState:UIControlStateNormal];
        [button setBackgroundImage:ImageNamed(@"btn_going_pre") forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(navigateClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
    }
    return self;
}

- (void)navigateClick
{
    if (_navigateBlock) {
        _navigateBlock(_annotation);
    }
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
 *  BaiduMapVC类
 */
@interface BaiduMapVC () <BMKMapViewDelegate>
{
    __weak IBOutlet BMKMapView *_mapView;
    BMKUserLocation *_myLocation;
    
    NSMutableArray *_annotitaions;
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
        _annotitaions = [NSMutableArray array];
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
    
    [self setUpMapView];
}

- (void)setUpMapView
{
    _mapView.showsUserLocation = YES;
    _mapView.showMapScaleBar = YES;
    _mapView.zoomLevel = 16.1;
    _mapView.centerCoordinate = _myLocation.location.coordinate;
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isAccuracyCircleShow = NO;
    param.locationViewImgName = @"target";
    [_mapView updateLocationViewWithParam:param];
}

- (IBAction)navBtnClick
{
    if (![[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled]) {
        [self showAlertWithTitle:@"提示" message:@"无法获取位置信息，建议开启定位服务" cancelTitle:@"忽略" cancelHandler:nil defaultTitle:@"开启" defaultHandler:^(UIAlertAction *action) {
            [Tools openSetting];
        }];
        return;
    }
    BMKMapStatus *status = [BMKMapStatus new];
    status.targetGeoPt = _myLocation.location.coordinate;
    [_mapView setMapStatus:status withAnimation:YES];
}

// 添加WiFi位置标注
- (void)addAnnotations
{
    if (_annotitaionInfos && _annotitaionInfos.count) {
        [SVProgressHUD showWithStatus:@"正在查找免费WiFi"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (NSDictionary *info in _annotitaionInfos) {
                @autoreleasepool {
                    if (![info[@"latitude"] doubleValue] && ![info[@"longitude"] doubleValue]) continue;
                    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
                    annotation.title = info[@"address"];
                    annotation.coordinate = CLLocationCoordinate2DMake([info[@"latitude"] doubleValue], [info[@"longitude"] doubleValue]);
                    [_annotitaions addObject:annotation];
                }
            }
            [_mapView addAnnotations:_annotitaions];
        });
    } else {
        [self getAllAps];
    }
}

- (void)getAllAps
{
    [MapCGI getAllAps:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *infos = data[@"infos"];
                if ([infos isKindOfClass:[NSArray class]] && infos.count) {
                    _annotitaionInfos = infos;
                    [self addAnnotations];
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
    [self addAnnotations];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[BMKPointAnnotation class]]) {
        return nil;
    }
    
    static NSString *reuseIdentifier = @"LocationIdentifier";
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        annotationView.image = ImageNamed(@"ico_wifi");
        annotationView.centerOffset = CGPointMake(0, -annotationView.image.size.height / 2);
    }
    LocationActionPaopaoView *paopaoView = [[LocationActionPaopaoView alloc] initWithAnnotion:annotation];
    BMKActionPaopaoView *paopao = [[BMKActionPaopaoView alloc] initWithCustomView:paopaoView];
    annotationView.paopaoView = paopao;
    __weak typeof(self) wself = self;
    paopaoView.navigateBlock = ^ (BMKPointAnnotation *anno) {
        DetailLocationViewController *vc = [DetailLocationViewController new];
        vc.annotation = anno;
        [wself.navigationController pushViewController:vc animated:YES];
    };
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    static int count = 0;
    count += views.count;
    if (count == _annotitaions.count) {
        [SVProgressHUD dismiss];
        count = 0;
    }
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    BMKMapStatus *status = [BMKMapStatus new];
    status.targetGeoPt = view.annotation.coordinate;
    [_mapView setMapStatus:status withAnimation:YES];
}

@end
