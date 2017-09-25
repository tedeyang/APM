//
//  WAGAPMInstallation.m
//  WAGChat
//
//  Created by yanjing on 2017/9/17.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "WAGAPMInstallation.h"
#import "WAGKSCrashInstallation.h"
//#import "LogHubInstallation.h"
#import <KSCrash.h>
//#import "KSCrashInstallation+APM.h"
#import "WAGUnsmoothMonitor.h"
//#import "WAGUserAgent.h"
//#import "PersistenceInstallation.h"
//#import "LogHub.h"

@implementation WAGAPMInstallation

+ (WAGAPMInstallation*)apmInstallation
{
    return [(WAGAPMInstallation*)[self alloc] init];
}

-(void)startAPM{
    
//    [[LogHubInstallation managerInstance] install];
    [[WAGUnsmoothMonitor sharedInstance] start];
    [[WAGUnsmoothMonitor sharedInstance] startCPM];
    [self installCrashHandler];
    

}





- (void) installCrashHandler
{
   
    WAGKSCrashInstallation* installation  = [WAGKSCrashInstallation sharedInstance];

    [installation install];
    [KSCrash sharedInstance].deleteBehaviorAfterSendAll = KSCDeleteOnSucess; // TODO: Remove this
    
    [installation sendAllReportsToLogHub];
    
//    [installation sendAllReportsToLogHubWithCompletion:^(NSArray* reports, BOOL completed, NSError* error)
//     {
//         //         NSString *result = [[NSString alloc] initWithData:reports[0]  encoding:NSUTF8StringEncoding];
//         
//         if(completed)
//         {
//             NSLog(@"Sent %d reports", (int)[reports count]);
//             float  cpuValue = [WAGUnsmoothMonitor cpuUsage];
//             long   fpsValue =  100;
//             float  momeryValue = [WAGUnsmoothMonitor usedMemoryInMB]/3.0;
//             NSString  * info = [WAGUserAgent appInformation];
//             
//             //                    NSString * CGMData =  [NSString stringWithFormat:@"%ld %.1f%% %.1f", fpsValue,cpuValue,momeryValue];
//             for (NSString * report  in reports) {
//                 if ([report isKindOfClass: [NSString class]]) {
//                     NSDictionary * dic = @{
//                                            @"stack":report?report:@"null",
//                                            @"cpu": [NSString stringWithFormat: @"%.1f" ,cpuValue ],
//                                            @"fps": [NSString stringWithFormat: @"%ld" ,fpsValue ],
//                                            @"mm": [NSString stringWithFormat: @"%.1f" ,momeryValue ],
//                                            @"appInfo": info?info:@"null"
//                                            };
//                     [[PersistenceInstallation sharedPersistence].ldpb putSource:@"net" topic:@"chat" content:dic];
//
////                     [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"gap" callback:^(id data, int code, NSError *err) {
////                         
////                     }];
//                     
//
//
////                     [[LogHub sharedLogHub] postLogWithDic:dic withTopic:@"chat" andSource:@"ios" logStoreName:@"wag_ios"];
// 
//                 }
//                 
//                 
//             }
//      
//         }
//         else
//         {
//             NSLog(@"Failed to send reports: %@", error);
//         }
//     }];
    

    
}


@end
