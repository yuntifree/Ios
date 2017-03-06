//
//  LANProperties.h
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LANProperties : NSObject

/*!
 @brief This method returns the hostname of a specific IP Address
 @param ipAddress The IP Address in string
 @return An NSString which is the host of the IP Address
 @code
 NSString *newDevice = [LANProperties getHostFromIPAddress:@"192.168.1.10"];
 @endcode
 */
+(NSString *)getHostFromIPAddress:(NSString*)ipAddress;

/*!
 @brief This method returns the SSID of the WiFi if is available, otherwise returns "No WiFi available"
 @return An NSString which is the SSID of the WiFi network
 @code
 NSString *wifiSSID = [LANProperties fetchSSIDInfo];
 @endcode
 */
+(NSString*)fetchSSIDInfo;
@end
