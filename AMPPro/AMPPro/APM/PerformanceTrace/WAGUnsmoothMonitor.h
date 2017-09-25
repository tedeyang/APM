//
//  PerformanceMonitor.h
//  SuperApp
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface WAGUnsmoothMonitor : NSObject

+ (instancetype)sharedInstance;

- (void)start;
- (void)startCPM;

- (void)stop;
- (void)stopCPM;


+ (float)usedMemoryInMB;

+ (vm_size_t) usedMemory ;

+ (float)cpuUsage;
@end
