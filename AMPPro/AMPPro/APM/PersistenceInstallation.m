//
//  PersistenceHandler.m
//  WAGChat
//
//  Created by yanjing on 2017/9/19.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import "PersistenceInstallation.h"
 
@implementation PersistenceInstallation

+ (instancetype)sharedPersistence {
    
    static PersistenceInstallation *_shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    
    return _shared;
}


- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self install_sqlite]; //sqlite
//    [self install_ldb];  // leveldb

    return self;
}

-(void)install_sqlite{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"apm_data.db"];
    NSLog(@"dbPath:  %@",dbPath);
    self.ldpb = [LogDataProvider dbWithPath:dbPath];
    
 
}
-(void)install_ldb{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"apm_data.ldb"];
    NSLog(@"dbPath:  %@",dbPath);
    self.ldb = [WAGLevelDB levelDBWithPath:dbPath];
    
}
@end
