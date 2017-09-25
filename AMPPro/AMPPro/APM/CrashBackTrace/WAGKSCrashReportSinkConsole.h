//
//  KSCrashReportSinkConsole.h
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSCrashReportFilter.h"

@interface WAGKSCrashReportSinkConsole : NSObject <KSCrashReportFilter>
+ (WAGKSCrashReportSinkConsole*) filter;

- (id <KSCrashReportFilter>) defaultCrashReportFilterSet;

- (void) filterReports:(NSArray*) reports
          onCompletion:(KSCrashReportFilterCompletion) onCompletion;

@end
