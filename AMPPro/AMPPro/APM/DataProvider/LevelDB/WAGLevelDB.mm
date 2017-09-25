//
//  WAGlevelDB.m
//  TestLevelDB
//
//  Created by yanjing on 2017/7/10.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "WAGLevelDB.h"
//#import <leveldb/db.h>
//#import <leveldb/options.h>
//#import <leveldb/write_batch.h>

#import <leveldb/db.h>
#import <leveldb/options.h>
#import <leveldb/write_batch.h>
#import "WAGCommonDefine.h"

@interface WAGLevelDB ()
{
    leveldb::DB *_db;
    leveldb::ReadOptions _readOptions;
    leveldb::WriteOptions _writeOptions;
    long long _squence;
    dispatch_queue_t _ldbQueue;
    NSString *_path;
}

@end

@implementation WAGLevelDB

NS_INLINE leveldb::Slice SliceByString(NSString *string)
{
    if (!string) return NULL;
    const char *cStr = [string UTF8String];
    size_t len = strlen(cStr);
    if (len == 0) return NULL;
    return leveldb::Slice(cStr,strlen(cStr));
}

NS_INLINE NSString *StringBySlice(const leveldb::Slice &slice)
{
    if (slice.empty()) return nil;
    const char *bytes = slice.data();
    const size_t len = slice.size();
    if (len == 0) return nil;
    return [[NSString alloc] initWithBytes:bytes length:len encoding:NSUTF8StringEncoding];
}

+ (WAGLevelDB *)levelDBWithPath:(NSString *)path
{
   WAGLevelDB * leveldb =  [[self alloc] initWithPath:path];
    return leveldb;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        _ldbQueue  = dispatch_queue_create("ldbQueue", DISPATCH_QUEUE_SERIAL);
        
        _path = path;
        leveldb::Options options;
        options.create_if_missing = true;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_path])
        {
            BOOL sucess = [[NSFileManager defaultManager] createDirectoryAtPath:_path
                                                    withIntermediateDirectories:YES
                                                                     attributes:NULL
                                                                          error:NULL];
            if (!sucess)
            {
                return nil;
            }
        }
        
        leveldb::Status status = leveldb::DB::Open(options, [_path fileSystemRepresentation], &_db);
        if (!status.ok())
        {
            return nil;
        }
        _squence = [self fetchSquence];

        _readOptions.fill_cache = true;
        _writeOptions.sync = true;
    }
    return self;
}

- (void)dealloc
{
    delete _db;
    _db = NULL;
}

#pragma mark -
#pragma mark Squence

- (BOOL)updateSquence
{
    return [self putString:[NSString stringWithFormat:@"squence_%lld",_squence] forKey:@"squence"];
}

- (NSInteger)fetchSquence
{
    NSString * squence =  [self stringForKey:@"squence"];
    NSInteger num = 0;
    if( [squence hasPrefix:@"squence_"]){
        
       NSRange  range = [squence rangeOfString:@"squence_"];
       NSUInteger  index = range.length;
       
       NSString *  nums = [squence substringFromIndex:index];
       num  = nums.integerValue;
    }
    
    return num;
}

#pragma mark -
#pragma mark Getting Default Values


- (BOOL)boolForKey:(NSString *)aKey
{
    return [[self stringForKey:aKey] boolValue];
}

- (double)floatForKey:(NSString *)aKey
{
    return [[self stringForKey:aKey] doubleValue];
}

- (NSInteger)intForKey:(NSString *)aKey
{
    return [[self stringForKey:aKey] integerValue];
}

- (NSString *)stringForKey:(NSString *)aKey
{
    if (!_db || !aKey){
        return nil;
    }
    
    leveldb::Slice sliceKey = SliceByString(aKey);
    std::string v_string;
    leveldb::Status status = _db->Get(_readOptions, sliceKey, &v_string);
    
    if (!status.ok())
    {
        return nil;
    }
    return [[NSString alloc] initWithBytes:v_string.data() length:v_string.length() encoding:NSUTF8StringEncoding];
}

- (NSData *)dataForKey:(NSString *)aKey
{
    if (!_db || !aKey) return nil;
    leveldb::Slice sliceKey = SliceByString(aKey);
    std::string v_string;
    leveldb::Status status = _db->Get(_readOptions, sliceKey, &v_string);
    if (!status.ok()) return nil;
    return [[NSData alloc] initWithBytes:v_string.data() length:v_string.length()];
}

- (id)objectForKey:(NSString *)aKey
{
    id value = nil;
    if (!_db || !aKey) return value;
    leveldb::Slice sliceKey = SliceByString(aKey);
    std::string v_string;
    leveldb::Status status = _db->Get(_readOptions, sliceKey, &v_string);
    if (!status.ok()) return value;
    NSData *data = [[NSData alloc] initWithBytes:v_string.data() length:v_string.length()];
    if (!data) return value;
    @try {
        value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        value = nil;
    }
    return value;
}


#pragma mark -
#pragma mark Getting Default Values callback

