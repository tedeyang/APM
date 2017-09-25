//
//  WAGPerformanceTesting.m
//  TestLevelDB
//
//  Created by yanjing on 2017/7/17.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "WAGAPMCacheIOHandler.h"
#include <os/lock.h>
#include <pthread/pthread.h>
//#import "CocoaLumberjack.h"

static WAGAPMCacheIOHandler *sharedInstance = nil;

@interface WAGAPMCacheIOHandler (){
    pthread_mutex_t unfairLock; // 自旋锁
    pthread_rwlock_t rwlock; // 文件读写锁
    
}
@property(nonatomic, strong) dispatch_queue_t  cvsQueue;
@property(nonatomic, strong) NSString *filePath;
@property(strong) NSDate* startRecodeDate;
@property(strong) NSDate* startWriteDate;

@property(assign) NSTimeInterval writeFilemaxInterval;
@property(assign) NSTimeInterval fetchDataSampleInterval;


//@property(nonatomic, strong) NSMutableArray * cacheArray;
@property NSMutableData *cacheData;


@end


@implementation WAGAPMCacheIOHandler


+ (instancetype)PfTestingWithPath:(NSString *)filePath
{
    WAGAPMCacheIOHandler *PTest = [[WAGAPMCacheIOHandler alloc]init];
    PTest.filePath = filePath;
    [PTest createFile];
    return PTest;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _cacheData = [NSMutableData data];
        _startRecodeDate = [NSDate date];
        _startWriteDate =  [NSDate date];
        _writeFilemaxInterval = 15.0;
        _fetchDataSampleInterval = 10.0;
        _modelName = @"not setting";
        //    PTest->unfairLock = &(OS_UNFAIR_LOCK_INIT);
        pthread_mutex_init(&(unfairLock),NULL);
        pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
        rwlock = lock;
        [self createFile];
        _cvsQueue  = dispatch_queue_create("cvsQueue", nil);
    }
    
    return self;
}

-(void)doTimeoutFlush{
    NSDate* dateNow = [NSDate date];
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceDate:self.startWriteDate];
    if (timeInterval > self.writeFilemaxInterval){
        self.startWriteDate = dateNow;
        
        [self flushLog];
    }
}
//强制写日志
- (void)flushLog
{
    NSMutableData* contentData = nil;
    
    //    os_unfair_lock_lock(unfairLock);
    //    @synchronized(self.cacheData) {
    pthread_mutex_lock(&unfairLock);
    if (self.cacheData.length == 0)
    {
        NSLog(@"______cacheData null ");
    }else{
        contentData = [self.cacheData copy];
        [self.cacheData setLength:0];
        NSLog(@"______cacheData write file finish ");
        
    }
    
    
    //    }
    //    os_unfair_lock_unlock(unfairLock);
    pthread_mutex_unlock(&unfairLock);
    
    [self appendDataToCvsFile:contentData];
}

-(void)fetchAPMWtihModelName:(NSString*) modelName{
    
    //    NSUInteger dotLocation = [modelName rangeOfString:@"." options:NSBackwardsSearch].location;
    //    if (dotLocation != NSNotFound)
    //    {
    //        modelName = [modelName substringToIndex:dotLocation];
    //    }
    
    self.modelName = modelName;
    //    NSString * CGMCVSData = [NSString stringWithFormat:@"%@,%ld,%.1f%%,%.1f\r\n",self.modelName, self.fpsValue,self.cpuValue, self.momeryValue];
    //
    //    [self appendStrCache:CGMCVSData];
}

-(void)updateAPMValue:(float)cpu fps:(long)fps mm:(float)momery{
    
#ifndef kUsingAPM
    
    
    NSDate* dateNow = [NSDate date];
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceDate:self.startRecodeDate];
    if (timeInterval >= self.fetchDataSampleInterval){
        self.startRecodeDate = dateNow;
        self.cpuValue = cpu;
        self.fpsValue = fps;
        self.momeryValue = momery/3.0 + 5; //
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(self.cvsQueue, ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                pthread_mutex_lock(&unfairLock);
                NSString * dateS = [strongSelf formatDateTime:dateNow];
                NSString * CGMCVSData = [NSString stringWithFormat:@"%@,%@,%ld,%.1f%%,%.1f\r\n",dateS,strongSelf.modelName, strongSelf.fpsValue,strongSelf.cpuValue, strongSelf.momeryValue];
                pthread_mutex_unlock(&unfairLock);
                
                [strongSelf appendStrCache:CGMCVSData];
                
            }
        });
        
        
    }
    
#endif
    
}

