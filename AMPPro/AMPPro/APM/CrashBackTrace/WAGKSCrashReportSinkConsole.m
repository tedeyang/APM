//
//  KSCrashReportSinkConsole.m
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "WAGKSCrashReportSinkConsole.h"
#import "KSCrashReportFilterAppleFmt.h"
#import "KSCrashReportFilterBasic.h"

@implementation WAGKSCrashReportSinkConsole

+ (WAGKSCrashReportSinkConsole*) filter
{
    return [[self alloc] init];
}

- (id <KSCrashReportFilter>) defaultCrashReportFilterSet
{
    return [KSCrashReportFilterPipeline filterWithFilters:
            [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicated],
            self,
            nil];
}

- (void) filterReports:(NSArray*) reports
          onCompletion:(KSCrashReportFilterCompletion) onCompletion
{
    int i = 0;
    for(NSString* report in reports)
    {
        printf("Report %d:\n%s\n", ++i, report.UTF8String);
    }
    
    kscrash_callCompletion(onCompletion, reports, YES, nil);
}
@end
