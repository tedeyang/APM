//
//  WAGKSCrashDoctor.h
//  TestCrash
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WAGKSCrashDoctor : NSObject
+ (WAGKSCrashDoctor*) doctor;

- (NSString*) diagnoseCrash:(NSDictionary*) crashReport;

@end
