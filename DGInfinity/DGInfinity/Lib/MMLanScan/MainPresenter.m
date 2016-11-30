//
//  MainPresenter.m
//  MMLanScanDemo
//
//  Created by Michael Mavris on 04/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MainPresenter.h"
#import "LANProperties.h"
#import "MMLANScanner.h"
#import "Device.h"

@interface MainPresenter()<MMLANScannerDelegate>

@property (nonatomic,weak)id <MainPresenterDelegate> delegate;
@property(nonatomic,strong)MMLANScanner *lanScanner;
@property(nonatomic,assign,readwrite)BOOL isScanRunning;
@property(nonatomic,assign,readwrite)float progressValue;
@end

@implementation MainPresenter {
    NSMutableArray *connectedDevicesMutable;
}

#pragma mark - Init method
//Initialization with delegate
-(instancetype)initWithDelegate:(id <MainPresenterDelegate>)delegate {

    self = [super init];
    
    if (self) {
        
        self.isScanRunning=NO;
       
        self.delegate=delegate;
        
        self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
    }
    
    return self;
}

#pragma mark - Button Actions
//This method is responsible for handling the tap button action on MainVC. In case the scan is running and the button is tapped it will stop the scan
-(void)scanButtonClicked {
    
    //Checks if is already scanning
    if (self.isScanRunning) {
        
        [self stopNetworkScan];
    }
    else {
        
        [self startNetworkScan];
    }
    
}
-(void)startNetworkScan {
    
    self.isScanRunning=YES;
    
    connectedDevicesMutable = [[NSMutableArray alloc] init];
    
    [self.lanScanner start];
};

-(void)stopNetworkScan {
    
    [self.lanScanner stop];
    
    self.isScanRunning=NO;
}

#pragma mark - SSID
//Getting the SSID string using LANProperties
-(NSString*)ssidName {

    return [NSString stringWithFormat:@"SSID: %@",[LANProperties fetchSSIDInfo]];
};

#pragma mark - MMLANScannerDelegate methods
//The delegate methods of MMLANScanner
-(void)lanScanDidFindNewDevice:(Device*)device{
    
    //Check if the Device is already added
    if (![connectedDevicesMutable containsObject:device]) {

        [connectedDevicesMutable addObject:device];
    }
    
    //Updating the array that holds the data. MainVC will be notified by KVO
    self.connectedDevices = [NSArray arrayWithArray:connectedDevicesMutable];
}

-(void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status{
   
    self.isScanRunning=NO;
    
    //Checks the status of finished. Then call the appropriate method
    if (status == MMLanScannerStatusFinished) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(mainPresenterIPSearchFinished)]) {
            [self.delegate mainPresenterIPSearchFinished];
        }
    }
    else if (status==MMLanScannerStatusCancelled) {
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(mainPresenterIPSearchCancelled)]) {
            [self.delegate mainPresenterIPSearchCancelled];
        }
    }
}

-(void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts {
    
    //Updating the progress value. MainVC will be notified by KVO
    self.progressValue=pingedHosts/overallHosts;
}

-(void)lanScanDidFailedToScan {
   
    self.isScanRunning=NO;

    if (self.delegate && [self respondsToSelector:@selector(mainPresenterIPSearchFailed)]) {
        [self.delegate mainPresenterIPSearchFailed];
    }
}

@end