-(void)appendStrCache:(NSString *)strC{
    
    
    //    NSDate* dateNow = [NSDate date];
    //    NSTimeInterval timeInterval = [dateNow timeIntervalSinceDate:self.startRecodeDate];
    //    if (timeInterval >= self.fetchDataSampleInterval){
    //        self.startRecodeDate = dateNow;
    //
    //        if (0 == strC.length ) {
    //            return;
    //        }
    //    __weak typeof(self) weakSelf = self;
    //    dispatch_async(self.cvsQueue, ^{
    //        __strong typeof(weakSelf) strongSelf = weakSelf;
    //        if (strongSelf) {
    //                NSString * tmpStr = [NSString stringWithFormat:@"%@ ",dateS,strC];
    //                NSLog(@"___ %@", tmpStr);
    NSData * tmp = [strC dataUsingEncoding:NSUTF8StringEncoding];
    [self appendDataCache:tmp];
    //        }
    //
    //    });
    //     }
    
}

- (unsigned long long)fileSize
{
    // 总大小
    unsigned long long size = 0;
    //    NSString *sizeText = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exist = [manager fileExistsAtPath:self.filePath isDirectory:&isDir];
    
    // 判断路径是否存在
    if (!exist)
    {
        return size;
    }
    
    if (isDir) { // 是文件夹
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:self.filePath];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [self.filePath stringByAppendingPathComponent:subPath];
            size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
        }
    }else{ // 是文件
        size += [manager attributesOfItemAtPath:self.filePath error:nil].fileSize;
    }
    return size;
}

-(void)appendDataCache:(NSData *)content
{
    
    pthread_mutex_lock(&unfairLock);
    
    //    os_unfair_lock_lock(unfairLock);
    //    @synchronized(self.cacheData) {
    //        [self.cacheData appendData:dataLen];
    [self.cacheData appendData:content];
    //    }
    //    os_unfair_lock_unlock(unfairLock);
    pthread_mutex_unlock(&unfairLock);
    
    [self doTimeoutFlush];
}


- (void)appendDataToCvsFile:(NSMutableData *)cvsData{
    if (cvsData == nil) {
        return;
    }
    //    @synchronized(self){
    pthread_rwlock_wrlock(&rwlock);
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.filePath];
    //将节点调到文件末尾
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:cvsData];
    
    //    for(int i=0;i<6000;i++){
    //        NSString *str = @"某人的姓名,一个电话,一个地址,2017.02.20 11:30\n";
    //        str = [NSString stringWithFormat:@"%d%@",i,str];
    //        NSData *stringData = [str dataUsingEncoding:NSUTF8StringEncoding];
    //        //追加写入数据
    //        [fileHandle writeData:stringData];
    //    }
    
    [fileHandle closeFile];
    //    }
    pthread_rwlock_unlock(&rwlock);
    
    
}

-(BOOL)createFile{
    
    if (self.filePath.length == 0) {
        NSString *dbPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString * fileName = [self formatDateTime:[NSDate date]];
        fileName = [fileName stringByAppendingString:@".csv"];
        
        //        dbPath = [dbPath stringByAppendingPathComponent:@"APMData"];
        dbPath = [dbPath stringByAppendingPathComponent:fileName];
        self.filePath = dbPath;
    }
    
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath isDirectory:&isDirectory];
    if (!isExist) {
        //        NSError *error = nil;
        isExist = [[NSFileManager defaultManager]  createFileAtPath:self.filePath contents:nil attributes:nil];
        //        [[NSFileManager defaultManager] createFileAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (isExist) {
        NSString * title = @"DateTime,Model,FPS,CPU,Memory\r\n";
        NSData * contentTitleData = [title dataUsingEncoding:NSUTF8StringEncoding];
        [self appendDataCache:contentTitleData];
    }
    
    NSLog(@" -- %@",self.filePath);
    return  isExist;
}

-(NSString *)formatDateTime:(NSDate*)_timestamp{
    
    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:(NSCalendarUnitYear     |
                                                                                         NSCalendarUnitMonth    |
                                                                                         NSCalendarUnitDay      |
                                                                                         NSCalendarUnitHour     |
                                                                                         NSCalendarUnitMinute   |
                                                                                         NSCalendarUnitSecond)
                                                                               fromDate:_timestamp];
    
    NSTimeInterval epoch = [_timestamp timeIntervalSinceReferenceDate];
    int milliseconds = (int)((epoch - floor(epoch)) * 1000);
    
    // long len =
    char ts[24] = "";
    //    char * ts = malloc(24);
    
    snprintf(ts, 24, "%04ld%02ld%02ld%02ld:%02ld:%02ld:%03d", // yyyy-MM-dd HH:mm:ss:SSS
             (long)components.year,
             (long)components.month,
             (long)components.day,
             (long)components.hour,
             (long)components.minute,
             (long)components.second,
             milliseconds);
    //    char * dis = ts;
    
    return [NSString stringWithFormat:@"%s",ts];
    
}

-(void)dealloc{
    pthread_mutex_destroy(&unfairLock);
    pthread_rwlock_destroy(&rwlock);
}

@end
