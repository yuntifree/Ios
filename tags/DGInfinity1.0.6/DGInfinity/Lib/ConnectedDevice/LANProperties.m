//
//  LANProperties.m
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import "LANProperties.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>

@implementation LANProperties

#pragma mark - Public methods
+(NSString*)fetchSSIDInfo {
    
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();

    NSDictionary *info;
    
    for (NSString *ifnam in ifs) {
        
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
    
            return [info objectForKey:@"SSID"];
            break;
        }
    }
    
    return @"No WiFi Available";
}

//Not working
#pragma mark - Get Host from IP
+(NSString *)getHostFromIPAddress:(NSString*)ipAddress {
    struct addrinfo *result = NULL;
    struct addrinfo hints;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_flags = AI_NUMERICHOST;
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = 0;
    
    int errorStatus = getaddrinfo([ipAddress cStringUsingEncoding:NSASCIIStringEncoding], NULL, &hints, &result);
    if (errorStatus != 0) {
        return nil;
    }
    
    CFDataRef addressRef = CFDataCreate(NULL, (UInt8 *)result->ai_addr, result->ai_addrlen);
    if (addressRef == nil) {
        return nil;
    }
    freeaddrinfo(result);
    
    CFHostRef hostRef = CFHostCreateWithAddress(kCFAllocatorDefault, addressRef);
    if (hostRef == nil) {
        return nil;
    }
    CFRelease(addressRef);
    
    BOOL succeeded = CFHostStartInfoResolution(hostRef, kCFHostNames, NULL);
    if (!succeeded) {
        return nil;
    }
    
    NSMutableArray *hostnames = [NSMutableArray array];
    
    CFArrayRef hostnamesRef = CFHostGetNames(hostRef, NULL);
    for (int currentIndex = 0; currentIndex < [(__bridge NSArray *)hostnamesRef count]; currentIndex++) {
        [hostnames addObject:[(__bridge NSArray *)hostnamesRef objectAtIndex:currentIndex]];
    }
    
    return hostnames[0];
}

@end
