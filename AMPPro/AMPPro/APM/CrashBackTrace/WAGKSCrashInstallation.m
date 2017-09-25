//
//  WAGKSCrashInstallation.m
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "WAGKSCrashInstallation.h"
#import "KSCrashInstallation+Private.h"
#import "KSCrashReportSinkStandard.h"
#import "KSCrashReportFilterBasic.h"
#import "KSCrashReportSinkEMail.h"
#import "KSCrashReportFilterAppleFmt.h"
#import "KSCrashReportSinkConsole.h"
#import "WAGKSCrashReportSinkConsole.h"
#import <KSCrash/KSCrash.h> // TODO: Remove this
#import "KSCrash+APM.h"

#import "WAGUnsmoothMonitor.h"
#import "WAGUserAgent.h"
#import "PersistenceInstallation.h"
#import "LogHub.h"

@implementation WAGKSCrashInstallation

+ (instancetype) sharedInstance
{
    static WAGKSCrashInstallation *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WAGKSCrashInstallation alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
 
    return [super initWithRequiredProperties:[NSArray arrayWithObjects: @"url", nil]];

}

- (id<KSCrashReportFilter>) sink
{
    WAGKSCrashReportSinkConsole * sink = [WAGKSCrashReportSinkConsole filter];
    
//    return [KSCrashReportFilterPipeline filterWithFilters:[sink defaultCrashReportFilterSet], nil];
    return  [sink defaultCrashReportFilterSet] ;

}

- (NSError*) validateProperties
{
    //    NSMutableString* errors = [NSMutableString string];
    //    for(NSString* propertyName in self.requiredProperties)
    //    {
    //        NSString* nextError = nil;
    //        @try
    //        {
    //            id value = [self valueForKey:propertyName];
    //            if(value == nil)
    //            {
    //                nextError = @"is nil";
    //            }
    //        }
    //        @catch (NSException *exception)
    //        {
    //            nextError = @"property not found";
    //        }
    //        if(nextError != nil)
    //        {
    //            if([errors length] > 0)
    //            {
    //                [errors appendString:@", "];
    //            }
    //            [errors appendFormat:@"%@ (%@)", propertyName, nextError];
    //        }
    //    }
    //    if([errors length] > 0)
    //    {
    //
    //       return [NSError errorWithDomain:[[self class] description] code:0 userInfo:nil];
    ////        return [NSError errorWithDomain:[[self class] description]
    ////                                   code:0
    ////                            description:@"Installation properties failed validation: %@", errors];
    //    }
    return nil;
}
- (void) sendAllReportsToLogHubWithCompletion:(KSCrashReportFilterCompletion) onCompletion
{
 
    NSError* error = [self validateProperties];
    if(error != nil)
    {
        if(onCompletion != nil)
        {
            onCompletion(nil, NO, error);
        }
        return;
    }
    
    id<KSCrashReportFilter> sink = [self sink];
    if(sink == nil)
    {
        onCompletion(nil, NO, [NSError errorWithDomain:[[self class] description] code:0 userInfo:nil]);
        return;
    }
    
    //    sink = [KSCrashReportFilterPipeline filterWithFilters:nil, sink, nil];
    
    KSCrash* handler = [KSCrash sharedInstance];
    
    handler.sink = sink;
    
    [handler sendAllReportsToLogHubWithCompletion:onCompletion];
}

- (void) sendAllReportsToLogHub
{
    void (^ completionCallback)(NSArray* filteredReports, BOOL completed, NSError* error) = ^(NSArray* reports, BOOL completed, NSError* error){
        
        if(completed)
        {
            NSLog(@"Sent %d reports", (int)[reports count]);
            float  cpuValue = [WAGUnsmoothMonitor cpuUsage];
            long   fpsValue =  100;
            float  momeryValue = [WAGUnsmoothMonitor usedMemoryInMB]/3.0;
            NSString  * info = [WAGUserAgent appInformation];
            
            //                    NSString * CGMData =  [NSString stringWithFormat:@"%ld %.1f%% %.1f", fpsValue,cpuValue,momeryValue];
            for (NSString * report  in reports) {
                if ([report isKindOfClass: [NSString class]]) {
                    NSDictionary * dic = @{
                                           @"stack":report?report:@"null",
                                           @"cpu": [NSString stringWithFormat: @"%.1f" ,cpuValue ],
                                           @"fps": [NSString stringWithFormat: @"%ld" ,fpsValue ],
                                           @"mm": [NSString stringWithFormat: @"%.1f" ,momeryValue ],
                                           @"appInfo": info?info:@"null"
                                           };
                    [[PersistenceInstallation sharedPersistence].ldpb putSource:@"net" topic:@"chat" content:dic];
                    
                    //                     [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"gap" callback:^(id data, int code, NSError *err) {
                    //
                    //                     }];
                    
                    //                     [[LogHub sharedLogHub] postLogWithDic:dic withTopic:@"chat" andSource:@"ios" logStoreName:@"wag_ios"];
                    
                }
                
            }
            
        }
        else
        {
            NSLog(@"Failed to send reports: %@", error);
        }
        
    };
    
    NSError* error = [self validateProperties];
    if(error != nil)
    {
        if(completionCallback != nil)
        {
            completionCallback(nil, NO, error);
        }
        return;
    }
    
    id<KSCrashReportFilter> sink = [self sink];
    if(sink == nil)
    {
        completionCallback(nil, NO, [NSError errorWithDomain:[[self class] description] code:0 userInfo:nil]);
        return;
    }
    
    //    sink = [KSCrashReportFilterPipeline filterWithFilters:nil, sink, nil];
    
    KSCrash* handler = [KSCrash sharedInstance];
    
    handler.sink = sink;
    
    [handler sendAllReportsToLogHubWithCompletion:completionCallback];
}


- (void) addPreFilter:(id<KSCrashReportFilter>) filter
{
    //    [self.prependedFilters addFilter:filter];
}



@end
