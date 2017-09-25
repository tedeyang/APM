//
//  PerformanceMonitor.m
//  SuperApp
//
//  Created by yanjing on 2017/9/16.
//  Copyright © 2017年 yj. All rights reserved.
//
#import "WAGUnsmoothMonitor.h"
//#import "PLCrashReporter.h"
//#import "PLCrashReport.h"
//#import "PLCrashReportTextFormatter.h"
#import "BSBacktraceLogger.h"
#import <mach/mach.h>
#import <QuartzCore/CADisplayLink.h>
#import "LogHub.h"
#import "WAGUserAgent.h"
#import "PersistenceInstallation.h"

@interface WAGUnsmoothMonitor ()
{
    int timeoutCount;
    CFRunLoopObserverRef observer;
    
    @public
    dispatch_semaphore_t semaphore;
    CFRunLoopActivity activity;
}

 @property(nonatomic, strong) CADisplayLink* link;
 @property(nonatomic, assign) NSUInteger count;
 @property(nonatomic, assign) NSTimeInterval lastTime;
 @property(nonatomic, assign) NSTimeInterval llll;
 @end

@implementation WAGUnsmoothMonitor

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    WAGUnsmoothMonitor *moniotr = (__bridge WAGUnsmoothMonitor*)info;
    
    moniotr->activity = activity;
    
    dispatch_semaphore_t semaphore = moniotr->semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)stop
{
    if (!observer)
        return;
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    observer = NULL;
}
- (void)startCPM{
    
    dispatch_async(dispatch_get_main_queue(),^{
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    });
}

- (void)tick:(CADisplayLink*)link
{
    if (self.lastTime == 0) {
        self.lastTime = link.timestamp;
        return;
    }
    
    self.count++;
    NSTimeInterval delta = link.timestamp - self.lastTime;
    if (delta < 1)
        return;
    self.lastTime = link.timestamp;
    float fps = self.count / delta;
    self.count = 0;
    
    float cpuValue = [WAGUnsmoothMonitor cpuUsage];
    long fpsValue = (int)round(fps);
    float  momeryValue = [WAGUnsmoothMonitor usedMemoryInMB] /3.0;
    
    //    CGFloat progress = fps / 60.0;
    //    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    //    UIColor *color = [UIColor redColor];
    
    NSString * CGMData =  [NSString stringWithFormat:@"%ld %.1f%% %.1f", fpsValue,cpuValue,momeryValue];
    NSLog(@"%@",CGMData);
 
    // [[WAGAPMHandler sharedInstance] updateAPMValue:cpuValue fps:fpsValue mm:momeryValue];
    if (cpuValue > 80 || momeryValue  > 200 || fpsValue < 30) {
        
        NSString *report =  [BSBacktraceLogger bs_backtraceOfMainThread];
        NSDictionary * dic = @{
                               @"stack":report?report:@"null",
                               @"cpu": [NSString stringWithFormat: @"%.1f" ,cpuValue ],
                               @"fps": [NSString stringWithFormat: @"%ld" ,fpsValue ],
                               @"mm": [NSString stringWithFormat: @"%.1f" ,momeryValue ],
                               @"appInfo": [WAGUserAgent appInformation]
                               
                               };
        
//        [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"gap" callback:^(id data, int code, NSError *err) {
//            
//        }];
        [[PersistenceInstallation sharedPersistence].ldpb putSource:@"net" topic:@"chat" content:dic];

    }
   
}

- (void)start
{
    if (observer)
        return;
    
    // 信号
    semaphore = dispatch_semaphore_create(0);
    
    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                       kCFRunLoopAllActivities,
                                       YES,
                                       0,
                                       &runLoopObserverCallBack,
                                       &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    // 在子线程监控时长
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES)
        {
            long st = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 50*NSEC_PER_MSEC));
            if (st != 0)
            {
                if (!observer)
                {
                    timeoutCount = 0;
                    semaphore = 0;
                    activity = 0;
                    return;
                }
                
                if (activity==kCFRunLoopBeforeSources || activity==kCFRunLoopAfterWaiting)
                {
                    if (++timeoutCount < 5){
                            continue;
                    }
                    NSString *report =  [BSBacktraceLogger bs_backtraceOfMainThread];
//                    PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD
//                                                                                       symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll];
//                    PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
//
//                    NSData *data = [crashReporter generateLiveReport];
//                    PLCrashReport *reporter = [[PLCrashReport alloc] initWithData:data error:NULL];
//                    NSString *report = [PLCrashReportTextFormatter stringValueForCrashReport:reporter
//                                                                              withTextFormat:PLCrashReportTextFormatiOS];
                    
                    float  cpuValue = [WAGUnsmoothMonitor cpuUsage];
                    long   fpsValue =  100;
                    float  momeryValue = [WAGUnsmoothMonitor usedMemoryInMB] /3.0 ;
                    
//                    NSString * CGMData =  [NSString stringWithFormat:@"%ld %.1f%% %.1f", fpsValue,cpuValue,momeryValue];

                    NSDictionary * dic = @{
                                           @"stack":report,
                                           @"cpu": [NSString stringWithFormat: @"%.1f" ,cpuValue ],
                                           @"fps": [NSString stringWithFormat: @"%ld" ,fpsValue ],
                                           @"mm": [NSString stringWithFormat: @"%.1f" ,momeryValue ],
                                           @"appInfo": [WAGUserAgent appInformation]

                                           };
                    
//                    [[PersistenceInstallation sharedPersistence].ldb putObject:dic Source:@"gap" callback:^(id data, int code, NSError *err) {
//                        
//                    }];
                     [[PersistenceInstallation sharedPersistence].ldpb putSource:@"net" topic:@"chat" content:dic];

//                    [[LogHub sharedLogHub] postLogWithDic:dic withTopic:@"chat" andSource:@"ios" logStoreName:@"wag_ios"];
                    
                    

                    NSLog(@"------------\n%@\n------------", report);
                }
            }
            timeoutCount = 0;
        }
    });
}

+ (float)usedMemoryInMB{
    vm_size_t memory = [self usedMemory];
    return memory / 1000.0 / 1000.0;
}

+ (vm_size_t) usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

+ (float)cpuUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

@end