- (void )stringForKey:(NSString *)aKey  callback:(ResultCallbackWithParams)callback
{
    
    dispatch_async(_ldbQueue, ^{
        
        if (!_db || !aKey){
            callback(nil , -1 , nil);
            return  ;
            
        }
        
        leveldb::Slice sliceKey = SliceByString(aKey);
        std::string v_string;
        leveldb::Status status = _db->Get(_readOptions, sliceKey, &v_string);
        
        if (!status.ok())
        {
            callback(nil , status.ok() , nil);
        }else{
            callback([[NSString alloc] initWithBytes:v_string.data() length:v_string.length() encoding:NSUTF8StringEncoding] , status.ok() , nil);
        }
    });
}

- (void)dataForKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback
{
    dispatch_async(_ldbQueue, ^{
        
        if (!_db || !aKey) {
            
            callback(nil , -1 , nil);
        }
        leveldb::Slice sliceKey = SliceByString(aKey);
        std::string v_string;
        leveldb::Status status = _db->Get(_readOptions, sliceKey, &v_string);
        if (!status.ok())
        {
            callback(nil , status.ok() , nil);
        }else{
            callback([[NSData alloc] initWithBytes:v_string.data() length:v_string.length()] , 1 , nil);
        }
        
    });
    //    return [[NSData alloc] initWithBytes:v_string.data() length:v_string.length()];
}

- (void)objectForKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback
{
    
    dispatch_async(_ldbQueue, ^{
        
        id value = nil;
        if (!_db || !aKey)
        {
            callback(value , -1 , nil);
        }
        
        //        return value;
        leveldb::Slice sliceKey = SliceByString(aKey);
        std::string v_string;
        leveldb::Status status = _db->Get(_readOptions, sliceKey, &v_string);
        if (!status.ok())
        {
            callback(value , status.ok() , nil);
            return;
        }
        
        //        return value;
        NSData *data = [[NSData alloc] initWithBytes:v_string.data() length:v_string.length()];
        if (!data)
        {
            callback(value , status.ok() , nil);
            return;
        }
        //        return value;
        @try {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            value = nil;
        }
        
        
        callback(value , status.ok() , nil);
    });
    
    
    //    return value;
}

#pragma mark -
#pragma mark Setting Default Values

- (BOOL)putBool:(BOOL)value forKey:(NSString *)aKey
{
    return [self putString:[NSString stringWithFormat:@"%d",value] forKey:aKey];
}

- (BOOL)putInt:(NSInteger)value forKey:(NSString *)aKey
{
    return [self putString:[NSString stringWithFormat:@"%ld",value] forKey:aKey];
}

- (BOOL)putFloat:(double)value forKey:(NSString *)aKey
{
    return [self putString:[NSString stringWithFormat:@"%f",value] forKey:aKey];
}

- (BOOL)putString:(NSString *)value forKey:(NSString *)aKey
{
    if (!_db || !value || !aKey) return NO;
    leveldb::Slice sliceKey = SliceByString(aKey);
    leveldb::Slice sliceValue = SliceByString(value);
    leveldb::Status status = _db->Put(_writeOptions, sliceKey, sliceValue);
    _squence++;

    return status.ok();
}

- (void)putData:(NSData *)value forKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback
{
    
    PREP_BLOCK
    
    dispatch_async(_ldbQueue, ^{
        BEGIN_BLOCK
        
        if (!_db || !value || !aKey)
        {
            callback(nil,0,nil);
             return  ;
        }
        
        leveldb::Slice sliceKey = SliceByString(aKey);
        leveldb::Slice sliceValue = leveldb::Slice((char *)[value bytes],[value length]);
        leveldb::Status status = _db->Put(_writeOptions, sliceKey, sliceValue);
        
        _squence++;
        
        [self updateSquence];
        
        if (callback) {
            callback(nil,status.ok(),nil);
        }
        END_BLOCK
    });
 
    
}

- (void)putObject:(id)value forKey:(NSString *)aKey  callback:(ResultCallbackWithParams)callback
{
    
    PREP_BLOCK
    
    dispatch_async(_ldbQueue, ^{
        BEGIN_BLOCK
        
        if (!_db || !value || !aKey)
        {
            callback(nil,0,nil);
            //        return NO ;
        }
        
        NSData *data = nil;
        @try {
            data = [NSKeyedArchiver archivedDataWithRootObject:value];
        }
        @catch (NSException *exception) {
            callback(nil,0,nil);
            //        return NO ;
        }
        if (!data) {
            callback(nil,0,nil);
            //        return  NO;
        }
        leveldb::Slice sliceKey = SliceByString(aKey);
        leveldb::Slice sliceValue = leveldb::Slice((char *)[data bytes],[data length]);
        leveldb::Status status = _db->Put(_writeOptions, sliceKey, sliceValue);
        
        _squence++;
        
        [self updateSquence];
        if (callback) {
            callback(nil,status.ok(),nil);
        }
        END_BLOCK
    });
     
}
                       
#pragma mark -
#pragma mark Setting Default Values  no key

