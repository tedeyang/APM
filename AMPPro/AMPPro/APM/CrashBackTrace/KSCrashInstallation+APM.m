//
//  KSCrashInstallation+LogHub.m
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "KSCrashInstallation+APM.h"
#import <KSCrash/KSCrash.h> // TODO: Remove this
#import "KSCrashReportFilterBasic.h"
#import "KSCrash+APM.h"


@implementation KSCrashInstallation (APM)
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
- (void) sendAllReportsTologHubWithCompletion:(KSCrashReportFilterCompletion) onCompletion
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

- (void) addPreFilter:(id<KSCrashReportFilter>) filter
{
//    [self.prependedFilters addFilter:filter];
}

- (id<KSCrashReportFilter>) sink
{
    return nil;
}



@end
