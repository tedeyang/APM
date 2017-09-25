//
//  WAGUserAgent.m
//  WAGChat
//
//  Created by yanjing on 2017/9/17.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "WAGUserAgent.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>

@implementation WAGUserAgent


+(NSString *)appInformation{
  
// User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
NSString * userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
 
    
    
    return userAgent;
}


@end
