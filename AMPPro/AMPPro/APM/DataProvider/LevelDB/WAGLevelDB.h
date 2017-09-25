//
//  WAGlevelDB.h
//  TestLevelDB
//
//  Created by yanjing on 2017/7/10.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ResultCallbackWithParams) (id data,int code, NSError* err);



@interface WAGLevelDB : NSObject
+ (WAGLevelDB *)levelDBWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

//Getting Default Values
- (BOOL)boolForKey:(NSString *)aKey;
- (double)floatForKey:(NSString *)aKey;
- (NSInteger)intForKey:(NSString *)aKey;
- (NSString *)stringForKey:(NSString *)aKey;
- (NSData *)dataForKey:(NSString *)aKey;
- (id)objectForKey:(NSString *)aKey;

- (void)stringForKey:(NSString *)aKey  callback:(ResultCallbackWithParams)callback;
- (void)dataForKey:(NSString *)aKey  callback:(ResultCallbackWithParams)callback;
- (void)objectForKey:(NSString *)aKey  callback:(ResultCallbackWithParams)callback;

//Setting Default Values
- (BOOL)putBool:(BOOL)value forKey:(NSString *)aKey;
- (BOOL)putInt:(NSInteger)value forKey:(NSString *)aKey;
- (BOOL)putFloat:(double)value forKey:(NSString *)aKey;

- (void)putString:(NSString *)value forKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback;
- (void)putData:(NSData *)value forKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback;
- (void)putObject:(id)value forKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback;

- (void)putString:(NSString *)value callback:(ResultCallbackWithParams)callback;
- (void)putData:(NSData *)value callback:(ResultCallbackWithParams)callback;
- (void)putObject:(id)value callback:(ResultCallbackWithParams)callback;
- (void)putObject:(id)value Source:(NSString *)source callback:(ResultCallbackWithParams)callback;



- (BOOL)removeValueForKey:(NSString *)aKey;
- (void)removeValueForKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback;
- (NSArray *)allKeys;

- (void)allKeysCallback:(ResultCallbackWithParams)callback;


- (void)enumerateKeys:(void (^)(NSString *key, BOOL *stop))block;

- (BOOL)clear;
- (BOOL)deleteDB;


@end
