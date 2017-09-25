//
//  PersistenceHandler.h
//  WAGChat
//
//  Created by yanjing on 2017/9/19.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WAGLevelDB.h"
#import "LogDataProvider.h"
#import "ApmLog.h"
@interface PersistenceInstallation : NSObject

@property(nonatomic , strong) WAGLevelDB * ldb;
@property(nonatomic , strong) LogDataProvider * ldpb;
+ (instancetype)sharedPersistence;

@end
