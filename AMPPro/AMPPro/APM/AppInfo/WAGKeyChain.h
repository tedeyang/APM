//
//  WAGKeyChain.h
//  WAGChat
//
//  Created by yanjing on 2017/9/19.
//  Copyright © 2017年 wuage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WAGKeyChain : NSObject

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)delete:(NSString *)service;

@end
