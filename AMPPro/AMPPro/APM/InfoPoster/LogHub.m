//
//  LogHub.m
//  WAGChat
//
//  Created by yanjing on 2017/9/4.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "LogHub.h"
#import "AliyunLogObjc.h"
#import <Foundation/Foundation.h>

@interface LogHub()

@property (nonatomic, strong) LogClient *client;

@end

@implementation LogHub

+ (instancetype)sharedLogHub {
    
    static LogHub *_sharedLogHub = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogHub = [[self alloc] init];
    });
    
    return _sharedLogHub;
}


- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
//    projectName 类似于 数据库名；
//    endpoint 类似是 projectName + 域名；
//    accessKeyID： 阿里云提供；
//    accessKeySecret阿里云提供；
    
  

    return self;
}


-(void)createLoghubClient:(NSString*) endPoint accessKeyID:(NSString *)ak accessKeySecret: (NSString *)as projectName: (NSString *)name
{
    if (self.client == nil) {
        self.client = [[LogClient alloc] initWithApp: endPoint accessKeyID:ak accessKeySecret:as projectName:name];
    }
    
}

- (void)postLogContent:(NSString*)content  // log 内容
               withKey:(NSString*)key      // log  key
             withTopic:(NSString*)topic     // log 类型 的标记 ，例如，汽车分为： 货车，装甲车，救护车，警车。
             andSource:(NSString*)source    // 可以理解为：log 的来源的标记 ，比如 ： 买家，卖家，管家。
          logStoreName:(NSString*)name      // 可以理解为 数据库中 一个表的表名
//                  call:(void (^)(NSURLResponse* _Nullable response,NSError* _Nullable error) )errorCallback
{
    if (self.client == nil) {
        return;
    }
    LogGroup *logGroup = [[LogGroup alloc] initWithTopic: topic andSource:source];
    Log *log = [[Log alloc] init];
    NSDate *date = [NSDate date];
    [log PutTime: [date timeIntervalSince1970]];

    [log PutContent: content withKey: key];
    [logGroup PutLog:log];
    
    [self.client PostLog:logGroup logStoreName: name call:^(NSURLResponse* _Nullable response,NSError* _Nullable error) {
        if (error != nil) {
            
        }
    }];
}
- (void)postLog:(NSArray<Log *> *)logs
             withTopic:(NSString*)topic
             andSource:(NSString*)source
          logStoreName:(NSString*)name
//                  call:(void (^)(NSURLResponse* _Nullable response,NSError* _Nullable error) )errorCallback
{
    if (self.client == nil) {
        return;
    }
    LogGroup *logGroup = [[LogGroup alloc] initWithTopic: topic andSource:source];
    NSDate *date = [NSDate date];

    for (Log * logObj in logs) {
        [logObj PutTime: [date timeIntervalSince1970]];
        [logGroup PutLog:logObj];
    }
    
    [self.client PostLog:logGroup logStoreName: name call:^(NSURLResponse* _Nullable response,NSError* _Nullable error) {
        if (error != nil) {
            
        }
    }];
}

- (void)postLogWithDic:(NSDictionary *)logs
      withTopic:(NSString*)topic
      andSource:(NSString*)source
   logStoreName:(NSString*)name
//                  call:(void (^)(NSURLResponse* _Nullable response,NSError* _Nullable error) )errorCallback
{
    if (self.client == nil) {
        return;
    }
    LogGroup *logGroup = [[LogGroup alloc] initWithTopic: topic andSource:source];
    NSDate *date = [NSDate date];

    Log *log = [[Log alloc] init];
    [log PutTime: [date timeIntervalSince1970]];
    for ( NSString * key in logs.allKeys) {
        [log  PutContent: logs[key] withKey:key];
    }
    [logGroup PutLog:log];

    
    
//    Log *log = [[Log alloc] init];
//    NSDate *date = [NSDate date];
//    [log PutTime: [date timeIntervalSince1970]];
//    [log PutContentWithDic:logs];
//    [logGroup PutLog:log];

//    for (Log * logObj in logs) {
//        [logGroup PutLog:logObj];
//    }
    
    [self.client PostLog:logGroup logStoreName: name call:^(NSURLResponse* _Nullable response,NSError* _Nullable error) {
        if (error != nil) {
            
        }
    }];
}

- (void)postLogWithInfo:(NSArray *)netInfos
             withTopic:(NSString*)topic
             andSource:(NSString*)source
          logStoreName:(NSString*)name
                  callback:(void (^)(int res, NSError* _Nullable error) )errorCallback
{
    if (self.client == nil || netInfos == nil || netInfos.count == 0) {
        return;
    }
    
    
    LogGroup *logGroup = [[LogGroup alloc] initWithTopic: topic andSource:source];
    NSDate *date = [NSDate date];
    
    for ( NSDictionary * logs  in netInfos ) {
        
        Log *log = [[Log alloc] init];
        [log PutTime: [date timeIntervalSince1970]];
        for ( NSString * key in logs.allKeys) {
            [log  PutContent: logs[key] withKey:key];
        }
        
        [logGroup PutLog:log];

    }
    
    
    [self.client PostLog:logGroup logStoreName: name call:^(NSURLResponse* _Nullable response,NSError* _Nullable error) {
        if (errorCallback)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

             errorCallback(httpResponse.statusCode,error);
        }
    }];
}




@end