- (void)putString:(NSString *)value   callback:(ResultCallbackWithParams)callback
    {
        
        PREP_BLOCK
        
        dispatch_async(_ldbQueue, ^{
            BEGIN_BLOCK
            if (!_db || !value ){
                if(callback){
                    callback(nil,0,nil);
 
                }
             }
            
            NSString * aKey = [NSString stringWithFormat:@"dataKey%lld",_squence];
            leveldb::Slice sliceKey = SliceByString(aKey);
            leveldb::Slice sliceValue = SliceByString(value);
            leveldb::Status status = _db->Put(_writeOptions, sliceKey, sliceValue);
            _squence++;
            
            if (callback) {
                callback(nil,status.ok(),nil);
            }
            END_BLOCK
        });
    }
        
 

- (void)putData:(NSData *)value  callback:(ResultCallbackWithParams)callback
{
    PREP_BLOCK
    
    dispatch_async(_ldbQueue, ^{
        BEGIN_BLOCK
        
        if (!_db || !value ) {
            if (callback) {
                callback(nil,0,nil);
            }
        }
        
        
        NSString * aKey = [NSString stringWithFormat:@"dataKey%lld",_squence];
        
        leveldb::Slice sliceKey = SliceByString(aKey);
        leveldb::Slice sliceValue = leveldb::Slice((char *)[value bytes],[value length]);
        leveldb::Status status = _db->Put(_writeOptions, sliceKey, sliceValue);
        
        _squence++;
        
        [self updateSquence];
        if (callback) {
            callback(nil,status.ok(),nil);
        }
        END_BLOCK
    });
    
}

- (void)putObject:(id)value Source:(NSString *)source callback:(ResultCallbackWithParams)callback

{
    
    PREP_BLOCK
    
    dispatch_async(_ldbQueue, ^{
        BEGIN_BLOCK
        if (!_db || !value ){
            if (callback) {
                callback(nil,0,nil);
            }
        }
        
        NSString * aKey = [NSString stringWithFormat:@"dataKey%@%lld",source?source:@"",_squence];
        
        NSData *data = nil;
        @try {
            data = [NSKeyedArchiver archivedDataWithRootObject:value];
        }
        @catch (NSException *exception) {
            if (callback) {
                callback(nil,0,nil);
            }
        }
        if (!data) {
            if (callback) {
                callback(nil,0,nil);
            }
        }
        leveldb::Slice sliceKey = SliceByString(aKey);
        leveldb::Slice sliceValue = leveldb::Slice((char *)[data bytes],[data length]);
        leveldb::Status status = _db->Put(_writeOptions, sliceKey, sliceValue);
        
        _squence++;
        
        [self updateSquence];
        if (callback) {
            callback(nil,status.ok(),nil);
        }
        END_BLOCK
    });
//    return status.ok();
}



- (BOOL)removeValueForKey:(NSString *)aKey
{
    if (!_db || !aKey) return NO;
    leveldb::Slice sliceKey = SliceByString(aKey);
    leveldb::Status status = _db->Delete(_writeOptions, sliceKey);
    return status.ok();
}

- (void)removeValueForKey:(NSString *)aKey callback:(ResultCallbackWithParams)callback
{
    PREP_BLOCK
    
    dispatch_async(_ldbQueue, ^{
        BEGIN_BLOCK
        
        if (!_db || !aKey) {
            if(callback){
                callback(nil ,NO,nil);
            }
        }
        leveldb::Slice sliceKey = SliceByString(aKey);
        leveldb::Status status = _db->Delete(_writeOptions, sliceKey);
        if(callback){
            callback(nil ,status.ok(),nil);
        }
        END_BLOCK
    });
    //    return status.ok();
}

- (NSArray *)allKeys
{
    if (_db == NULL) return nil;
    NSMutableArray *keys = [NSMutableArray array];
    [self enumerateKeys:^(NSString *key, BOOL *stop) {
        [keys addObject:key];
    }];
    return keys;
}
- (void)allKeysCallback:(ResultCallbackWithParams)callback{
    
    PREP_BLOCK
    
    dispatch_async(_ldbQueue, ^{
        BEGIN_BLOCK
        if (_db == NULL)
        {
            if(callback){
                callback(nil ,NO,nil);
            }
        }
        
        NSMutableArray *keys = [NSMutableArray array];
        [self enumerateKeys:^(NSString *key, BOOL *stop) {
            [keys addObject:key];
        }];
        if(callback){
            callback(keys ,YES,nil);
        }
        END_BLOCK
    });
//    return keys;
}

- (void)enumerateKeys:(void (^)(NSString *key, BOOL *stop))block
{
    if (_db == NULL) return;
    BOOL stop = NO;
    leveldb::Iterator* iter = _db->NewIterator(leveldb::ReadOptions());
    for (iter->SeekToFirst(); iter->Valid(); iter->Next()) {
        leveldb::Slice key = iter->key();
        NSString *k = StringBySlice(key);
        block(k, &stop);
        if (stop)
            break;
    }
    delete iter;
}

- (BOOL)clear
{
    NSArray *keys = [self allKeys];
    BOOL result = YES;
    for (NSString *k in keys) {
        result = result && [self removeValueForKey:k];
    }
    return result;
}

- (BOOL)deleteDB
{
    delete _db;
    _db = NULL;
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:NULL];
}

@end
