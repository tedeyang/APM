//
//  LogHubManager.h
//  WAGChat
//
//  Created by yanjing on 2017/9/17.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogHubInstallation : NSObject

+ (LogHubInstallation*)managerInstance;
+ (instancetype)sharedInstance ;
- (void) install;
- (void) install:(NSString*) endPoint accessKeyID:(NSString *)ak accessKeySecret: (NSString *)as projectName: (NSString *)name;

- (void) uploadLogs;

@end
