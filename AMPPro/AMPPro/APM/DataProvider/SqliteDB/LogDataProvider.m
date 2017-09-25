//
//  LogDataProvider.m
//  WAGChat
//
//  Created by yanjing on 2017/9/20.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "LogDataProvider.h"
#import <FMDB/FMDB.h>
#import "ApmLog.h"

@interface LogDataProvider ()
@property(nonatomic, strong) FMDatabaseQueue *dbQueue;
@end




@implementation LogDataProvider

+ (instancetype)dbWithPath:(NSString *)filePath
{
    LogDataProvider *kv = [LogDataProvider new];
    kv.dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [kv setupDatabase];
    return kv;
}

- (void)setupDatabase
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS apmlog( SID integer NOT NULL PRIMARY KEY autoincrement , source text , topic text  content text );";
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db open];
        [db executeStatements:sql];
        [db close];

    }];
    
}
 

- (BOOL)putSource:(NSString *)source  topic:(NSString *)topic content:(id )content
{
    NSString *value = nil;
    if ([NSJSONSerialization isValidJSONObject:content]) {
        NSError *error = nil;
        value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:content options:0 error:&error] encoding:NSUTF8StringEncoding];
        if (error) {
            NSLog(@"error == %@",error.description);
        }
    }

    
    NSString *sql = @"INSERT OR REPLACE INTO apmlog (source, topic, content) VALUES (?, ?, ?)";
    __block BOOL success = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];

        success = [db executeUpdate:sql, source?:@"",topic?:@"",value?:@""];
        if (!success) {
            NSLog(@"putString error = %@", [db lastErrorMessage]);
        }
        [db close];

    }];
    return success;
}

- (void)getLogsWithCallback:(ResultCallbackWithParams)callback
{
   
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];

        ApmLog * log = [[ApmLog alloc]init];
        NSMutableArray * att =  [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"select * from apmlog"];
        
        while([rs next]) {
          log.source = [rs stringForColumn:@"source"];
          log.topic = [rs stringForColumn:@"topic"];
          NSString *  content = [rs stringForColumn:@"content"];
          
            id ret = nil;
            if (content.length > 0) {
                NSError *error = nil;
                 ret = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    NSLog(@"error == %@",error.description);
                }
            }
            log = ret;
            [att addObject:log];

        }
        [rs close];
        [db close];
        
        if (callback) {
            callback(att,1,nil);
        }
        
        
        
    }];
 }

- (void)removeValueWithCallback:(ResultCallbackWithParams)callback
{
    
      [self.dbQueue inDatabase:^(FMDatabase *db) {
          [db open];

          BOOL rs = [db executeUpdate:@"delete * from apmlog"];
          [db close];
          
          if (callback ) {
              callback(nil , rs, nil);
          }
      }];
    
}

- (void)removeValueForKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        
        BOOL rs = [db executeUpdate:@"delete * from apmlog where source = ?",aKey];
        [db close];
        
        if (callback ) {
            callback(nil , rs, nil);
        }
    }];
    
}


//- (BOOL)putDictionary:(NSDictionary *)data forKey:(NSString *)key
//{
//    return [self putObject:data forKey:key toCategory:0];
//}
//
//- (NSDictionary *)getDictionaryWithKey:(NSString *)key
//{
//    return [self getObjectWithKey:key fromCategory:0];
//}

- (void)dealloc
{
    [self.dbQueue close];
}

@end
