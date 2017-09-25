//
//  WAGKSCrashInstallation.h
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <KSCrash/KSCrashInstallation.h>

@interface WAGKSCrashInstallation : KSCrashInstallation

+ (instancetype) sharedInstance;

- (void) sendAllReportsToLogHubWithCompletion:(KSCrashReportFilterCompletion) onCompletion;

- (void) sendAllReportsToLogHub;

@end
