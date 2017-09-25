//
//  LogHub.h
//  WAGChat
//
//  Created by yanjing on 2017/9/4.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import <Foundation/Foundation.h>
 
@class Log;

@interface LogHub : NSObject


+ (instancetype)sharedLogHub;

//    projectName 类似于 数据库名；
//    endpoint 类似是 projectName + 域名；
//    accessKeyID： 阿里云提供；
//    accessKeySecret阿里云提供；
//    content 为 log 内容
//    key 为 log  key
//    topic 为 log 类型 的标记 ，例如，汽车分为： 货车，装甲车，救护车，警车。
//    source 可以理解为：log 的来源的标记 ，比如 ： 买家，卖家，管家。
//    logStoreName 可以理解为 数据库中 一个表的表名

-(void)createLoghubClient:(NSString*) endPoint accessKeyID:(NSString *)ak accessKeySecret: (NSString *)as projectName: (NSString *)name;

- (void)postLogContent:(NSString*)content  // log 内容
               withKey:(NSString*)key      // log  key
             withTopic:(NSString*)topic     // log 类型 的标记 ，例如，汽车分为： 货车，装甲车，救护车，警车。
             andSource:(NSString*)source    // 可以理解为：log 的来源的标记 ，比如 ： 买家，卖家，管家。
          logStoreName:(NSString*)name ;     // 可以理解为 数据库中 一个表的表名



- (void)postLog:(NSArray<Log *> *)logs
      withTopic:(NSString*)topic
      andSource:(NSString*)source
   logStoreName:(NSString*)name;


- (void)postLogWithDic:(NSDictionary *)logs
             withTopic:(NSString*)topic
             andSource:(NSString*)source
          logStoreName:(NSString*)name;

- (void)postLogWithInfo:(NSArray *)netInfos
              withTopic:(NSString*)topic
              andSource:(NSString*)source
           logStoreName:(NSString*)name
               callback:(void (^)(int res, NSError* _Nullable error) )errorCallback;


@end
