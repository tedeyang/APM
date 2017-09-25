// AFNetworkActivityLogger.h
//
// Copyright (c) 2015 AFNetworking (http://afnetworking.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFNetworkActivityLogger.h"
#import <AFNetworking/AFURLSessionManager.h>
#import <objc/runtime.h>
#import "LogHub.h"
#import "WAGUserAgent.h"
#import "PersistenceInstallation.h"


static NSError * AFNetworkErrorFromNotification(NSNotification *notification) {
    NSError *error = nil;
    if ([[notification object] isKindOfClass:[NSURLSessionTask class]]) {
        error = [(NSURLSessionTask *)[notification object] error];
        if (!error) {
            error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
        }
    }
    return error;
}

@interface AFNetworkActivityLogger ()
@property (nonatomic, strong) NSMutableSet *mutableLoggers;

@end

@implementation AFNetworkActivityLogger

+ (instancetype)sharedLogger {
    static AFNetworkActivityLogger *_sharedLogger = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });

    return _sharedLogger;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.mutableLoggers = [NSMutableSet set];

//    AFNetworkActivityConsoleLogger *consoleLogger = [AFNetworkActivityConsoleLogger new];
//    [self addLogger:consoleLogger];

    return self;
}

- (NSSet *)loggers {
    return self.mutableLoggers;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)addLogger:(id<AFNetworkActivityLoggerProtocol>)logger {
    [self.mutableLoggers addObject:logger];
}

- (void)removeLogger:(id<AFNetworkActivityLoggerProtocol>)logger {
    [self.mutableLoggers removeObject:logger];
}

- (void)startLogging {
    [self stopLogging];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidResumeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

static void * AFNetworkRequestStartDate = &AFNetworkRequestStartDate;

- (void)networkRequestDidStart:(NSNotification *)notification {
    NSURLSessionTask *task = [notification object];
    NSURLRequest *request = task.originalRequest;
    NSError *error = AFNetworkErrorFromNotification(notification);

    if (!request) {
        return;
    }

    objc_setAssociatedObject(notification.object, AFNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

//    for (id <AFNetworkActivityLoggerProtocol> logger in self.loggers) {
//        if (request && logger.filterPredicate && [logger.filterPredicate evaluateWithObject:request]) {
//            return;
//        }
//        [logger URLSessionTaskDidStart:task];
//    }
    
//    NSLog(@"[HTTPMethod: %@] [URL:'%@']", [request HTTPMethod], [[request URL] absoluteString]);
    NSTimeInterval elapsedTime = 0;
    NSInteger   netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    NSInteger   responseStatusCode =  200; //((NSHTTPURLResponse *)task.response).statusCode;
    NSString *  url = [[request URL] absoluteString];
    NSString * errorStr = error.description;
    NSString * requestSize = [NSString stringWithFormat:@"%ld",request.HTTPBody.length ];
    
    NSString * appInformation = [WAGUserAgent appInformation];

    NSString * logStr = [NSString stringWithFormat:@"S**************************[ResponseCode:%ld] [URL:'%@'] [ElapsedTime: %.04f s] [NetStatus:%ld] [Error: %@] operationId : %ld", (long)responseStatusCode, url, elapsedTime , netStatus ,errorStr, task.taskIdentifier];
    NSLog(@"%@",logStr);
    
    NSDictionary * dic = @{@"url":url?url:@"null",
                           @"responseCode":@(responseStatusCode).stringValue,
                           @"elapsedTime":@(elapsedTime).stringValue,
                           @"netStatus":@(netStatus).stringValue,
                           @"actionType":@(1).stringValue,
                           @"operationId": @(task.taskIdentifier).stringValue,
                           @"error": errorStr?errorStr:@"null",
                           @"appInfo": appInformation?appInformation : @"null",
                           @"requestSize":requestSize
                           };
    
//    [[LogHub sharedLogHub] postLogWithDic:dic withTopic:@"chat" andSource:@"ios" logStoreName:@"wag_ios"];
//     [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"net" callback:^(id data, int code, NSError *err) {
//         
//     }];
    [[PersistenceInstallation sharedPersistence].ldpb putSource:@"net" topic:@"chat" content:dic];


    
}

- (void)networkRequestDidFinish:(NSNotification *)notification {
    NSURLSessionTask *task = [notification object];
    NSURLRequest *request = task.originalRequest;
    NSURLResponse *response = task.response;
  
    NSError *error = AFNetworkErrorFromNotification(notification);

    if (!request && !response) {
        return;
    }

    id responseObject = nil;
    if (notification.userInfo) {
        responseObject = notification.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
    }

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, AFNetworkRequestStartDate)];

    
    NSInteger   netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    NSInteger   responseStatusCode =  ((NSHTTPURLResponse *)task.response).statusCode;
    NSString *  url = [[task.response URL] absoluteString];
    NSString * errorStr = error.description;
    NSString * requestSize = [NSString stringWithFormat:@"%ld",request.HTTPBody.length ];
    NSString * appInformation = [WAGUserAgent appInformation];
    NSString * logStr = [NSString stringWithFormat:@"R**************************[ResponseCode:%ld] [URL:'%@'] [ElapsedTime: %.04f s] [NetStatus:%ld] [Error: %@] operationId : %ld", (long)responseStatusCode, url, elapsedTime , netStatus ,errorStr, task.taskIdentifier];
    NSLog(@"%@",logStr);
 
    NSDictionary * dic = @{@"url":url?url:@"null",
                           @"responseCode":@(responseStatusCode).stringValue,
                           @"elapsedTime":@(elapsedTime).stringValue,
                           @"netStatus":@(netStatus).stringValue,
                           @"actionType":@(2).stringValue,
                           @"operationId": @(task.taskIdentifier).stringValue,
                           @"error": errorStr?errorStr:@"null",
                           @"appInfo": appInformation?appInformation : @"null",
                           @"requestSize":requestSize
                           };
 
//      [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"net" callback:^(id data, int code, NSError *err) {
//          
//      }] ;
    [[PersistenceInstallation sharedPersistence].ldpb putSource:@"net" topic:@"chat" content:dic];

    
//    [[LogHub sharedLogHub] postLogWithDic:dic withTopic:@"chat" andSource:@"ios" logStoreName:@"wag_ios"];
    
 }

@end
