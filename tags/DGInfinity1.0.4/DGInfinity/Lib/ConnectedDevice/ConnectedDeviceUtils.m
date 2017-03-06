//
//  ConnectedDeviceUtils.m
//  360FreeWiFi
//
//  Created by 黄继华 on 16/4/5.
//  Copyright © 2016年 qihoo360. All rights reserved.
//

#import "ConnectedDeviceUtils.h"
#import "Tools.h"
#import "GCDAsyncUdpSocket.h"
#include <sys/sysctl.h>
#include <net/if_dl.h>
#include "route.h"
#include "if_ether.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <err.h>
#import "getgateway.h"
#import "NetworkManager.h"

@interface ConnectedDeviceUtils()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSMutableArray<RMConnectedDevice *> *connectedDeviceArray;

@end

@implementation ConnectedDeviceUtils

+ (instancetype)sharedInstance
{
    static ConnectedDeviceUtils *instance = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        instance = [ConnectedDeviceUtils new];
        instance.connectedDeviceArray = [NSMutableArray array];
    });

    return instance;
}

- (void)sendUdpToRefreshConnectedDevice
{
    if ([[NetworkManager shareManager] currentReachabilityStatus] == ReachableViaWiFi) {
        NSString *ip = [Tools getServerWiFiIPAddress];
        NSArray *array = [ip componentsSeparatedByString: @"."];
        if ([array count] == 4) {
            NSString *ipPrefix = [NSString stringWithFormat: @"%@.%@.%@.", array[0], array[1], array[2]];
            for (int i = 0; i < 256; i++) {
                uint16_t port = 8361 + i;
                GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
                NSError *error = nil;
                if (![socket bindToPort: port error: &error]) {
                    continue;
                }
                if (![socket beginReceiving:&error]) {
                    continue;
                }
                NSData *data = [@"test" dataUsingEncoding: NSUTF8StringEncoding];
                NSString *targetIp = [NSString stringWithFormat: @"%@.%d", ipPrefix, i];
                [socket sendData: data toHost: targetIp port: port withTimeout: -1 tag: i];
                [socket closeAfterSending];
            }

            dispatch_queue_t queue = dispatch_queue_create("net.qihoo.freewifi.connectedDeviceUtils", DISPATCH_QUEUE_SERIAL);
            for (int i = 0; i < 3; i++) {
                dispatch_async(queue, ^{
                    sleep(1);
                    [self readArpList: ipPrefix];
                });
            }
        }
    }
}

- (void)readArpList:(NSString *)ipPrefix
{
    int mib[6];
    size_t needed;
    char *lim, *buf, *next;
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    extern int h_errno;
    int found_entry = 0;
    u_long addr = 0;
    NSString *gatewayIp = [Tools getServerWiFiIPAddress];

    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    if (sysctl(mib, 6, NULL, &needed, NULL, 0) < 0)
        err(1, "route-sysctl-estimate");
    if ((buf = (char *)malloc(needed)) == NULL)
        err(1, "malloc");
    if (sysctl(mib, 6, buf, &needed, NULL, 0) < 0)
        err(1, "actual retrieval of routing table");
    lim = buf + needed;
    for (next = buf; next < lim; next += rtm->rtm_msglen) {
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        if (addr) {
            if (addr != sin->sin_addr.s_addr)
                continue;
            found_entry = 1;
        }

        NSString *ip = [NSString stringWithUTF8String: inet_ntoa(sin->sin_addr)];
        NSString *mac = @"";
        if (sdl->sdl_alen) {
            u_char *cp = (u_char *)LLADDR(sdl);
            mac = [NSString stringWithFormat: @"%02x:%02x:%02x:%02x:%02x:%02x", cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        } else {
//            mac = @"(incomplete)";
        }

        if (rtm->rtm_rmx.rmx_expire == 0) {
//            mac = [NSString stringWithFormat: @"%@ permanent", mac];
        }
        if (sin->sin_other & SIN_PROXY) {
//            mac = [NSString stringWithFormat: @"%@ published (proxy only)", mac];
        }
        if (rtm->rtm_addrs & RTA_NETMASK) {
            sin = (struct sockaddr_inarp *)
            (sdl->sdl_len + (char *)sdl);
            if (sin->sin_addr.s_addr == 0xffffffff) {
//                mac = [NSString stringWithFormat: @"%@ published", mac];
            }
            if (sin->sin_len != 8) {
//                mac = [NSString stringWithFormat: @"%@ (weird)", mac];
            }
        }

        if ([ip hasPrefix: ipPrefix] && mac.length > 0 && ![gatewayIp isEqualToString: ip]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                RMConnectedDevice *device = [RMConnectedDevice new];
                device.ip = ip;
                device.mac = mac;
                if (![self.connectedDeviceArray containsObject: device]) {
                    [self.connectedDeviceArray addObject: device];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_CONNECTED_DEVICE_LIST_CHANGED object: nil];
            });
        }
    }
}

- (void)clearConnectedDeviceList
{
    [self.connectedDeviceArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_CONNECTED_DEVICE_LIST_CHANGED object: nil];
}

-(NSArray<RMConnectedDevice *> *)getConnectedDeviceList
{
    NSMutableArray<RMConnectedDevice *> *array = [NSMutableArray arrayWithArray: self.connectedDeviceArray];

    //加上本机，因为至少本机是连着 WiFi 的
    RMConnectedDevice *currentDevice = [RMConnectedDevice new];
    currentDevice.ip = [Tools getWlanIPAddress];
    currentDevice.isCurrentDevice = YES;

    if ([array containsObject: currentDevice]) {
        [array exchangeObjectAtIndex: [array indexOfObject: currentDevice] withObjectAtIndex: 0];
    } else {
        [array insertObject: currentDevice atIndex: 0];
    }

    return [array copy];
}

- (NSArray<RMConnectedDevice *> *)getConnectedDeviceListWithoutCurrent
{
    RMConnectedDevice *currentDevice = [RMConnectedDevice new];
    currentDevice.ip = [Tools getWlanIPAddress];

    NSMutableArray<RMConnectedDevice *> *array = [NSMutableArray arrayWithArray: self.connectedDeviceArray];
    if ([array containsObject: currentDevice]) {
        [array removeObject: currentDevice];
    }

    return [array copy];
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
//    CLog(@"udp did send data tag:%ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
//    CLog(@"udp did not send data tag:%ld", tag);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
//    CLog(@"udp did close socket: %@", sock);
}

@end
