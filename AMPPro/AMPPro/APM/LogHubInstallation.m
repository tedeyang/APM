//
//  LogHubManager.m
//  WAGChat
//
//  Created by yanjing on 2017/9/17.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "LogHubInstallation.h"
#import "LogHub.h"
#import "AFNetworkActivityLogger.h"
#import "PersistenceInstallation.h"
#import "AFNetworkReachabilityManager.h"
#import <UIKit/UIApplication.h>

@implementation LogHubInstallation


+ (LogHubInstallation*)managerInstance
{
  
    return [(LogHubInstallation*)[self alloc] init];
}

+ (instancetype)sharedInstance {
    static LogHubInstallation *_sharedLogger = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });
    
    return _sharedLogger;
}
-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return  self;
}

- (void) install:(NSString*) endPoint accessKeyID:(NSString *)ak accessKeySecret: (NSString *)as projectName: (NSString *)name;
{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    [[LogHub sharedLogHub]createLoghubClient:endPoint accessKeyID:ak accessKeySecret:as projectName:name];
    //开启日志
    
    //注册程序进入前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name: UIApplicationWillEnterForegroundNotification object:nil];
    
    //开启日志
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [self uploadLogs];
}

- (void) install
{
    [[LogHub sharedLogHub]createLoghubClient:@"endPoint" accessKeyID:@"ak" accessKeySecret:@"as" projectName:@"name"];

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    //注册程序进入前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name: UIApplicationWillEnterForegroundNotification object:nil];
    
    //开启日志
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [self uploadLogs];

    
}
- (void)appWillEnterForegroundNotification {
    
    [self uploadLogs];
}

-(void)uploadLogs{
    
    BOOL netStatus = [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
 
    if (netStatus) {
        [self logHand_sqlite];
//        [self logHand_ldb];
    }
    

}

-(void)logHand_sqlite{
    [[PersistenceInstallation sharedPersistence].ldpb getLogsWithCallback:^(id data, int code, NSError *err) {
        NSArray * allKeys = data;
        NSMutableArray * allNetObjects =  [NSMutableArray array];
        NSMutableArray * allGapObjects =  [NSMutableArray array];
        
        for ( ApmLog * log in allKeys ) {
            //                NSDictionary * dic = log.content;
            if ([log.topic isEqualToString: @"net"]) {
                [allNetObjects addObject:log.content];
            }else if ([log.topic isEqualToString: @"gap"]) {
                [allGapObjects addObject: log.content];
            }
        }
        
        [[LogHub sharedLogHub]postLogWithInfo:allNetObjects withTopic:@"chat" andSource:@"net" logStoreName:@"wag_ios" callback:^(int res, NSError * _Nullable error) {
            if (res == 200) {
                [[PersistenceInstallation sharedPersistence].ldpb removeValueForKey: @"net" callback:^(id data, int code, NSError *err) {
                }];
            }
            
        }];
        
        [[LogHub sharedLogHub]postLogWithInfo:allGapObjects  withTopic:@"chat" andSource:@"gap" logStoreName:@"wag_ios" callback:^(int res, NSError * _Nullable error) {
            if (res == 200) {
                
                [[PersistenceInstallation sharedPersistence].ldpb removeValueForKey: @"gap" callback:^(id data, int code, NSError *err) {
                }];
            }
            
        }];
        
    }];
    
}

-(void)logHand_ldb{
    
    [[PersistenceInstallation sharedPersistence].ldb allKeysCallback:^(id data, int code, NSError *err) {
        NSArray * allKeys = data;
        NSMutableArray * allNetObjects =  [NSMutableArray array];
        NSMutableArray * allGapObjects =  [NSMutableArray array];
        
        NSMutableArray * allNetKeys =  [NSMutableArray array];
        NSMutableArray * allGapKeys =  [NSMutableArray array];
        
        for ( NSString * key in allKeys ) {
            NSDictionary * dic =  [[PersistenceInstallation sharedPersistence].ldb objectForKey:key];
            if ([key hasPrefix:@"dataKeynet"]) {
                [allNetObjects addObject:dic];
                [allNetKeys addObject:key];
                
            }else if ([key hasPrefix:@"dataKeygap"]) {
                [allGapObjects addObject: dic];
                [allGapKeys addObject:key];
                
            }
        }
        
        [[LogHub sharedLogHub]postLogWithInfo:allGapObjects withTopic:@"chat" andSource:@"gap" logStoreName:@"wag_ios" callback:^(int res, NSError * _Nullable error) {
            if (res == 200) {
                for (NSString *key  in allGapKeys) {
                    [[PersistenceInstallation sharedPersistence].ldb removeValueForKey: key callback:^(id data, int code, NSError *err) {
                        
                    }];
                }
            }
            
        }];
        
        [[LogHub sharedLogHub]postLogWithInfo:allNetObjects withTopic:@"chat" andSource:@"net" logStoreName:@"wag_ios" callback:^(int res, NSError * _Nullable error) {
            if (res == 200) {
                
                for (NSString *key  in allNetKeys) {
                    
                    
                    [[PersistenceInstallation sharedPersistence].ldb removeValueForKey: key callback:^(id data, int code, NSError *err) {
                        
                    }];
                }
            }
            
        }];
        
    }];
}

@end
