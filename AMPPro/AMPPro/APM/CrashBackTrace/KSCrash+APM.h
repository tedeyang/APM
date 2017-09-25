//
//  KSCrash+Apm.h
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <KSCrash/KSCrash.h>

@interface KSCrash (APM)
- (void) sendAllReportsToLogHubWithCompletion:(KSCrashReportFilterCompletion) onCompletion;
 

@end
