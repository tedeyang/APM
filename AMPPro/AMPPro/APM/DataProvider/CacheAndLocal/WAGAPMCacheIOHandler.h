//
//  WAGPerformanceTesting.h
//  TestLevelDB
//
//  Created by yanjing on 2017/7/17.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUsingAPM  0


@interface WAGAPMCacheIOHandler : NSObject

@property(nonatomic, assign) long  fpsValue;
@property(nonatomic, assign) float momeryValue;
@property(nonatomic, assign) float cpuValue;
@property(nonatomic, strong) NSString * modelName;

+ (instancetype)sharedInstance ;

+ (instancetype)PfTestingWithPath:(NSString *)filePath;

- (void)appendDataCache:(NSData *)content;

- (void)appendStrCache:(NSString *)strC;

-(NSString *)formatDateTime:(NSDate*)_timestamp;

-(void)updateAPMValue:(float)cpu fps:(long)fps mm:(float)momery;

-(void)fetchAPMWtihModelName:(NSString*) modelName;

@end
