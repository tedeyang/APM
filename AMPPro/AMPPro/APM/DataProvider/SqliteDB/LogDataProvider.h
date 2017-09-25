//
//  LogDataProvider.h
//  WAGChat
//
//  Created by yanjing on 2017/9/20.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ResultCallbackWithParams) (id data,int code, NSError* err);

@interface LogDataProvider : NSObject

+ (instancetype)dbWithPath:(NSString *)filePath;

- (BOOL)putSource:(NSString *)source  topic:(NSString *)topic content:(id )content;

- (void)getLogsWithCallback:(ResultCallbackWithParams)callback;
- (void)removeValueWithCallback:(ResultCallbackWithParams)callback;
- (void)removeValueForKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback;

@end
