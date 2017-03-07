//
//  DetailLocationViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/3/6.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "DetailLocationViewController.h"
#import "BaiduMapSDK.h"

@interface DetailLocationViewController () <BMKMapViewDelegate>
{
    __weak IBOutlet BMKMapView *_mapView;
    __weak IBOutlet UILabel *_ssidLbl;
    __weak IBOutlet UILabel *_locationLbl;
    
}
@end

@implementation DetailLocationViewController

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
    
    [self setUpSubViews];
}

- (void)setUpSubViews
{
    _mapView.zoomLevel = 16;
    _mapView.centerCoordinate = _annotation.coordinate;
    [_mapView addAnnotation:_annotation];
    
    _ssidLbl.text = WIFISDK_SSID;
    _locationLbl.text = _annotation.title;
}

- (IBAction)navigateClick:(UIButton *)sender {
    BOOL isInstallBaiduMap = [[BaiduMapSDK shareBaiduMapSDK] whetherInstallBaiduApp];
    NSArray *titles = isInstallBaiduMap ? @[@"苹果地图", @"百度地图"] : @[@"苹果地图"];
    __weak typeof(self) wself = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
        LocationInfo *myInfo = [LocationInfo new];
        myInfo.coordinate2D = [[BaiduMapSDK shareBaiduMapSDK] getUserLocation].location.coordinate;
        LocationInfo *targetInfo = [LocationInfo new];
        targetInfo.coordinate2D = wself.annotation.coordinate;
        if (buttonIndex == 1) {
            [[BaiduMapSDK shareBaiduMapSDK] openSystemMapApp:myInfo endLocationInfo:targetInfo];
        } else if (buttonIndex == 2) {
            [[BaiduMapSDK shareBaiduMapSDK] openBaiduMapApp:myInfo endLocationInfo:targetInfo];
        }
    } otherButtonTitleArray:titles];
    [actionSheet show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    static NSString *reuseIdentifier = @"LocationIdentifier";
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        annotationView.pinColor = BMKPinAnnotationColorRed;
    }
    return annotationView;
}

@end
