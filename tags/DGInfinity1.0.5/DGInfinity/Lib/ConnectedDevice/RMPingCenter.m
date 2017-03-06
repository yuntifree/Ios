//
//  RMPingCenter.m
//  360FreeWiFi
//
//  Created by 黄继华 on 16/4/29.
//  Copyright © 2016年 qihoo360. All rights reserved.
//

#import "RMPingCenter.h"
#import "SimplePing.h"
#import "Tools.h"
#import "RMConnectedDevice.h"
#import "LANProperties.h"
#import "MacFinder.h"

@interface RMPingCenter()<SimplePingDelegate>

@property (nonatomic, strong) NSMutableArray *pingArray;
@property (nonatomic, strong) NSMutableArray<RMConnectedDevice *> *connectedDeviceArray;
@property (nonatomic, strong) NSDictionary *brandDictionary;

@end

@implementation RMPingCenter

- (void)dealloc
{
    DDDLog(@"RMPingCenter Dealloc");
}

+ (instancetype)sharedInstance
{
    static RMPingCenter *instance = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        instance = [RMPingCenter new];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.brandDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    }
    return self;
}

- (void)scan
{
    self.connectedDeviceArray = [NSMutableArray array];

    NSTimeInterval delay = 0;
    for (int i = 0; i < 3; i++) { //遍历 3 遍
        for (int j = 0; j < 8; j++) {  //将网段分成 8 部分
            [self performSelector: @selector(startFrom:) withObject: @(1 + 256 / 8 * j) afterDelay: delay];
            delay += 2;
        }
    }
}

- (void)stop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)startFrom:(NSNumber *)index
{
    NSString *ip = [Tools getWlanIPAddress];
    NSArray *array = [ip componentsSeparatedByString: @"."];
    NSMutableString *result = [NSMutableString string];
    if ([array count] == 4) {
        [result appendString: array[0]];
        [result appendString: @"."];
        [result appendString: array[1]];
        [result appendString: @"."];
        [result appendString: array[2]];
        [result appendString: @"."];
    }
    self.pingArray = [NSMutableArray array];
    for (int i = [index intValue]; i < [index intValue] + 64 && i < 255; i++) {
        SimplePing *ping = [SimplePing simplePingWithHostName: [NSString stringWithFormat: @"%@%d", result, i]];
        ping.delegate = self;
        [ping start];
        ping.tag = i;
        [self.pingArray addObject: ping];
    }
}

#pragma mark - SimplePingDelegate

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [pinger sendPingWithData: nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    [pinger stop];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
{

}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
{
    [pinger stop];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
    NSString *gatewayIp = [Tools getServerWiFiIPAddress];
    
    if (pinger.hostName && ![pinger.hostName isEqualToString: gatewayIp]) {
        NSString *mac = [MacFinder ip2mac:pinger.hostName];
        RMConnectedDevice *connectedDevice = [RMConnectedDevice new];
        connectedDevice.mac = [mac uppercaseString];
        connectedDevice.ip = pinger.hostName;
        connectedDevice.dev_name = [LANProperties getHostFromIPAddress:pinger.hostName];
        if (connectedDevice.mac) {
            connectedDevice.brand = [self.brandDictionary objectForKey:[[connectedDevice.mac substringWithRange:NSMakeRange(0, 8)] stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
        }
        NSArray *array = [self.connectedDeviceArray copy];
        [self.connectedDeviceArray removeObject: connectedDevice];
        [self.connectedDeviceArray addObject: connectedDevice];
        [self.connectedDeviceArray sortUsingComparator: ^NSComparisonResult(RMConnectedDevice *obj1, RMConnectedDevice *obj2) {
            int index1 = [[[obj1.ip componentsSeparatedByString: @"."] lastObject] intValue];
            int index2 = [[[obj2.ip componentsSeparatedByString: @"."] lastObject] intValue];
            return index1 > index2 ? NSOrderedDescending : NSOrderedAscending;
        }];
        if (![array isEqualToArray: self.connectedDeviceArray]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_CONNECTED_DEVICE_LIST_CHANGED_USING_PING object: nil];
        }
    }
    [pinger stop];
}


- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    [pinger stop];
}

#pragma mark - 

- (NSArray *)getConnectedDevice
{
    return [self.connectedDeviceArray copy];
}

- (NSArray<RMConnectedDevice *> *)getConnectedDeviceWithoutCurrent
{
    RMConnectedDevice *connectedDevice = [RMConnectedDevice new];
    connectedDevice.ip = [Tools getWlanIPAddress];
    NSMutableArray *array = [NSMutableArray arrayWithArray: self.connectedDeviceArray];
    [array removeObject: connectedDevice];
    return [array copy];
}

@end
