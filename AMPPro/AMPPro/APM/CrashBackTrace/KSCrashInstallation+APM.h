//
//  KSCrashInstallation+Apm.h
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <KSCrash/KSCrashInstallation.h>

@interface KSCrashInstallation (APM)
- (void) sendAllReportsTologHubWithCompletion:(KSCrashReportFilterCompletion) onCompletion;
@end
