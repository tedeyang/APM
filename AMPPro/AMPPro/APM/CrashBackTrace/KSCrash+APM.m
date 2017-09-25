//
//  KSCrash+LogHub.m
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "KSCrash+APM.h"

#import <KSCrash/KSCrashC.h> // TODO: Remove this
//#import <KSCrash/KSCrashDoctor.h> // TODO: Remove this
//#import <KSCrash/KSCrashReportFields.h> // TODO: Remove this
//#import <KSCrash/KSCrashC.h> // TODO: Remove this
//
//#import "KSCrashDoctor.h"
//#import "KSCrashReportFields.h"
//#import "KSCrashMonitor_AppState.h"
//#import "KSJSONCodecObjC.h"
//#import "NSError+SimpleConstructor.h"
//#import "KSCrashMonitorContext.h"
//#import "KSCrashMonitor_System.h"
#import <KSCrash/KSCrashReportFilter.h>

#import <KSCrash/KSJSONCodecObjC.h>
#import "WAGKSCrashDoctor.h"
#import "WAGKSCrashMarcos.h"

@implementation KSCrash (Apm)

- (void) sendAllReportsToLogHubWithCompletion:(KSCrashReportFilterCompletion) onCompletion
{
    
    NSArray* reports = [self allReports_wag];

    NSLog(@"Sending %ld crash reports to loghub", [reports count]);

    [self sendReports:reports
         onCompletion:^(NSArray* filteredReports, BOOL completed, NSError* error)
     {
         NSLog(@"Process finished with completion: %d", completed);
         if(error != nil)
         {
             NSLog(@"Failed to send reports: %@", error);
         }
         if((self.deleteBehaviorAfterSendAll == KSCDeleteOnSucess) ||
            self.deleteBehaviorAfterSendAll == KSCDeleteAlways)
         {
             kscrash_deleteAllReports();
         }
         kscrash_callCompletion(onCompletion, filteredReports, completed, error);
     }];
}

- (void) sendReports:(NSArray*) reports onCompletion:(KSCrashReportFilterCompletion) onCompletion
{
    if([reports count] == 0)
    {
        kscrash_callCompletion(onCompletion, reports, YES, nil);
        return;
    }
    
    if(self.sink == nil)
    {
        kscrash_callCompletion(onCompletion, reports, NO,
                               [NSError errorWithDomain:[[self class] description] code:0  userInfo:nil]);
        return;
    }
    
    [self.sink filterReports:reports
                onCompletion:^(NSArray* filteredReports, BOOL completed, NSError* error)
     {
         kscrash_callCompletion(onCompletion, filteredReports, completed, error);
     }];
}


- (NSData*) loadCrashReportJSONWithID:(int64_t) reportID
{
    char* report = kscrash_readReport(reportID);
    if(report != NULL)
    {
        return [NSData dataWithBytesNoCopy:report length:strlen(report) freeWhenDone:YES];
    }
    return nil;
}

- (void) doctorReport:(NSMutableDictionary*) report
{
    NSMutableDictionary* crashReport = report[@KSCrashField_Crash];
    if(crashReport != nil)
    {
        crashReport[@KSCrashField_Diagnosis] = [[WAGKSCrashDoctor doctor] diagnoseCrash:report];
    }
    crashReport = report[@KSCrashField_RecrashReport][@KSCrashField_Crash];
    if(crashReport != nil)
    {
        crashReport[@KSCrashField_Diagnosis] = [[WAGKSCrashDoctor doctor] diagnoseCrash:report];
    }
}


- (NSDictionary*) reportWithID:(int64_t) reportID
{
    NSData* jsonData = [self loadCrashReportJSONWithID:reportID];
    if(jsonData == nil)
    {
        return nil;
    }
    
    NSError* error = nil;
    NSMutableDictionary* crashReport = [KSJSONCodec decode:jsonData
                                                   options:KSJSONDecodeOptionIgnoreNullInArray |
                                        KSJSONDecodeOptionIgnoreNullInObject |
                                        KSJSONDecodeOptionKeepPartialObject
                                                     error:&error];
    if(error != nil)
    {
//        KSLOG_ERROR(@"Encountered error loading crash report %" PRIx64 ": %@", reportID, error);
    }
    if(crashReport == nil)
    {
//        KSLOG_ERROR(@"Could not load crash report");
        return nil;
    }
    [self doctorReport:crashReport];
    
    return crashReport;
}

- (NSArray*) allReports_wag
{
    int reportCount = kscrash_getReportCount();
    int64_t reportIDs[reportCount];
    reportCount = kscrash_getReportIDs(reportIDs, reportCount);
    NSMutableArray* reports = [NSMutableArray arrayWithCapacity:(NSUInteger)reportCount];
    for(int i = 0; i < reportCount; i++)
    {
        NSDictionary* report = [self reportWithID:reportIDs[i]];
        if(report != nil)
        {
            [reports addObject:report];
        }
    }
    
    return reports;
}

@end
